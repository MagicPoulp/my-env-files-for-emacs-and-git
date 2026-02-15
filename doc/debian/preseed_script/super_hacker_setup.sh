#!/bin/sh

set -e

# --------------------------------------------------------
# Setup Num lock (System-wide Override)

# 1. Hardware Level (udev)
echo 'ACTION=="add", SUBSYSTEM=="input", DERIVE_SETLEDS="1", RUN+="/usr/bin/setleds -D +num"' > /etc/udev/rules.d/99-numlock.rules

# 2. GNOME Level (Direct File Writing)
# Create the necessary directories
mkdir -p /etc/dconf/db/local.d/
mkdir -p /etc/dconf/profile/

# Ensure the dconf profile exists so GNOME knows to look at our local settings
if [ ! -f /etc/dconf/profile/user ]; then
    cat <<EOF > /etc/dconf/profile/user
user-db:user
system-db:local
EOF
fi

# Create the setting file
cat <<EOF > /etc/dconf/db/local.d/00-numlock
[org/gnome/desktop/peripherals/keyboard]
numlock-state=true
remember-numlock-state=true
EOF

# Apply the changes to the system database (This is the persistent way)
dconf update

echo "NumLock configured via system-wide database."

# --------------------------------------------------------
# Setup firewall

# 1. Define the nftables configuration path
NFT_CONF="/etc/nftables.conf"
SYSCTL_CONF="/etc/sysctl.d/99-ipforward.conf"

echo "Configuring hardened workstation firewall..."

# 2. Write the nftables configuration
cat <<EOF > "$NFT_CONF"
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Allow traffic from established/related connections
        ct state established,related accept

        # Allow loopback (local apps)
        iif "lo" accept

        # Drop invalid packets
        ct state invalid drop

        # NOTE: SSH, HTTP, and Ping (ICMP) are implicitly dropped
    }

    chain forward {
        type filter hook forward priority 0; policy drop;

        # Allow VM/Container traffic to reach the internet
        ct state established,related accept

        # Change "virbr*" to your specific bridge if different
        iifname "virbr*" accept
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF

# 3. Enable IP Forwarding in the Kernel (required for VM Internet)
echo "Enabling IP Forwarding..."
echo "net.ipv4.ip_forward=1" > "$SYSCTL_CONF"
sysctl -p "$SYSCTL_CONF"

# 4. Set permissions and apply
chmod 750 "$NFT_CONF"
nft -f "$NFT_CONF"

# 5. Ensure nftables starts on boot
systemctl enable nftables

echo "SUCCES: The firwall is configured for Desktop use and to allow a VM."
