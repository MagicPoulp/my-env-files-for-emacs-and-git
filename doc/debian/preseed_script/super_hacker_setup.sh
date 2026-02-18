#!/bin/sh
# Thierry Vilmart
#
# Super hacker setup
# sets up the firewall, isolcpus, interrupts pinning

set -e

# --------------------------------------------------------
# Set time zone

timedatectl set-timezone Europe/Paris

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

echo "--> NumLock is configured via system-wide database."

# --------------------------------------------------------
# Setup firewall

# 1. Define the nftables configuration path
NFT_CONF="/etc/nftables.conf"
SYSCTL_CONF="/etc/sysctl.d/99-ipforward.conf"

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
echo "net.ipv4.ip_forward=1" > "$SYSCTL_CONF"
sysctl -p "$SYSCTL_CONF"

# 4. Set permissions and apply
chmod 750 "$NFT_CONF"
nft -f "$NFT_CONF"

# 5. Ensure nftables starts on boot
systemctl enable nftables

echo "--> The firewall is configured for Desktop use and to allow a VM."

# --------------------------------------------------------
# Update the Kernel for isolcpus and for using VMs

NEW_CONF="quiet isolcpus=4-19 nohz_full=4-19 rcu_nocbs=4-19 intel_iommu=on audit=0"
sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$NEW_CONF\"|" /etc/default/grub
echo "--> grub is configured to use isolcpus for using VMs."

# --------------------------------------------------------
# make a pinning file for interrups

cat <<'EOF' > pin_irq.sh
#!/bin/sh

# see in /proc/interrupts
USB_IRQ=$(grep xhci_hcd /proc/interrupts | awk '{print $1}' | tr -d ':' | tr '\n' ' ')

# Target mask for CPU 5 (0x20 = 2^5)
#TARGET_MASK="20"
# Target mask for CPU 19
TARGET_MASK="80000"

# Assign i8042 (Keyboard) to CPU
echo $TARGET_MASK | sudo tee /proc/irq/1/smp_affinity > /dev/null

# Assign i8042 (Mouse/PS2) to CPU
echo $TARGET_MASK | sudo tee /proc/irq/12/smp_affinity > /dev/null

for NUMBER1 in $USB_IRQ; do
    # Assign xhci_hcd (USB Host Controller - Primary) to CPU
    echo $TARGET_MASK | sudo tee /proc/irq/$NUMBER1/smp_affinity > /dev/null
done

EXCLUDE="$USB_IRQ 1 12"

# Define the CPU core range for the Host (CPUs 0, 1, 2, 3)
HOST_CPU_MASK="F"

echo ${HOST_CPU_MASK} > /proc/irq/default_smp_affinity

echo "Starting IRQ affinity reset to Host Cores (0-3, mask $HOST_CPU_MASK)..."

for irq_dir in /proc/irq/[0-9]*; do
    IRQ_NUMBER=$(basename "$irq_dir")
    IRQ_NUMBER=$(echo "$IRQ_NUMBER" | tr -d '[:space:]')
    if ! echo " $EXCLUDE " | grep -q " $IRQ_NUMBER "; then
        AFFINITY_FILE="$irq_dir/smp_affinity"
        if [ -f "$AFFINITY_FILE" ]; then
            CURRENT_AFFINITY=$(cat "$AFFINITY_FILE")
            if [ "$CURRENT_AFFINITY" != "$HOST_CPU_MASK" ]; then
                echo "$HOST_CPU_MASK" | sudo tee "$AFFINITY_FILE" > /dev/null
                echo "   [SET] IRQ $IRQ_NUMBER: $CURRENT_AFFINITY -> $HOST_CPU_MASK"
            fi
        fi
    else
        echo "exclude $IRQ_NUMBER"
    fi
done

echo "IRQ affinity reset complete."
EOF

chmod +x pin_irq.sh
apt update
apt-get install -y qemu-system libvirt-daemon-system libvirt-clients virtinst bridge-utils

# install the pinning file for when the network changes and when a VM starts
cp pin_irq.sh /etc/NetworkManager/dispatcher.d/99-irq-repin
mkdir -p /etc/libvirt/hooks/qemu.d/win11/prepare/begin
mkdir -p /etc/libvirt/hooks/qemu.d/win11/release/end
cp irq-pin.sh /etc/libvirt/hooks/qemu.d/win11/release/begin

echo "IRQ pinning is set in NetworkManager's dispatcher and in kvm"

# --------------------------------------------------------

echo "IMPORTANT: you must run: sudo update-grub"
echo "IMPORTANT: you must run: sudo reboot"
