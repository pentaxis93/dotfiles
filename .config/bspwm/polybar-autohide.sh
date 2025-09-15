#!/bin/bash
# ============================================================================
# POLYBAR AUTO-HIDE DAEMON FOR BSPWM
# ============================================================================
# Purpose:
#   Automatically hides polybar when video players (mpv, vlc, etc.) are
#   focused in monocle mode, providing an immersive viewing experience.
#   Acts as a lightweight daemon that monitors BSPWM events.
#
# Architecture:
#   - Event-driven: Subscribes to bspwm's node_focus, desktop_layout, and desktop_focus events
#   - Self-healing: Automatically restarts if bspc subscribe disconnects
#   - Single instance: PID file ensures only one daemon runs
#
# How It Works:
#   1. Monitors BSPWM events via 'bspc subscribe'
#   2. On focus change or layout change, checks:
#      - Is the layout monocle?
#      - Is the focused window a video player?
#   3. Hides polybar if both conditions are true, shows otherwise
#
# Configuration:
#   Supported video players (line ~54): mpv, vlc, mplayer, smplayer, celluloid, haruna
#   Add more players to the regex pattern as needed
#
# Dependencies:
#   - bspwm: Window manager that provides events
#   - polybar: Status bar with IPC support (enable-ipc = true)
#   - xprop: To identify window classes
#
# Installation:
#   1. Place in ~/.config/bspwm/polybar-autohide.sh
#   2. Make executable: chmod +x polybar-autohide.sh
#   3. Add to bspwmrc: nohup ~/.config/bspwm/polybar-autohide.sh &
#
# Debugging:
#   - Check if running: pgrep -f polybar-autohide.sh
#   - View logs: tail -f /tmp/polybar-autohide.log
#   - Manual restart: pkill -f polybar-autohide.sh && nohup ~/.config/bspwm/polybar-autohide.sh &
#
# Related Files:
#   ~/.config/bspwm/bspwmrc - Launches this daemon on startup
#   ~/.config/sxhkd/sxhkdrc - Contains Super+B for manual polybar toggle
#   ~/.config/polybar/config.ini - Must have enable-ipc = true
#
# Author: System configuration for pentaxis93
# Date: September 2024
# ============================================================================

# Configuration
LOG_FILE="/tmp/polybar-autohide.log"   # Debug log location
PIDFILE="/tmp/polybar-autohide.pid"     # PID file to prevent multiple instances

# Function to log messages
log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Clean up on exit
cleanup() {
    log_msg "Script exiting..."
    rm -f "$PIDFILE"
    exit 0
}

trap cleanup EXIT SIGINT SIGTERM

# Function to check if polybar should be hidden
should_hide_polybar() {
    # Get current desktop layout
    layout=$(bspc query -T -d focused 2>/dev/null | grep -o '"layout":"[^"]*"' | cut -d'"' -f4)

    # Get focused window ID
    focused_id=$(bspc query -N -n focused 2>/dev/null)
    if [ -z "$focused_id" ]; then
        echo "false"
        return
    fi

    # Get window class - check both instance and class name
    win_info=$(xprop -id "$focused_id" WM_CLASS 2>/dev/null)
    if [ -z "$win_info" ]; then
        echo "false"
        return
    fi

    # Extract class name (second quoted string) and convert to lowercase
    win_class=$(echo "$win_info" | sed -n 's/.*= "\(.*\)", "\(.*\)"/\2/p' | tr '[:upper:]' '[:lower:]')

    # Log current state for debugging
    log_msg "Layout: $layout, Focused: $focused_id, Class: $win_class"

    # Hide polybar if:
    # 1. Layout is monocle AND
    # 2. Focused window is a video player
    # To add more video players, add them to this regex pattern (e.g., |kodi|plex)
    if [ "$layout" = "monocle" ] && [[ "$win_class" =~ ^(mpv|vlc|mplayer|smplayer|celluloid|haruna)$ ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Function to update polybar visibility
update_polybar() {
    local should_hide=$(should_hide_polybar)

    if [ "$should_hide" = "true" ]; then
        # Hide polybar
        if polybar-msg cmd hide >/dev/null 2>&1; then
            log_msg "Polybar hidden"
        else
            log_msg "Failed to hide polybar"
        fi
    else
        # Show polybar
        if polybar-msg cmd show >/dev/null 2>&1; then
            log_msg "Polybar shown"
        else
            log_msg "Failed to show polybar"
        fi
    fi
}

# Main loop with restart logic
main_loop() {
    log_msg "Starting main event loop..."

    # Initial check
    update_polybar

    # Monitor bspwm events with automatic restart
    while true; do
        log_msg "Subscribing to bspwm events..."

        # Subscribe to events and process them
        bspc subscribe node_focus desktop_layout desktop_focus 2>/dev/null | while read -r event; do
            # Log the event
            log_msg "Event received: $event"

            # Update polybar visibility
            update_polybar
        done

        # If we get here, bspc subscribe died
        log_msg "bspc subscribe died, restarting in 1 second..."
        sleep 1
    done
}

# Start logging
log_msg "=== Polybar auto-hide script started ==="
log_msg "PID: $$"

# Check if another instance is running
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        log_msg "Another instance is already running (PID: $OLD_PID), exiting..."
        exit 1
    else
        log_msg "Removing stale PID file"
        rm -f "$PIDFILE"
    fi
fi

# Write our PID file after checking for existing instances
echo $$ > "$PIDFILE"

# Run the main loop
main_loop