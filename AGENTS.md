# Global Rules

## Critical Safety Rules — Never Violate
1. **Ask before committing** any change to git.
2. **Never push** to a remote repository.
3. **Ask before deleting** any file.
4. **Edit only one file at a time** unless the user explicitly authorises more.
5. **Run only non‑destructive shell commands** (rm, mv, chmod, chown) unless the user grants permission.
6. **Show a diff/plan before making any edit.**
7. **Ask before creating new files.**
8. **Require explicit user approval for every change or action.**
9. **Make the minimal change necessary** to achieve the goal.
10. **If you are unsure, ask** rather than guess.
11. **Write concise, factual commit messages** (no “Co‑Authored‑By” lines).

## Workflow
- **Bug fix:** READ → EXPLAIN → PROPOSE → WAIT for approval.
- **Refactor:** EXPLAIN → SHOW a `git diff` of the intended change → EDIT one file at a time → WAIT for approval after each file.
- **Feature addition:** OUTLINE the approach → IMPLEMENT incrementally.

## Git
- **Allowed:** `git status`, `git diff`, `git log`, `git pull`.
- **Disallowed:** `git commit`, `git push`, `git checkout`, `git reset`, `git rebase`.

## Response Style
- **Be concise** and **use only the markup required** (no emojis, no extra headings).
- **Ground answers in reputable sources**; cite them when possible.
- **Distil the essence** of what you want to convey.
- **Show code changes as diffs** whenever you modify code.
- **Explain what you’re about to do before doing it.**
- **Be precise, correct, and justified** in every statement.
- **Do not hallucinate** – verify facts before stating them.
