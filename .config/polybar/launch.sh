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

# Kill any existing window-title daemons
# WHY: Prevents multiple daemons from running simultaneously
# ISSUE: Multiple daemons cause duplicate xprop monitors and inconsistent updates
log_msg "Terminating existing window-title daemon..."
if [ -f "/tmp/window-title-daemon.pid" ]; then
    OLD_PID=$(cat /tmp/window-title-daemon.pid)
    if kill -0 "$OLD_PID" 2>/dev/null; then
        kill "$OLD_PID"
        log_msg "Killed window-title daemon (PID: $OLD_PID)"
    fi
fi
# Also kill any orphaned window-title scripts and xprop monitors
# These can persist if daemon crashes without cleanup
pkill -f "window-title.sh" 2>/dev/null        # Old script (deprecated)
pkill -f "window-title-daemon.sh" 2>/dev/null  # Current daemon

# Launch polybar with error checking
log_msg "Launching polybar with config: $CONFIG_FILE"
if polybar main -c "$CONFIG_FILE" 2>&1 | tee -a "$LOGFILE" & then
    disown
    log_msg "SUCCESS: Polybar launched (PID: $!)"

    # Wait a moment and verify it's still running
    sleep 1
    if pgrep -u $UID -x polybar >/dev/null; then
        log_msg "Polybar is running successfully"

        # Start the window-title daemon
        # WHY: Provides real-time window title updates in polybar
        # ARCHITECTURE: Runs as separate daemon to avoid blocking polybar hide/show
        # DETAILS: Monitors both focus changes AND title property changes (tab switches)
        log_msg "Starting window-title daemon..."
        nohup "$CONFIG_DIR/scripts/window-title-daemon.sh" >/dev/null 2>&1 &
        daemon_pid=$!
        sleep 0.5  # Give daemon time to initialize

        if kill -0 $daemon_pid 2>/dev/null; then
            log_msg "Window-title daemon started (PID: $daemon_pid)"
        else
            log_msg "WARNING: Window-title daemon failed to start"
            # Not critical - polybar will still work, just without dynamic titles
        fi
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