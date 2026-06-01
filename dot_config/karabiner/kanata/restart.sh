#!/bin/bash
# Restart kanata LaunchDaemon
set -euo pipefail

PLIST="/Library/LaunchDaemons/com.kanata.plist"

echo "Stopping kanata..."
sudo launchctl bootout system/com.kanata 2>/dev/null || true
sleep 0.5

echo "Starting kanata..."
sudo launchctl bootstrap system "$PLIST"

sleep 1
if sudo launchctl print system/com.kanata &>/dev/null; then
    echo "Kanata restarted successfully."
else
    echo "Failed to start kanata. Check: tail -f /var/log/kanata.error.log"
    exit 1
fi
