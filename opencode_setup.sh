#!/usr/bin/env zsh
set -euo pipefail
set -x

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

OPENCODE_CONFIG_DIR=$HOME/.opencode
AGENTS_CONFIG_DIR=$HOME/.config/agents
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

MODELS=$(curl -s http://127.0.0.1:11434/v1/models)
if [[ -z "$MODELS" ]]; then
    MODELS=$(ssh server "curl -s http://127.0.0.1:11434/v1/models")
fi
if [[ -z "$MODELS" ]]; then
    echo "ERROR: Could not reach Ollama locally or via SSH tunnel." >&2
    echo "       Is 'ssh -fN server' running?" >&2
    exit 1
fi

SELECTION=$(echo "$MODELS" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)['data']
except Exception as e:
    print(f'ERROR: Failed to parse Ollama model list: {e}', file=sys.stderr)
    sys.exit(1)

ids = [m['id'] for m in data if 'embed' not in m['id'].lower()]

if not ids:
    print('ERROR: No non-embedding models found in Ollama. Have you pulled any models?', file=sys.stderr)
    sys.exit(1)

BUILD_CANDIDATES = ['qwen3.6:35b', 'qwen3.6:27b', 'devstral-small-2:24b', 'gemma4:31b', 'granite4.1:30b']
PLAN_CANDIDATES  = ['gpt-oss:120b', 'qwen3.5:122b-a10b', 'nemotron-3-super:latest', 'nemotron-cascade-2:30b']

def pick(role, candidates, ids):
    for c in candidates:
        if c in ids:
            return c
    print(f'ERROR: No suitable {role} model found in Ollama.', file=sys.stderr)
    print(f'  Expected one of: {chr(44).join(candidates)}', file=sys.stderr)
    print(f'  Available models: {chr(44).join(ids)}', file=sys.stderr)
    return None

build_model = pick('build', BUILD_CANDIDATES, ids)
plan_model  = pick('plan',  PLAN_CANDIDATES,  ids)

if not build_model or not plan_model:
    sys.exit(1)

entries = []
for mid in ids:
    parts = mid.replace('-', ' ').split(':')
    name = parts[0].title() + ' ' + parts[1] if ':' in mid else parts[0].title()
    entries.append(f'                \"{mid}\": {{\"name\": \"{name}\", \"tools\": true, \"options\": {{\"extraBody\": {{\"think\": true}}}}}}')
model_entries = ',\n'.join(entries)

print(f'{model_entries}|||{build_model}|||{plan_model}')
")

PYTHON_EXIT=$?
if [[ $PYTHON_EXIT -ne 0 ]]; then
    echo "ERROR: Model selection failed." >&2
    exit 1
fi

MODEL_ENTRIES=$(echo "$SELECTION" | awk -F'[|][|][|]' 'BEGIN{RS=""} {print $1}')
BUILD_MODEL=$(echo "$SELECTION"   | awk -F'[|][|][|]' 'BEGIN{RS=""} {print $2}')
PLAN_MODEL=$(echo "$SELECTION"    | awk -F'[|][|][|]' 'BEGIN{RS=""} {print $3}')

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
            "git pull *": "allow",
            "git commit *": "deny",
            "git push *": "ask",
            "git checkout *": "ask",
            "git reset *": "deny",
            "git rebase *": "ask",
            "rm *": "deny",
            "rm -rf": "deny",
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
            "model": "${BUILD_MODEL}",
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
                    "rm -rf": "deny",
                    "grep *": "allow",
                    "cat *": "allow",
                    "ls *": "allow"
                }
            }
        },
        "plan": {
            "model": "${PLAN_MODEL}",
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

echo "✓ OpenCode config written to $OPENCODE_CONFIG_DIR/opencode.json"
echo "  build agent → $BUILD_MODEL"
echo "  plan  agent → $PLAN_MODEL"

cat > "$AGENTS_CONFIG_DIR/AGENTS.md" <<'AGENTS'
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
11. **Write concise, factual commit messages** (no "Co‑Authored‑By" lines).

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
- **Explain what you're about to do before doing it.**
- **Be precise, correct, and justified** in every statement.
- **Do not hallucinate** – verify facts before stating them.

AGENTS

echo "\n✅ Done. Run 'ssh -fN server' to start the tunnel, then 'opencode' in any project."
echo "   Permissions: all edits require approval, git push/commit/rm denied"
echo "   Agents: 'build' (guarded writes) and 'plan' (read-only) — Tab to switch"
