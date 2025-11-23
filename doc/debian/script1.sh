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
