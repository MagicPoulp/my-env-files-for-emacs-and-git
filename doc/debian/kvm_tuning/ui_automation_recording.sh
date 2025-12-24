#!/bin/bash

export XDG_RUNTIME_DIR=/tmp/wayland-run
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# 1. Force Headless and No Input
export WLR_BACKENDS=headless
export WLR_LIBINPUT_NO_DEVICES=1
export WAYLAND_DISPLAY=wayland-0

echo "Starting Compositor and Looking Glass..."
# Redirecting output to a log file prevents it from 'hanging' the terminal
cage -s -- looking-glass-client \
  win:size=1920x1080 \
  win:fullScreen=yes \
  -s \
  -f /dev/shm/looking-glass > /tmp/lg.log 2>&1 &
LG_PID=$!

sleep 5 # Give it plenty of time to reach "Starting session"

echo "Starting Recorder..."
wf-recorder -f ./qga_test_output.mp4 > /dev/null 2>&1 &
REC_PID=$!

echo "Recording started (PID: $REC_PID). Executing tests..."

# --- YOUR QGA COMMANDS HERE ---
# For now, we just wait to see if it finishes
sleep 15 
# ------------------------------

echo "Stopping recording and cleaning up..."
kill -SIGINT $REC_PID
wait $REC_PID
kill $LG_PID
wait $LG_PID 2>/dev/null

echo "Done! Check ./qga_test_output.mp4"
