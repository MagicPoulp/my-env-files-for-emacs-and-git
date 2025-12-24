#!/bin/sh

echo F | sudo tee /proc/irq/default_smp_affinity

echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

nmcli radio wifi off
sudo rfkill block wifi

# This command applies the hugepage setting immediately
sudo sh -c 'echo 8192 > /proc/sys/vm/nr_hugepages'
#!/bin/bash
