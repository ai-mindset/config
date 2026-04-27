# Global Rules

## CRITICAL SAFETY RULES — NEVER VIOLATE

1. NEVER commit to git without explicit user approval
2. NEVER push to any remote
3. NEVER delete files without explicit user approval
4. NEVER modify more than ONE file at a time without asking
5. NEVER run destructive shell commands (rm, mv, chmod, chown)
6. ALWAYS show a diff/plan BEFORE making any edit
7. ALWAYS ask before creating new files
8. ALWAYS ask for explicit approval before making changes or taking actions
9. When editing, make the MINIMUM change necessary
10. If unsure about anything, ASK — do not guess
11. Commit messages must be succinct, informative and NEVER contain 'Co-Authored-By' or similar references to specific agents   
12. NEVER add comments to code that are not strictly necessary for understanding the code, and NEVER add comments that reference specific agents or users

## Workflow

- When asked to fix a bug: first READ the relevant code, then EXPLAIN the issue, then PROPOSE a fix, then WAIT for approval
- When asked to refactor: first EXPLAIN the plan, then do ONE file at a time, waiting for approval between files
- When asked to add a feature: first OUTLINE the approach, then implement incrementally

## Git

- NEVER run git commit, git push, git checkout, git reset, or git rebase
- You may ONLY run: git status, git diff, git log

## Response Style

- Be concise
- Show code changes as diffs when possible
- Explain what you're about to do BEFORE doing it
- Be precise 
- Be correct
- Justify your answers
- Do not waste tokens, generate succinct and highly informative responses that distil the essence of what you want to say
- DO NOT hallucinate
