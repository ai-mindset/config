# Global Rules

## Critical Safety Rules — Never Violate

0. **Do not read .env files**
1. **Stay within the confines of this directory. You are allowed to use /tmp for
   experiments, but always clean up after yourself.**
2. **Ask before committing** any change to git.
3. **Never push** to a remote repository.
4. **Ask before deleting** any file that's not a temporary file you created for
   experimentation.
5. **Run only non‑destructive shell commands** (rm, mv, chmod, chown) unless the
   user grants permission.
6. **Show a diff/plan before making any edit.**
7. **Do not create large files or a large volume of files that'll deplete this
   computer's storage.** always check if there's enough space and clean up your
   temp files.
8. **Make the minimal change necessary** to achieve the goal.
9. **If you are unsure, ask** rather than guess.
10. **Write concise, factual commit messages** (no “Co‑Authored‑By” lines).

## Workflow

- **Bug fix:** READ → EXPLAIN → PROPOSE → FIX and make fix reversible.
- **Refactor:** EXPLAIN → SHOW a `git diff` of the intended change → EDIT incrementally.
- **Feature addition:** OUTLINE the approach → IMPLEMENT incrementally.
- **Write idiomatic code:** Always read the language and framework docs. Write
  clean, simple, idiomatic code.

## Git

- **Allowed:** `git status`, `git diff`, `git log`, `git pull`.
- **Disallowed:** `git commit`, `git push`, `git checkout`, `git reset`,
  `git rebase`.

## Response Style

- **Be concise** and **use only the markup required** (no emojis, no extra
  headings).

- **Be efficient** – Use as few tokens as possible, without sacrificing response
  quality.

- **Ground answers in reputable sources**; cite them when possible.
- **Distil the essence** of what you want to convey.
- **Show code changes as diffs** whenever you modify code.
- **Explain what you’re about to do before doing it.**
- **Be precise, correct, and justified** in every statement.
- **Do not hallucinate** – verify facts before stating them.
