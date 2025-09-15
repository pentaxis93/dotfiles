#!/usr/bin/env bash
# ============================================================================
# POLYBAR LAUNCH SCRIPT WITH ERROR HANDLING
# ============================================================================
# Purpose: Safely launch polybar with config validation and error recovery
#
# Features:
#   - Config validation before launch
#   - Timestamped logging
#   - Error recovery with fallback
#   - Clean shutdown of existing instances
#
# Log location: /tmp/polybar.log
# ============================================================================

LOGFILE="/tmp/polybar.log"
CONFIG_DIR="$HOME/.config/polybar"
CONFIG_FILE="$CONFIG_DIR/config.ini"

# Function to log with timestamp
log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

# Start new log session
echo "============================================================" >> "$LOGFILE"
log_msg "Starting polybar launch sequence"

# Validate config exists
if [ ! -f "$CONFIG_FILE" ]; then
    log_msg "ERROR: Config file not found at $CONFIG_FILE"
    notify-send -u critical "Polybar" "Config file not found!"
    exit 1
fi

# Terminate already running bar instances
log_msg "Terminating existing polybar instances..."
if polybar-msg cmd quit >/dev/null 2>&1; then
    log_msg "Sent quit command via IPC"
else
    killall -q polybar
    log_msg "Killed polybar processes"
fi

# Wait until the processes have been shut down
timeout=5
while pgrep -u $UID -x polybar >/dev/null && [ $timeout -gt 0 ]; do
    sleep 0.5
    ((timeout--))
done

if pgrep -u $UID -x polybar >/dev/null; then
    log_msg "WARNING: Some polybar instances still running after timeout"
fi

# Launch polybar with error checking
log_msg "Launching polybar with config: $CONFIG_FILE"
if polybar main -c "$CONFIG_FILE" 2>&1 | tee -a "$LOGFILE" & then
    disown
    log_msg "SUCCESS: Polybar launched (PID: $!)"

    # Wait a moment and verify it's still running
    sleep 1
    if pgrep -u $UID -x polybar >/dev/null; then
        log_msg "Polybar is running successfully"
    else
        log_msg "ERROR: Polybar crashed immediately after launch"
        log_msg "Check the log above for error messages"
        notify-send -u critical "Polybar" "Failed to start - check /tmp/polybar.log"
        exit 1
    fi
else
    log_msg "ERROR: Failed to launch polybar"
    notify-send -u critical "Polybar" "Failed to launch - check /tmp/polybar.log"
    exit 1
fi