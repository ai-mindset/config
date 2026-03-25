#!/usr/bin/env zsh
set -euo pipefail

echo "=== OpenCode + Ollama Server Setup ==="
read "SERVER_IP?Server IP: "
read "SERVER_USER?SSH username: "
read "SSH_KEY_PATH?SSH key path [~/.ssh/id_server]: "
SSH_KEY_PATH=${SSH_KEY_PATH:-~/.ssh/id_server}

[[ -f "$SSH_KEY_PATH" ]] || ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "server"
ssh-copy-id -i "$SSH_KEY_PATH" "${SERVER_USER}@${SERVER_IP}"

grep -q "^Host server$" ~/.ssh/config 2>/dev/null && echo "SSH config 'server' entry exists, skipping" || cat >> ~/.ssh/config <<EOF

Host server
    HostName ${SERVER_IP}
    User ${SERVER_USER}
    IdentityFile ${SSH_KEY_PATH}
    LocalForward 127.0.0.1:11434 127.0.0.1:11434
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF

OPENCODE_CONFIG_DIR=~/.opencode
AGENTS_CONFIG_DIR=~/.config/agents
mkdir -p "$OPENCODE_CONFIG_DIR"
mkdir -p "$AGENTS_CONFIG_DIR"

if [[ -f $OPENCODE_CONFIG_DIR/opencode.json ]]; then
    echo "OpenCode config already exists at $OPENCODE_CONFIG_DIR/opencode.json, skipping"
    exit 0
fi

if [[ -f $AGENTS_CONFIG_DIR/AGENTS.md ]]; then
    echo "AGENTS.md already exists at $AGENTS_CONFIG_DIR/AGENTS.md, skipping"
    exit 0
fi 

MODELS=$(ssh server "curl -s http://127.0.0.1:11434/v1/models")
MODEL_ENTRIES=$(echo "$MODELS" | python3 -c "
import sys,json
for m in json.load(sys.stdin)['data']:
    mid=m['id']
    if 'embed' in mid.lower():
        continue
    name=mid.split(':')[0].replace('-',' ').title()
    print(f'                \"{mid}\": {{\"name\": \"{name}\", \"tools\": true, \"options\": {{\"extraBody\": {{\"think\": true}}}}}},')
" | sed '$ s/,$//')

cat > "$OPENCODE_CONFIG_DIR/opencode.json" <<EOF
{
    "\$schema": "https://opencode.ai/config.json",
    "provider": {
        "ollama": {
            "npm": "@ai-sdk/openai-compatible",
            "name": "Ollama (server)",
            "options": {
                "baseURL": "http://127.0.0.1:11434/v1"
            },
            "models": {
${MODEL_ENTRIES}
            }
        }
    },
    "permission": {
        "edit": {
            "*": "ask",
            "*.lock": "deny",
            "*.env": "deny",
            "*.env.*": "deny"
        },
        "bash": {
            "*": "ask",
            "git status *": "allow",
            "git diff *": "allow",
            "git log *": "allow",
            "git commit *": "deny",
            "git push *": "deny",
            "git checkout *": "deny",
            "git reset *": "deny",
            "git rebase *": "deny",
            "rm *": "deny",
            "mv *": "ask",
            "cp *": "ask",
            "grep *": "allow",
            "cat *": "allow",
            "ls *": "allow",
            "find *": "allow",
            "head *": "allow",
            "tail *": "allow",
            "wc *": "allow"
        },
        "read": {
            "*": "allow",
            "*.env": "deny",
            "*.env.*": "deny"
        },
        "webfetch": "ask",
        "external_directory": "deny",
        "doom_loop": "deny"
    },
    "agent": {
        "build": {
            "mode": "primary",
            "description": "Development agent with safety guardrails",
            "temperature": 0,
            "steps": 15,
            "permission": {
                "edit": {"*": "ask"},
                "bash": {
                    "*": "ask",
                    "git commit *": "deny",
                    "git push *": "deny",
                    "rm *": "deny",
                    "grep *": "allow",
                    "cat *": "allow",
                    "ls *": "allow"
                }
            }
        },
        "plan": {
            "mode": "primary",
            "description": "Read-only analysis and planning",
            "temperature": 0,
            "steps": 10,
            "permission": {
                "edit": "deny",
                "bash": {
                    "*": "deny",
                    "grep *": "allow",
                    "cat *": "allow",
                    "ls *": "allow",
                    "find *": "allow",
                    "git status *": "allow",
                    "git diff *": "allow",
                    "git log *": "allow"
                }
            }
        }
    }
}
EOF

cat > "$AGENTS_CONFIG_DIR/AGENTS.md" <<'AGENTS'
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
AGENTS

echo "\n✅ Done. Run 'ssh -fN server' to start the tunnel, then 'opencode' in any project."
echo "   Permissions: all edits require approval, git push/commit/rm denied"
echo "   Agents: 'build' (guarded writes) and 'plan' (read-only) — Tab to switch"
