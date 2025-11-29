#!/bin/sh

# Set CPU affinity to '1' (which is the bitmask for CPU 0)
# The IRQ numbers are: 183 to 189

# Loop through the IRQs and set their affinity to CPU 0
for irq in 183 184 185 186 187 188 189; do
    if [ -f "/proc/irq/$irq/smp_affinity" ]; then
        echo F > /proc/irq/$irq/smp_affinity
    fi
done

echo F | sudo tee /proc/irq/default_smp_affinity

echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

nmcli radio wifi off
sudo rfkill block wifi

# This command applies the hugepage setting immediately
sudo sh -c 'echo 13312 > /proc/sys/vm/nr_hugepages'
#!/bin/bash

# Define the CPU core range for the Host (CPUs 0, 1, 2, 3)
# The binary mask for 0, 1, 2, 3 is 0000 1111, which is Hexadecimal 'F'.
HOST_CPU_MASK="F"

echo "Starting IRQ affinity reset to Host Cores (0-3, mask $HOST_CPU_MASK)..."

# Find all directories that start with a number under /proc/irq/
# These represent the dynamic IRQ lines.
for irq_dir in /proc/irq/[0-9]*; do
    # Extract the IRQ number
    IRQ_NUMBER=$(basename "$irq_dir")
    
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
done

echo "IRQ affinity reset complete."
