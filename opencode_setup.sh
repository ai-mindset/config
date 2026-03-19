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

mkdir -p ~/.config/opencode
MODELS=$(ssh server "curl -s http://127.0.0.1:11434/v1/models")
MODEL_ENTRIES=$(echo "$MODELS" | python3 -c "
import sys,json
for m in json.load(sys.stdin)['data']:
    mid=m['id']; name=mid.split(':')[0].replace('-',' ').title()
    print(f'                \"{mid}\": {{\"name\": \"{name}\", \"tools\": true}},')
" | sed '$ s/,$//')

cat > ~/.config/opencode/opencode.json <<EOF
{
    "\$schema": "https://opencode.ai/config.json",
    "provider": {
        "ollama": {
            "npm": "@ai-sdk/openai-compatible",
            "name": "Ollama",
            "options": {
                "baseURL": "http://127.0.0.1:11434/v1"
            },
            "models": {
${MODEL_ENTRIES}
            }
        }
    }
}
EOF

echo "\n✅ Done. Run 'ssh -fN server' to start the tunnel, then 'opencode' in any project."
