#!/usr/bin/env zsh
set -euo pipefail

if (( EUID == 0 )); then
    print -u2 "Run this script as the non-root administrator who will use SSH."
    exit 1
fi

for command in nmcli sudo; do
    if ! command -v "$command" > /dev/null 2>&1; then
        print -u2 "Required command not found: $command"
        exit 1
    fi
done

is_ipv4_cidr() {
    local cidr="$1"
    local address prefix
    local -a octets

    [[ "$cidr" == */* ]] || return 1
    address="${cidr%/*}"
    prefix="${cidr##*/}"
    [[ "$prefix" == <-> ]] || return 1
    (( prefix == 32 )) || return 1

    octets=("${(@s:.:)address}")
    (( ${#octets} == 4 )) || return 1
    for octet in "${octets[@]}"; do
        [[ "$octet" == <-> ]] || return 1
        (( octet >= 0 && octet <= 255 )) || return 1
    done
}

echo "=== Server Setup ==="
read "SERVER_HOSTNAME?Hostname: "
read "WIFI_SSID?WiFi SSID: "
read "ADMIN_PUBLIC_KEY?Paste the admin client's Ed25519 public key: "
read "ADMIN_CLIENT_CIDR?Admin client's reserved IPv4 address (for example 192.168.1.42/32): "

if [[ ! "$SERVER_HOSTNAME" =~ '^[a-zA-Z0-9][a-zA-Z0-9.-]{0,252}$' ]]; then
    print -u2 "Invalid hostname."
    exit 1
fi

case "$ADMIN_PUBLIC_KEY" in
    'ssh-ed25519 '*|'sk-ssh-ed25519@openssh.com '*) ;;
    *)
        print -u2 "Use an Ed25519 public key (ssh-ed25519 or sk-ssh-ed25519@openssh.com)."
        exit 1
        ;;
esac

if ! is_ipv4_cidr "$ADMIN_CLIENT_CIDR"; then
    print -u2 "Invalid IPv4 CIDR. Reserve the admin client's address and enter it as a /32."
    exit 1
fi

ADMIN_USER="$(id -un)"
ADMIN_HOME="$HOME"
SSH_DROP_IN="/etc/ssh/sshd_config.d/00-synthesis-hardening.conf"

sudo -v
sudo hostnamectl set-hostname "$SERVER_HOSTNAME"

echo "\n🔎 Force console to 1080p"
sudo grubby --update-kernel=ALL --args="video=1920x1080"

echo "\n📡 Configuring WiFi for DHCP with a permanent MAC address"
if nmcli -t -f NAME connection show | grep -Fqx -- "server-wifi"; then
    nmcli connection modify "server-wifi" 802-11-wireless.ssid "$WIFI_SSID"
else
    echo "NetworkManager will securely prompt for the WiFi password."
    nmcli --ask device wifi connect "$WIFI_SSID" name "server-wifi"
fi
nmcli connection modify "server-wifi" \
    802-11-wireless.cloned-mac-address permanent \
    ipv4.method auto \
    ipv4.addresses "" \
    ipv4.gateway "" \
    ipv4.routes "" \
    ipv4.ignore-auto-routes no \
    ipv4.never-default no \
    ipv4.ignore-auto-dns no \
    ipv4.dns "" \
    ipv6.method auto \
    connection.autoconnect yes \
    connection.zone drop
nmcli connection up "server-wifi"

WIFI_DEVICE="$(nmcli -g GENERAL.DEVICES connection show "server-wifi" | head -n 1)"
SERVER_MAC="$(nmcli -g GENERAL.HWADDR device show "$WIFI_DEVICE")"
SERVER_ADDRESS="$(ip -4 -o address show dev "$WIFI_DEVICE" scope global | awk 'NR == 1 {print $4}')"
if [[ -z "$WIFI_DEVICE" || -z "$SERVER_MAC" || -z "$SERVER_ADDRESS" ]]; then
    print -u2 "Could not determine the active WiFi device, permanent MAC, or DHCP address."
    exit 1
fi

echo "\n🔒 Installing and hardening SSH"
sudo dnf install -y openssh-clients openssh-server firewalld

PUBLIC_KEY_TEMP="$(mktemp)"
SSH_CONFIG_TEMP="$(mktemp)"
SSH_CONFIG_BACKUP="$(mktemp)"
SSH_CONFIG_EXISTED=no
trap 'rm -f "$PUBLIC_KEY_TEMP" "$SSH_CONFIG_TEMP" "$SSH_CONFIG_BACKUP"' EXIT
print -r -- "$ADMIN_PUBLIC_KEY" > "$PUBLIC_KEY_TEMP"
if ! ssh-keygen -l -f "$PUBLIC_KEY_TEMP" > /dev/null; then
    print -u2 "The admin public key is not a valid OpenSSH key."
    exit 1
fi

echo "\n🔑 Installing the validated admin public key before passwords are disabled"
install -d -m 700 "$ADMIN_HOME/.ssh"
touch "$ADMIN_HOME/.ssh/authorized_keys"
chmod 600 "$ADMIN_HOME/.ssh/authorized_keys"
if ! grep -Fqx -- "$ADMIN_PUBLIC_KEY" "$ADMIN_HOME/.ssh/authorized_keys"; then
    print -r -- "$ADMIN_PUBLIC_KEY" >> "$ADMIN_HOME/.ssh/authorized_keys"
fi

cat > "$SSH_CONFIG_TEMP" <<EOF
AddressFamily inet
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
AuthenticationMethods publickey
PermitEmptyPasswords no
AllowUsers $ADMIN_USER
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 2
LogLevel VERBOSE
X11Forwarding no
AllowAgentForwarding no
AllowTcpForwarding local
AllowStreamLocalForwarding no
PermitOpen 127.0.0.1:11434 127.0.0.1:8000
GatewayPorts no
PermitTunnel no
PermitUserEnvironment no
ClientAliveInterval 60
ClientAliveCountMax 3
EOF

sudo ssh-keygen -A
sudo /usr/sbin/sshd -t -f "$SSH_CONFIG_TEMP"
if sudo test -f "$SSH_DROP_IN"; then
    sudo cat "$SSH_DROP_IN" > "$SSH_CONFIG_BACKUP"
    SSH_CONFIG_EXISTED=yes
fi

restore_ssh_drop_in() {
    if [[ "$SSH_CONFIG_EXISTED" == yes ]]; then
        sudo install -o root -g root -m 600 "$SSH_CONFIG_BACKUP" "$SSH_DROP_IN"
    else
        sudo rm -f -- "$SSH_DROP_IN"
    fi
}

sudo install -o root -g root -m 600 "$SSH_CONFIG_TEMP" "$SSH_DROP_IN"
if ! sudo /usr/sbin/sshd -t; then
    restore_ssh_drop_in
    print -u2 "SSH syntax validation failed; the previous configuration was restored."
    exit 1
fi

SSHD_CONNECTION="user=$ADMIN_USER,host=$SERVER_HOSTNAME,addr=${ADMIN_CLIENT_CIDR%/*}"
SSHD_EFFECTIVE="$(sudo /usr/sbin/sshd -T -C "$SSHD_CONNECTION")"
for expected in \
    "addressfamily inet" \
    "permitrootlogin no" \
    "pubkeyauthentication yes" \
    "passwordauthentication no" \
    "kbdinteractiveauthentication no" \
    "authenticationmethods publickey" \
    "allowusers $ADMIN_USER" \
    "x11forwarding no" \
    "allowagentforwarding no" \
    "allowtcpforwarding local" \
    "allowstreamlocalforwarding no" \
    "permitopen 127.0.0.1:11434" \
    "gatewayports no" \
    "permittunnel no" \
    "permituserenvironment no"; do
    if ! grep -Fqx -- "$expected" <<< "$SSHD_EFFECTIVE"; then
        restore_ssh_drop_in
        print -u2 "Effective SSH configuration check failed: expected '$expected'."
        print -u2 "The previous SSH configuration was restored."
        exit 1
    fi
done

sudo systemctl enable --now sshd
sudo systemctl reload sshd

echo "\n🧱 Configuring the firewall to accept SSH only from the admin client"
sudo systemctl enable --now firewalld
sudo firewall-cmd --set-default-zone=drop
if sudo firewall-cmd --permanent --zone=drop --query-service=ssh > /dev/null; then
    sudo firewall-cmd --permanent --zone=drop --remove-service=ssh
fi
sudo firewall-cmd --permanent --zone=drop \
    --add-rich-rule="rule family=\"ipv4\" source address=\"$ADMIN_CLIENT_CIDR\" service name=\"ssh\" accept"
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

if sudo systemctl list-unit-files auto-suspend.timer --no-legend 2>/dev/null |
    grep -q '^auto-suspend.timer'; then
    echo "\n😴 Disabling the legacy auto-suspend timer"
    sudo systemctl disable --now auto-suspend.timer
fi

echo "\n✅ Server ready. Auto-suspend is disabled; verify Wake-on-LAN before enabling it."
echo "   Server address now:       $SERVER_ADDRESS"
echo "   Permanent WiFi MAC:       $SERVER_MAC"
echo "   Reserve the server address for this MAC in the router."
echo "   Keep the admin client's $ADMIN_CLIENT_CIDR address reserved too."
echo "   Verify the host key here: sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub"
echo "   Connect from the admin client: ssh $ADMIN_USER@${SERVER_ADDRESS%/*}"
echo "   Tunnel Ollama and Strands:     ssh -N -T -o ExitOnForwardFailure=yes -L 127.0.0.1:11434:127.0.0.1:11434 -L 127.0.0.1:8000:127.0.0.1:8000 $ADMIN_USER@${SERVER_ADDRESS%/*}"

