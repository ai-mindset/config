#!/usr/bin/env zsh
set -euo pipefail

echo "=== Server Setup ==="
read "HOSTNAME?Hostname: "
read "WIFI_SSID?WiFi SSID: "
read -s "WIFI_PASS?WiFi password: "; echo
read "STATIC_IP?Static IP (e.g. 192.168.1.100/24): "
read "GATEWAY?Gateway (e.g. 192.168.1.1): "

sudo hostnamectl set-hostname "$HOSTNAME"

nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASS" name "server-wifi"
nmcli connection modify "server-wifi" \
    ipv4.method manual \
    ipv4.addresses "$STATIC_IP" \
    ipv4.gateway "$GATEWAY" \
    ipv4.dns "9.9.9.9;149.112.112.112" \
    ipv6.method disabled \
    connection.autoconnect yes
nmcli connection up "server-wifi"

if [[ ! -f ~/.ssh/authorized_keys ]] || [[ ! -s ~/.ssh/authorized_keys ]]; then
    echo "\n⚠️  No SSH keys found. Paste your public key (from laptop: cat ~/.ssh/id_server.pub):"
    read "PUBKEY?Public key: "
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    echo "$PUBKEY" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    echo "✅ SSH key added"
else
    echo "✅ SSH authorized_keys already exists, skipping"
fi

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

sudo dnf install -y firewalld
sudo systemctl enable --now firewalld
sudo firewall-cmd --set-default-zone=drop
sudo firewall-cmd --permanent --zone=drop --add-service=ssh
sudo firewall-cmd --reload

curl -fsSL https://ollama.com/install.sh | sh
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null <<'EOF'
[Service]
Environment="OLLAMA_HOST=127.0.0.1:11434"
Environment="OLLAMA_KEEP_ALIVE=24h"
Environment="OLLAMA_NUM_PARALLEL=2"
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="HSA_OVERRIDE_GFX_VERSION=11.5.1"
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now ollama

curl -fsSL https://opencode.ai/install | bash
export PATH="$HOME/.local/bin:$PATH"
grep -q 'opencode' ~/.zshrc 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

echo "\n✅ Server ready."
echo "From your laptop, test: ssh server"
echo "Then: ollama pull <model>"
