#!/bin/bash
# ============================================================================
# POLYBAR WINDOW TITLE DAEMON (IPC VERSION)
# ============================================================================
# Purpose:
#   Provides intelligent, real-time window titles in polybar that update on
#   both window focus changes AND internal application state changes (like
#   switching tabs in tmux or Firefox).
#
# Architecture & Design Decisions:
#   1. DAEMON + IPC: Runs as independent daemon using polybar IPC hooks
#      WHY: Allows polybar to hide/show without killing the title monitor
#
#   2. XPROP -SPY: Uses xprop -spy to monitor WM_NAME property changes
#      WHY: Detects tab switches within apps (tmux windows, browser tabs)
#      WITHOUT THIS: Titles would only update on window focus changes
#
#   3. SMART FILTERING: Context-aware title simplification
#      WHY: Raw titles are often too long or redundant for polybar
#      EXAMPLES:
#        "tmux - tmux" → "tmux"
#        "~/dev/project: tmux - tmux" → "project"
#        "(1) WhatsApp — Mozilla Firefox" → "WhatsApp"
#        "Issue #123 · owner/repo — GitHub" → "GitHub"
#        "pentaxis93 — GitHub" → "pentaxis93" (smart fallback)
#
# Dependencies:
#   - bspwm: For focus events (bspc subscribe)
#   - xprop: For window properties and title monitoring
#   - polybar-msg: For IPC communication
#   - tmux: Must have 'set-titles on' in .tmux.conf for tab detection
#
# Related Files:
#   ~/.config/polybar/config.ini - Defines the window-title IPC module
#   ~/.config/polybar/launch.sh  - Starts this daemon on polybar launch
#   ~/.tmux.conf                  - Must have title settings enabled
#   /tmp/window-title.txt         - Stores current title for polybar to read
#   /tmp/window-title-daemon.pid - PID file for single instance
#
# Troubleshooting:
#   - Titles not updating on tmux tab switch:
#     → Check: tmux show-options -g | grep set-titles (should be "on")
#     → Fix: Add to ~/.tmux.conf: set -g set-titles on
#
#   - Multiple daemons running:
#     → Check: ps aux | grep window-title-daemon
#     → Fix: killall window-title-daemon.sh; rm /tmp/window-title-daemon.pid
#
#   - Titles stuck or not updating:
#     → Check: ps aux | grep "xprop.*spy" (should have ONE process)
#     → Debug: Set DEBUG=1 and check /tmp/window-title-daemon.log
#
# Configuration:
#   MAX_LENGTH: Maximum characters before truncation (default: 30)
#   DEBUG: Set to 1 to enable logging to /tmp/window-title-daemon.log
#
# Author: System configuration for pentaxis93
# Date: September 2024
# ============================================================================

# Configuration
MAX_LENGTH=30
PIDFILE="/tmp/window-title-daemon.pid"
LOG_FILE="/tmp/window-title-daemon.log"
DEBUG=  # Debug logging disabled (set to 1 to enable)
XPROP_SPY_PID=""  # Track the xprop spy process

# Function to log messages (optional, for debugging)
log_msg() {
    if [ -n "$DEBUG" ]; then
        echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
    fi
}

# Clean up on exit
cleanup() {
    log_msg "Window title daemon exiting..."
    # Kill any running xprop spy
    if [ -n "$XPROP_SPY_PID" ] && kill -0 "$XPROP_SPY_PID" 2>/dev/null; then
        kill "$XPROP_SPY_PID" 2>/dev/null
    fi
    rm -f "$PIDFILE"
    exit 0
}

trap cleanup EXIT SIGINT SIGTERM

# Function to get and filter window title
get_filtered_title() {
    local raw_title="$1"
    local focused_id="$2"

    # Clean up the raw title from xprop format
    title=$(echo "$raw_title" | sed -n 's/^WM_NAME(.*) = "\(.*\)"$/\1/p')

    if [ -z "$title" ]; then
        echo ""
        return
    fi

    # Filter out hex window IDs or strange patterns
    if echo "$title" | grep -qE '^[A-F0-9]{8}$'; then
        # This looks like a window ID, try to get a better title
        title=$(xprop -id "$focused_id" _NET_WM_NAME 2>/dev/null | sed -n 's/^_NET_WM_NAME(.*) = "\(.*\)"$/\1/p')
        if [ -z "$title" ]; then
            # Still no good title, use the class name as fallback
            title=$(xprop -id "$focused_id" WM_CLASS 2>/dev/null | sed -n 's/.*"\(.*\)"$/\1/p')
        fi
    fi

    # Get window class for app-specific handling
    class=$(xprop -id "$focused_id" WM_CLASS 2>/dev/null | sed -n 's/.*"\(.*\)"$/\1/p')

    # ========================================================================
    # FILTERING RULES
    # These rules transform raw window titles into concise, meaningful labels
    # Order matters! More specific rules should come before generic ones.
    # ========================================================================

    # Rule 1: Terminal-specific filtering (do this first for better tmux detection)
    # WHY: Terminal titles often contain redundant info like paths and program names
    case "$class" in
        Alacritty|kitty|xterm|urxvt|konsole|gnome-terminal)
            # Check if this is tmux
            if echo "$title" | grep -q "tmux"; then
                log_msg "Detected tmux session, raw title: $title"
                # Try to get the active tmux window name
                tmux_window=$(tmux display-message -p '#W' 2>/dev/null)
                log_msg "Tmux window name: $tmux_window"
                if [ -n "$tmux_window" ]; then
                    # Just show the window name, no prefix
                    title="$tmux_window"
                    log_msg "Using tmux window name: $title"
                else
                    # Fallback: extract what's before "- tmux"
                    title=$(echo "$title" | sed 's/ - tmux$//')
                    # Extract the meaningful part after colon if present
                    if echo "$title" | grep -q ':'; then
                        title=$(echo "$title" | sed 's/^[^:]*: *//')
                    fi
                    # If we still have "tmux" alone, keep it
                    [ "$title" = "" ] && title="tmux"
                    log_msg "Fallback tmux title: $title"
                fi
            else
                # Non-tmux terminal - extract program or directory
                # Remove path prefix if present
                title=$(echo "$title" | sed 's/^.*: //')

                # If it's a path, show only the last directory
                if [[ "$title" =~ ^(/|~) ]]; then
                    title=$(basename "$title")
                fi

                # Handle SSH sessions - keep ssh: prefix for security awareness
                if echo "$title" | grep -qE "ssh|SSH"; then
                    # Try to extract hostname
                    hostname=$(echo "$title" | sed -E 's/.*@([^ ]+).*/\1/')
                    if [ "$hostname" != "$title" ]; then
                        title="ssh: $hostname"
                    fi
                fi
            fi
            ;;
    esac

    # Rule 2: Remove redundant patterns (but not for tmux which we already handled)
    if ! echo "$title" | grep -q "^tmux:"; then
        if echo "$title" | grep -qE '^([^-:]+)[-:] *\1$'; then
            title=$(echo "$title" | sed -E 's/^([^-:]+)[-:] *.*/\1/')
        fi
    fi

    # Rule 3: Browser-specific filtering
    case "$class" in
        firefox|Firefox|chromium|Chromium|Google-chrome|Brave-browser)
            # First remove browser name suffix (handle both em dash and regular dash)
            title=$(echo "$title" | sed -E 's/ [—-] (Mozilla Firefox|Chromium|Google Chrome|Brave)$//')

            # Remove notification counts like (1), (23), etc.
            title=$(echo "$title" | sed -E 's/^\([0-9]+\) *//')

            # Handle specific web apps that reliably include their name
            # These are sites where we KNOW the name is in the title
            if echo "$title" | grep -qE "(WhatsApp|Gmail|Slack|Discord|Twitter|X\.com|Reddit|LinkedIn|Spotify|YouTube|Claude|Anthropic|ChatGPT)"; then
                # Show simplified app names for known web apps
                if echo "$title" | grep -q "WhatsApp"; then
                    title="WhatsApp"
                elif echo "$title" | grep -q "Gmail"; then
                    title="Gmail"
                elif echo "$title" | grep -q "Slack"; then
                    title="Slack"
                elif echo "$title" | grep -q "Discord"; then
                    title="Discord"
                elif echo "$title" | grep -qE "Twitter|X\.com"; then
                    title="X"
                elif echo "$title" | grep -q "Reddit"; then
                    title="Reddit"
                elif echo "$title" | grep -q "LinkedIn"; then
                    title="LinkedIn"
                elif echo "$title" | grep -q "Spotify"; then
                    title="Spotify"
                elif echo "$title" | grep -q "YouTube"; then
                    # For YouTube, show just the video title
                    title=$(echo "$title" | sed 's/ - YouTube$//')
                    # If it's still too long, truncate with YT: prefix
                    if [ ${#title} -gt $MAX_LENGTH ]; then
                        title="YT: ${title:0:$((MAX_LENGTH-6))}..."
                    fi
                elif echo "$title" | grep -qE "Claude|Anthropic"; then
                    title="Claude"
                elif echo "$title" | grep -q "ChatGPT"; then
                    title="ChatGPT"
                elif echo "$title" | grep -q "GitHub"; then
                    # Only show "GitHub" if GitHub is actually in the title
                    title="GitHub"
                fi
            # For all other pages, just clean up and show the actual page title
            else
                # This is the smart fallback - show what the page says it is
                # Remove any trailing site names if present
                title=$(echo "$title" | sed -E 's/ [—-] [^—-]+$//')
                # Trim whitespace
                title=$(echo "$title" | xargs)
            fi
            ;;
    esac

    # Rule 4: Remove file paths from editor titles
    case "$class" in
        Code|code-oss|sublime_text|Sublime_text|Atom|emacs|Emacs)
            # Extract just the filename
            title=$(echo "$title" | sed -E 's|.*/([^/]+)|\1|')
            # Remove project indicators
            title=$(echo "$title" | sed -E 's/ \[.*\]$//')
            ;;
    esac

    # Rule 5: Media player simplification
    case "$class" in
        mpv|vlc|VLC|mplayer|smplayer)
            # Extract just the filename
            title=$(basename "$title" 2>/dev/null || echo "$title")
            # Remove common file extensions
            title=$(echo "$title" | sed -E 's/\.(mp4|mkv|avi|mp3|flac|ogg|webm|mov)$//')
            ;;
    esac

    # ========================================================================
    # TRUNCATION
    # ========================================================================

    # Truncate if still too long
    if [ ${#title} -gt $MAX_LENGTH ]; then
        title="${title:0:$((MAX_LENGTH-3))}..."
    fi

    echo "$title"
}

# Function to update polybar via IPC
update_polybar_title() {
    local title="$1"

    # Write title to a temp file for polybar to read
    echo "$title" > /tmp/window-title.txt

    # Trigger hook-0 on the window-title module to make it re-read the file
    polybar-msg action window-title hook 0 >/dev/null 2>&1

    log_msg "Updated title: $title"
}

# Function to start monitoring a window for title changes
monitor_window() {
    local window_id="$1"

    # Kill existing xprop spy if running
    if [ -n "$XPROP_SPY_PID" ] && kill -0 "$XPROP_SPY_PID" 2>/dev/null; then
        kill "$XPROP_SPY_PID" 2>/dev/null
        wait "$XPROP_SPY_PID" 2>/dev/null
    fi

    if [ -z "$window_id" ]; then
        return
    fi

    log_msg "Starting property monitor for window $window_id"

    # Start xprop spy in background to monitor WM_NAME changes
    (
        xprop -id "$window_id" -spy WM_NAME 2>/dev/null | while read -r line; do
            if echo "$line" | grep -q "^WM_NAME"; then
                title=$(get_filtered_title "$line" "$window_id")
                update_polybar_title "$title"
            fi
        done
    ) &
    XPROP_SPY_PID=$!
}

# Function to handle focus change
handle_focus_change() {
    local focused_id=$(bspc query -N -n focused 2>/dev/null)

    if [ -z "$focused_id" ]; then
        update_polybar_title ""
        return
    fi

    log_msg "Focus changed to window $focused_id"

    # Get initial title
    initial_title=$(xprop -id "$focused_id" WM_NAME 2>/dev/null)
    title=$(get_filtered_title "$initial_title" "$focused_id")
    update_polybar_title "$title"

    # Start monitoring this window for title changes
    monitor_window "$focused_id"
}

# Check if another instance is running
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Window title daemon already running (PID: $OLD_PID)"
        exit 1
    else
        rm -f "$PIDFILE"
    fi
fi

# Write our PID
echo $$ > "$PIDFILE"

log_msg "Window title daemon started (PID: $$)"

# Initial update
handle_focus_change

# Monitor for focus changes
bspc subscribe node_focus desktop_focus 2>/dev/null | while read -r event; do
    handle_focus_change
done