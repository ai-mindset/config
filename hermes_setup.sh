
#!/usr/bin/env zsh
set -e

IMAGE="nousresearch/hermes-agent"
DATA="$HOME/.hermes"
UID_=$(id -u)
SERVICE_DIR="$HOME/.config/systemd/user"

echo ">>> Pulling Hermes image..."
podman pull "$IMAGE"

echo ">>> Creating data directories..."
mkdir -p "$DATA"/{cron,sessions,logs,hooks,memories,skills,skins,plans,workspace,home}
chmod 777 "$DATA"

echo ">>> Running interactive setup (follow the prompts)..."
echo "    Use http://localhost:11434/v1 as your endpoint"
podman run -it --rm \
  --network=host \
  --userns=keep-id:uid=10000,gid=10000 \
  -v "$DATA:/opt/data:z" \
  "$IMAGE" setup

echo ">>> Creating systemd user service..."
mkdir -p "$SERVICE_DIR"
cat > "$SERVICE_DIR/hermes.service" << EOF
[Unit]
Description=Hermes Agent Daemon
After=network.target

[Service]
ExecStart=podman run --rm \
  --name hermes \
  --network=host \
  --userns=keep-id:uid=10000,gid=10000 \
  -v $DATA:/opt/data:z \
  $IMAGE gateway run
ExecStop=podman stop hermes
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable hermes

echo ">>> Creating sleep hook (needs sudo)..."
HOOK=/etc/systemd/system-sleep/hermes-sleep
[ ! -d /etc/systemd/system-sleep ] && sudo mkdir /etc/systemd/system-sleep
sudo tee "$HOOK" > /dev/null << EOF
#!/bin/bash
case \$1 in
  pre)
    sudo -u $(whoami) XDG_RUNTIME_DIR=/run/user/$UID_ systemctl --user stop hermes
    ;;
  post)
    sudo -u $(whoami) XDG_RUNTIME_DIR=/run/user/$UID_ systemctl --user start hermes
    ;;
esac
EOF
sudo chmod +x "$HOOK"

echo ">>> Adding hermes() function to ~/.zshrc..."
FUNC='hermes() { podman run -it --rm --network=host --userns=keep-id:uid=10000,gid=10000 -v $HOME/.hermes:/opt/data:z nousresearch/hermes-agent "$@" }'
grep -qF 'nousresearch/hermes-agent' ~/.zshrc || echo "$FUNC" >> ~/.zshrc
echo "    Run 'source ~/.zshrc' or open a new terminal, then just type: hermes"

echo ">>> Starting Hermes..."
systemctl --user start hermes

echo ""
echo "All done! Check status with: systemctl --user status hermes"

