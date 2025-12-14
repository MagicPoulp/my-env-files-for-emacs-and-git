#!/bin/bash

# Ensure this script is executable: chmod +x start_win11.sh

VM_NAME="win11"
PRIORITY=1

# 1. Start the VM
echo "Starting Domain '$VM_NAME'..."
sudo virsh start "$VM_NAME"
if [ $? -ne 0 ]; then
    echo "Error: Failed to start VM. Exiting."
    exit 1
fi

# 2. Wait for the QEMU process to start and get its PID
echo "Waiting for QEMU process for $VM_NAME..."
PID=""
while [ -z "$PID" ]; do
    # Search for the QEMU process whose command line contains the VM name
    PID=$(pgrep -f "qemu-system-x86_64.*$VM_NAME")
    sleep 1
done
echo "QEMU process found. PID: $PID"

# 3. Use 'chrt' to set Real-Time priority (Round Robin, P=1)
# -r = Real-Time Policy (Round Robin, which is the safer POSIX default)
# -p = Apply to a specific PID
sudo chrt -r -p "$PRIORITY" "$PID"
if [ $? -eq 0 ]; then
    echo "Real-time priority (RR, P=$PRIORITY) set successfully for QEMU process (PID $PID)."
else
    echo "WARNING: Failed to set real-time priority using chrt. Running without guaranteed priority."
fi

# 4. Wait for Windows to boot and launch Looking Glass
echo "Waiting 20 seconds for Windows boot..."
sleep 20
#echo "looking-glass-client win:size=1920x1080 win:fullScreen -s -f /dev/shm/looking-glass"

