# Global Rules

<!-- Thanks to BetterStack https://youtu.be/D4uBfIe7SzA -->

## Critical Safety Rules — Never Violate

0. **Do not read .env files**
1. **Stay within the confines of this directory. You are allowed to use /tmp for
   experiments.**
2. **Never push** to a remote repository.
3. **Ask before deleting** any file that's not a temporary file you created for
   experimentation.
4. **Run only non‑destructive shell commands** unless the user grants explicit
   permission.
5. **Do not create large files or a large volume of files that'll deplete this
   computer's storage.** always check if there's enough space and clean up your
   temp files.
6. **Make the minimal change necessary** to achieve the goal.
7. **If you are unsure, ask** rather than guess.
8. **Write concise, factua, succinct and informative commit messages** start
   with a tag e.g. add:, fix:, chore:, upd: etc.

## Workflow

- **Bug fix:** READ → EXPLAIN → PROPOSE → FIX and make fix reversible.
- **Refactor:** EXPLAIN → SHOW a `git diff` of the intended change → EDIT
  incrementally.
- **Feature addition:** OUTLINE the approach → IMPLEMENT incrementally.
- **Write idiomatic code:** Always read the language and framework docs. Write
  clean, simple, idiomatic code.

## Git

- **Allowed:** `git status`, `git diff`, `git log`, `git pull`, `git switch`,
  `git switch -c`
- **Disallowed:** `git push`, `git rebase`.

## Response Style

- **Be concise** and **use only the markup required** (no emojis, no extra
  headings).
- **Be efficient** – Use as few tokens as possible, without sacrificing response
  quality.
- **Ground answers in reputable sources** - always verify, validate and cite
  them.
- **Distil the essence** of what you want to say.
- **Show code changes as diffs** whenever you modify code.
- **Succinctly explain what you’re about to do before doing it.**
- **Be precise, correct, and justified** in every statement.

## Keeping this file current

This file is a failure log, not a wishlist. Every line below exists because it
went wrong at least once.

When you make a mistake, get corrected, or discover something about this
codebase that wasn't written down:

1. Add one line to the failure log below, in the imperative, describing the
   correct behaviour.
2. Keep it specific to this repo. General advice belongs nowhere.
3. If the fix is a workflow rather than a rule, put it in .codex/skills and link
   it from here.
4. Include the change in the same commit and mention it in your summary.

Keep this file under 500 lines. It is loaded into every session, and long
context makes you less reliable, not more. If a section outgrows its usefulness,
move it to api/AGENT.md, othersubdir/AGENT.md, or a skill.

## Failure log
