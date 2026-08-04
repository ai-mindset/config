#!/usr/bin/env python3
"""Rebuild a Git branch as a small sequence of logical commits."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path, PurePosixPath
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from typing import NoReturn


def fail(message: str) -> NoReturn:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def git(
    *args: str,
    input_text: str | None = None,
    env: dict[str, str] | None = None,
    check: bool = True,
) -> str:
    result = subprocess.run(
        ["git", *args],
        input=input_text,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
        check=False,
    )
    if check and result.returncode:
        detail = result.stderr.strip() or result.stdout.strip()
        fail(f"git {' '.join(args)} failed: {detail}")
    return result.stdout.strip()


def tracked_files(*pathspecs: str) -> set[str]:
    command = ["ls-files", "-z"]
    if pathspecs:
        command.extend(["--", *pathspecs])
    output = subprocess.run(
        ["git", *command],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if output.returncode:
        fail(output.stderr.decode(errors="replace").strip())
    return {
        os.fsdecode(item)
        for item in output.stdout.split(b"\0")
        if item
    }


def is_env_file(path: str) -> bool:
    return any(part == ".env" or part.startswith(".env.") for part in PurePosixPath(path).parts)


def load_plan(path: Path) -> list[dict[str, object]]:
    try:
        document = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        fail(f"cannot read plan {path}: {error}")

    if not isinstance(document, dict) or set(document) != {"commits"}:
        fail('the plan must contain exactly one top-level key: "commits"')
    commits = document["commits"]
    if not isinstance(commits, list) or not commits:
        fail('"commits" must be a non-empty array')

    validated: list[dict[str, object]] = []
    for number, commit in enumerate(commits, 1):
        if not isinstance(commit, dict) or set(commit) != {"message", "paths"}:
            fail(f"commit {number} must contain exactly 'message' and 'paths'")
        message = commit["message"]
        paths = commit["paths"]
        if not isinstance(message, str) or not message.strip():
            fail(f"commit {number} has an empty message")
        if not isinstance(paths, list) or not paths or not all(
            isinstance(item, str) and item for item in paths
        ):
            fail(f"commit {number} must have a non-empty string path list")
        validated.append({"message": message.strip(), "paths": paths})
    return validated


def validate_assignments(commits: list[dict[str, object]]) -> list[tuple[str, list[str]]]:
    all_files = tracked_files()
    if not all_files:
        fail("the repository has no tracked files")
    forbidden = sorted(path for path in all_files if is_env_file(path))
    if forbidden:
        fail("refusing to process tracked .env files: " + ", ".join(forbidden))

    assigned: set[str] = set()
    groups: list[tuple[str, list[str]]] = []
    for number, commit in enumerate(commits, 1):
        message = str(commit["message"])
        pathspecs = [str(item) for item in commit["paths"]]  # type: ignore[union-attr]
        matched = tracked_files(*pathspecs)
        if not matched:
            fail(f"commit {number} matches no tracked files")
        overlap = sorted(assigned & matched)
        if overlap:
            fail(f"commit {number} reassigns files: " + ", ".join(overlap))
        assigned.update(matched)
        groups.append((message, sorted(matched)))

    missing = sorted(all_files - assigned)
    if missing:
        fail("tracked files missing from the plan: " + ", ".join(missing))
    return groups


def print_plan(branch: str, old_tip: str, groups: list[tuple[str, list[str]]]) -> None:
    print(f"Branch: {branch}")
    print(f"Current tip: {old_tip}")
    print("Replacement history:")
    for number, (message, files) in enumerate(groups, 1):
        print(f"  {number}. {message} ({len(files)} files)")


def rebuild(branch: str, old_tip: str, groups: list[tuple[str, list[str]]]) -> None:
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S-%f")
    backup_ref = f"refs/backup/{branch}-before-rewrite-{timestamp}"
    old_tree = git("rev-parse", f"{old_tip}^{{tree}}")

    descriptor, temporary_name = tempfile.mkstemp(prefix="git-rewrite-index-")
    os.close(descriptor)
    os.unlink(temporary_name)
    temporary_index = Path(temporary_name)
    temporary_env = os.environ.copy()
    temporary_env["GIT_INDEX_FILE"] = str(temporary_index)

    try:
        git("read-tree", "--empty", env=temporary_env)
        parent: str | None = None
        created: list[tuple[str, str]] = []
        for message, files in groups:
            git("add", "--", *files, env=temporary_env)
            tree = git("write-tree", env=temporary_env)
            arguments = ["commit-tree", tree]
            if parent:
                arguments.extend(["-p", parent])
            parent = git(*arguments, input_text=message + "\n", env=temporary_env)
            created.append((parent, message))
        if parent is None:
            fail("no commits were created")
        new_tip = parent
        new_tree = git("rev-parse", f"{new_tip}^{{tree}}")
        if new_tree != old_tree:
            fail(f"tree verification failed: old {old_tree}, new {new_tree}")

        print("\nVerified: the old and replacement trees are identical.")
        print("Proposed commits:")
        for commit_id, message in created:
            print(f"  {commit_id[:12]} {message}")
        answer = input(f'\nType "rewrite {branch}" to replace the local branch: ')
        if answer != f"rewrite {branch}":
            print("Cancelled. The branch and refs were not changed.")
            return

        git("update-ref", backup_ref, old_tip)
        git("update-ref", f"refs/heads/{branch}", new_tip, old_tip)
        print(f"\nRewrote {branch} successfully.")
        print(f"Backup: {backup_ref} -> {old_tip}")
        print("No remote was changed.")
        print("Recovery command:")
        print(
            f"  git update-ref refs/heads/{branch} {backup_ref} {new_tip}"
        )
    finally:
        try:
            temporary_index.unlink()
        except FileNotFoundError:
            pass


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Rebuild the current Git branch into logical commits without rebasing."
    )
    parser.add_argument("plan", type=Path, help="JSON file describing commits and paths")
    parser.add_argument(
        "--apply",
        action="store_true",
        help="build, verify, and offer to install the replacement history",
    )
    arguments = parser.parse_args()

    if not Path(".git").exists():
        fail("run this command from the root of a non-bare Git repository")
    branch = git("symbolic-ref", "--quiet", "--short", "HEAD", check=False)
    if not branch:
        fail("detached HEAD is not supported")
    if git("status", "--porcelain=v1", "--untracked-files=no"):
        fail("the working tree or index is not clean")

    commits = load_plan(arguments.plan)
    groups = validate_assignments(commits)
    old_tip = git("rev-parse", "HEAD")
    print_plan(branch, old_tip, groups)
    if not arguments.apply:
        print("\nValidation passed. Re-run with --apply to build the replacement history.")
        return
    rebuild(branch, old_tip, groups)


if __name__ == "__main__":
    main()
