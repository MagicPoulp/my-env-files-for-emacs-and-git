#!/bin/sh

# this is set in a NetworkManager dispatcher and in lib virt startup script
# /etc/NetworkManager/dispatcher.d/99-irq-repin
# /etc/libvirt/hooks/qemu.d/win11/prepare/begin/

# the 0,1,2,3 are for kernel

# CPU 4 is for keyboard and mouse

# CPU 5 is for disk IO thread 1

# CPU 6, 7 are for emulator

# CPU 8-15 are for windows

# optional: CPU 19 can be for a new audio IO thread for the scream audio via UDP unicast

# see in /proc/interrupts
USB_IRQ=$(grep xhci_hcd /proc/interrupts | awk '{print $1}' | tr -d ':' | tr '\n' ' ')

# Target mask for CPU 4
TARGET_MASK="10"

# interrupts 1 and 12 are for keyboard and mouse and isolated
# Assign i8042 (Keyboard)
echo $TARGET_MASK | sudo tee /proc/irq/1/smp_affinity > /dev/null

# Assign i8042 (Mouse/PS2)
echo $TARGET_MASK | sudo tee /proc/irq/12/smp_affinity > /dev/null

for NUMBER1 in $USB_IRQ; do
    # Assign xhci_hcd (USB Host Controller - Primary)
    echo $TARGET_MASK | sudo tee /proc/irq/$NUMBER1/smp_affinity > /dev/null
done

EXCLUDE="$USB_IRQ 1 12"

echo F | sudo tee /proc/irq/default_smp_affinity

# Define the CPU core range for the Host (CPUs 0, 1, 2, 3)
# The binary mask for 0, 1, 2, 3 is 0000 1111, which is Hexadecimal 'F'.
HOST_CPU_MASK="F"

echo "Starting IRQ affinity reset to Host Cores (0-3, mask $HOST_CPU_MASK)..."

# Find all directories that start with a number under /proc/irq/
# These represent the dynamic IRQ lines.
for irq_dir in /proc/irq/[0-9]*; do
    # Extract the IRQ number
    IRQ_NUMBER=$(basename "$irq_dir")
    IRQ_NUMBER=$(echo "$IRQ_NUMBER" | tr -d '[:space:]')
    if ! echo " $EXCLUDE " | grep -q " $IRQ_NUMBER "; then
        # Check if the smp_affinity file exists for this IRQ
        AFFINITY_FILE="$irq_dir/smp_affinity"
        if [ -f "$AFFINITY_FILE" ]; then
            # Read the current affinity for comparison (optional, but helpful)
            CURRENT_AFFINITY=$(cat "$AFFINITY_FILE")
            # Check if the IRQ is NOT already set to the desired mask
            if [ "$CURRENT_AFFINITY" != "$HOST_CPU_MASK" ]; then
                # Write the new CPU mask to the affinity file
                echo "$HOST_CPU_MASK" > "$AFFINITY_FILE"
                echo "   [SET] IRQ $IRQ_NUMBER: $CURRENT_AFFINITY -> $HOST_CPU_MASK"
                # else: IRQ is already set to 'F', so skip.
                # else
                #    echo "   [SKIP] IRQ $IRQ_NUMBER: Already set to $HOST_CPU_MASK"
            fi
        fi
    else
        echo "exclude $IRQ_NUMBER"
    fi
done

echo "IRQ affinity reset complete."
