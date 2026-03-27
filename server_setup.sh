#!/usr/bin/env zsh
set -euo pipefail

echo "=== Server Setup ==="
read "HOSTNAME?Hostname: "
read "WIFI_SSID?WiFi SSID: "
read -s "WIFI_PASS?WiFi password: "; echo
read "STATIC_IP?Static IP (e.g. 192.168.1.100/24): "
read "GATEWAY?Gateway (e.g. 192.168.1.1): "

sudo hostnamectl set-hostname "$HOSTNAME"

echo "\n🔎 Force console to 1080p"
sudo grubby --update-kernel=ALL --args="video=1920x1080"

echo "\n📡 Configuring WiFi with static IP and Quad9 DNS"
nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASS" name "server-wifi"
nmcli connection modify "server-wifi" \
    ipv4.method manual \
    ipv4.addresses "$STATIC_IP" \
    ipv4.gateway "$GATEWAY" \
    ipv4.dns "9.9.9.9;149.112.112.112" \
    ipv6.method disabled \
    connection.autoconnect yes
nmcli connection up "server-wifi"

echo "\n🔒 Hardening SSH"
sudo systemctl enable --now sshd
sudo tee /etc/ssh/sshd_config.d/99-hardened.conf > /dev/null <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
MaxAuthTries 3
X11Forwarding no
AllowTcpForwarding yes
ClientAliveInterval 300
ClientAliveCountMax 2
EOF
sudo systemctl restart sshd

echo "\n🧱 Configuring firewall (drop all, allow SSH only)"
sudo dnf install -y firewalld
sudo systemctl enable --now firewalld
sudo firewall-cmd --set-default-zone=drop
sudo firewall-cmd --permanent --zone=drop --add-service=ssh
sudo firewall-cmd --reload

echo "\n🦙 Installing Ollama"
curl -fsSL https://ollama.com/install.sh | sh
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null <<'EOF'
[Service]
Environment="OLLAMA_HOST=127.0.0.1:11434"
Environment="OLLAMA_KEEP_ALIVE=1h"
Environment="OLLAMA_NUM_PARALLEL=2"
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="HSA_OVERRIDE_GFX_VERSION=11.5.1"
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now ollama
sudo systemctl restart ollama

echo "\n💻 Installing OpenCode"
curl -fsSL https://opencode.ai/install | bash
export PATH="$HOME/.local/bin:$PATH"
grep -q 'opencode' ~/.bashrc 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

echo "\n😴 Setting up auto-suspend (30 min idle)"
sudo tee /etc/systemd/system/auto-suspend.service > /dev/null <<'EOF'
[Unit]
Description=Suspend if no active sessions or connections

[Service]
Type=oneshot
ExecCondition=/usr/bin/bash -c '! (who | grep -q pts/ || ss -tn state established "( sport = :2024 )" | grep -q ESTAB || journalctl -u ollama --since "30 min ago" --no-pager -q | grep -q "request completed")'
ExecStart=/usr/bin/systemctl suspend
EOF

sudo tee /etc/systemd/system/auto-suspend.timer > /dev/null <<'EOF'
[Unit]
Description=Check for idle every 30 min

[Timer]
OnBootSec=30min
OnUnitActiveSec=30min

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now auto-suspend.timer

echo "\n✅ Server ready."
echo "   1. Copy your SSH key:  ssh-copy-id $(whoami)@$(hostname -I | awk '{print $1}')"
echo "   2. Pull a model:       ollama pull <model>"
echo "   3. Test suspend check: sudo systemctl start auto-suspend.service"

