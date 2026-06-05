#!/usr/bin/env zsh
set -euo pipefail

echo "=== OpenCode + Ollama Server Setup ==="

# --- SSH setup ---
if grep -q "^Host server$" ~/.ssh/config 2>/dev/null; then
    echo "Existing 'Host server' entry found in ~/.ssh/config."
    read "REPLY?Reuse existing SSH config? [Y/n]: "
    if [[ "$REPLY" =~ ^[Nn]$ ]]; then
        read "SERVER_IP?Server IP: "
        read "SERVER_USER?SSH username: "
        read "SSH_KEY_PATH?SSH key path [~/.ssh/id_server]: "
        SSH_KEY_PATH=${SSH_KEY_PATH:-~/.ssh/id_server}

        [[ -f "$SSH_KEY_PATH" ]] || ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "server"
        ssh-copy-id -i "$SSH_KEY_PATH" "${SERVER_USER}@${SERVER_IP}"

        # Replace existing entry
        sed -i '' '/^Host server$/,/^Host /{ /^Host server$/d; /^Host /!d; }' ~/.ssh/config
        cat >> ~/.ssh/config <<EOF

Host server
    HostName ${SERVER_IP}
    User ${SERVER_USER}
    IdentityFile ${SSH_KEY_PATH}
    LocalForward 127.0.0.1:11434 127.0.0.1:11434
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
    fi
else
    read "SERVER_IP?Server IP: "
    read "SERVER_USER?SSH username: "
    read "SSH_KEY_PATH?SSH key path [~/.ssh/id_server]: "
    SSH_KEY_PATH=${SSH_KEY_PATH:-~/.ssh/id_server}

    [[ -f "$SSH_KEY_PATH" ]] || ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "server"
    ssh-copy-id -i "$SSH_KEY_PATH" "${SERVER_USER}@${SERVER_IP}"

    cat >> ~/.ssh/config <<EOF

Host server
    HostName ${SERVER_IP}
    User ${SERVER_USER}
    IdentityFile ${SSH_KEY_PATH}
    LocalForward 127.0.0.1:11434 127.0.0.1:11434
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
fi

OPENCODE_CONFIG_DIR=$HOME/.opencode
AGENTS_CONFIG_DIR=$HOME/.config/agents
mkdir -p "$OPENCODE_CONFIG_DIR"
mkdir -p "$AGENTS_CONFIG_DIR"

# --- File selection ---
echo ""
echo "Which config(s) would you like to generate?"
echo "  1) opencode.json"
echo "  2) AGENTS.md"
echo "  3) Both"
read "FILE_CHOICE?Select [1-3]: "

GEN_OPENCODE=false
GEN_AGENTS=false
case "$FILE_CHOICE" in
    1) GEN_OPENCODE=true ;;
    2) GEN_AGENTS=true ;;
    3) GEN_OPENCODE=true; GEN_AGENTS=true ;;
    *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

# --- Regeneration prompts ---
if [[ $GEN_OPENCODE == true && -f $OPENCODE_CONFIG_DIR/opencode.json ]]; then
    read "REPLY?opencode.json already exists. Regenerate? [y/N]: "
    [[ "$REPLY" =~ ^[Yy]$ ]] || GEN_OPENCODE=false
fi

if [[ $GEN_AGENTS == true && -f $AGENTS_CONFIG_DIR/AGENTS.md ]]; then
    read "REPLY?AGENTS.md already exists. Regenerate? [y/N]: "
    [[ "$REPLY" =~ ^[Yy]$ ]] || GEN_AGENTS=false
fi

if [[ $GEN_OPENCODE == false && $GEN_AGENTS == false ]]; then
    echo "Nothing to generate. Exiting."
    exit 0
fi

# --- Fetch model list ---
MODELS=$(curl -s http://127.0.0.1:11434/v1/models)
if [[ -z "$MODELS" ]]; then
    MODELS=$(ssh server "curl -s http://127.0.0.1:11434/v1/models")
fi
if [[ -z "$MODELS" ]]; then
    echo "ERROR: Could not reach Ollama locally or via SSH tunnel." >&2
    exit 1
fi

# --- Model selection ---
if [[ $GEN_OPENCODE == true ]]; then
    echo ""
    echo "Model selection:"
    echo "  1) Use defaults (auto-detect from candidates list)"
    echo "  2) Choose manually"
    read "MODEL_CHOICE?Select [1-2]: "

    if [[ $MODEL_CHOICE == "2" ]]; then
        echo ""
        echo "Available models:"
        echo "$MODELS" | python3 -c "
import sys, json
data = json.load(sys.stdin)['data']
ids = [m['id'] for m in data if 'embed' not in m['id'].lower()]
[print(f'{i}) {mid}') for i, mid in enumerate(ids, 1)]
"
        read "PLAN_IDX?Select PLAN model number: "
        read "BUILD_IDX?Select BUILD (coding) model number: "
    fi

    SELECTION=$(echo "$MODELS" | python3 -c "
import sys, json, re

try:
    data = json.load(sys.stdin)['data']
except Exception as e:
    print(f'ERROR: Failed to parse Ollama model list: {e}', file=sys.stderr)
    sys.exit(1)

ids = [m['id'] for m in data if 'embed' not in m['id'].lower()]

if not ids:
    print('ERROR: No non-embedding models found.', file=sys.stderr)
    sys.exit(1)

BUILD_CANDIDATES = ['qwen3.6:35b', 'qwen3.6:27b', 'devstral-small-2:24b', 'gemma4:31b', 'granite4.1:30b']
PLAN_CANDIDATES  = ['nemotron-3-super:latest', 'nemotron-cascade-2:30b']

def sanitise(mid): return re.sub(r'[^a-zA-Z0-9]', '_', mid)
def pretty_name(mid): return re.sub(r'[_:\.\-]+', ' ', mid).title()

def pick_default(role, candidates, ids):
    for c in candidates:
        if c in ids:
            return c
    print(f'ERROR: No suitable {role} model found.', file=sys.stderr)
    print(f'  Expected one of: {chr(44).join(candidates)}', file=sys.stderr)
    print(f'  Available: {chr(44).join(ids)}', file=sys.stderr)
    return None

mode = sys.argv[1]
if mode == 'default':
    build_model = pick_default('build', BUILD_CANDIDATES, ids)
    plan_model  = pick_default('plan',  PLAN_CANDIDATES,  ids)
    if not build_model or not plan_model:
        sys.exit(1)
else:
    build_model = ids[int(sys.argv[2]) - 1]
    plan_model  = ids[int(sys.argv[3]) - 1]

entries = []
for mid in ids:
    key  = sanitise(mid)
    name = pretty_name(mid)
    entries.append(
        f'                \"{key}\": {{\"id\": \"{mid}\", \"name\": \"{name}\", \"tools\": true, \"options\": {{\"extraBody\": {{\"think\": true}}}}}}'
    )
model_entries = ',\n'.join(entries)
print(f'{model_entries}|||{sanitise(build_model)}|||{sanitise(plan_model)}')
" "$( [[ $MODEL_CHOICE == "2" ]] && echo manual || echo default )" \
  "$( [[ $MODEL_CHOICE == "2" ]] && echo $BUILD_IDX || echo 0 )" \
  "$( [[ $MODEL_CHOICE == "2" ]] && echo $PLAN_IDX  || echo 0 )")

    PYTHON_EXIT=$?
    if [[ $PYTHON_EXIT -ne 0 ]]; then
        echo "ERROR: Model selection failed." >&2
        exit 1
    fi

    MODEL_ENTRIES=$(echo "$SELECTION" | awk -F'[|][|][|]' 'BEGIN{RS=""} {print $1}')
    BUILD_KEY=$(echo "$SELECTION"     | awk -F'[|][|][|]' 'BEGIN{RS=""} {print $2}')
    PLAN_KEY=$(echo "$SELECTION"      | awk -F'[|][|][|]' 'BEGIN{RS=""} {print $3}')
fi

# --- Generate opencode.json ---
if [[ $GEN_OPENCODE == true ]]; then
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
            "model": "ollama/${BUILD_KEY}",
            "mode": "primary",
            "description": "Development agent with safety guardrails",
            "temperature": 0,
            "steps": 15,
            "permission": {
                "edit": { "*": "ask" },
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
            "model": "ollama/${PLAN_KEY}",
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
    echo "Written: $OPENCODE_CONFIG_DIR/opencode.json (build: ${BUILD_KEY}, plan: ${PLAN_KEY})"
fi

# --- Generate AGENTS.md ---
if [[ $GEN_AGENTS == true ]]; then
    cat > "$AGENTS_CONFIG_DIR/AGENTS.md" <<'EOF'
# Agent Guidelines

## build
- You are a careful, precise coding agent.
- Always explain changes before making them.
- Never commit or push without explicit user approval.
- Prefer small, focused edits over large rewrites.

## plan
- You are a read-only analysis and planning agent.
- Never edit files or run destructive commands.
- Produce clear, structured plans with explicit reasoning.
- Flag risks and trade-offs before recommending an approach.
EOF
    echo "Written: $AGENTS_CONFIG_DIR/AGENTS.md"
fi
