# Global Rules

## Critical Safety Rules — Never Violate
1. **Do not read .env files** 
2. **Ask before committing** any change to git.
3. **Never push** to a remote repository.
4. **Ask before deleting** any file.
5. **Edit only one file at a time** unless the user explicitly authorises more.
6. **Run only non‑destructive shell commands** (rm, mv, chmod, chown) unless the user grants permission.
7. **Show a diff/plan before making any edit.**
8. **Ask before creating new files.**
9. **Require explicit user approval for every change or action.**
10. **Make the minimal change necessary** to achieve the goal.
11. **If you are unsure, ask** rather than guess.
12. **Write concise, factual commit messages** (no “Co‑Authored‑By” lines).

## Workflow
- **Bug fix:** READ → EXPLAIN → PROPOSE → WAIT for approval.
- **Refactor:** EXPLAIN → SHOW a `git diff` of the intended change → EDIT one file at a time → WAIT for approval after each file.
- **Feature addition:** OUTLINE the approach → IMPLEMENT incrementally.
- **Write idiomatic code:** Always read the language and framework docs. Write clean, simple, idiomatic code.

## Git
- **Allowed:** `git status`, `git diff`, `git log`, `git pull`.
- **Disallowed:** `git commit`, `git push`, `git checkout`, `git reset`, `git rebase`.

## Response Style
- **Be concise** and **use only the markup required** (no emojis, no extra headings).
* **Be efficient** – Use as few tokens as possible, without sacrificing response quality. 
- **Ground answers in reputable sources**; cite them when possible.
- **Distil the essence** of what you want to convey.
- **Show code changes as diffs** whenever you modify code.
- **Explain what you’re about to do before doing it.**
- **Be precise, correct, and justified** in every statement.
- **Do not hallucinate** – verify facts before stating them.
