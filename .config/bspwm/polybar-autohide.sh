#!/bin/bash
# Auto-hide polybar when mpv is focused in monocle mode
# This script monitors bspwm events and toggles polybar visibility

# Function to check if polybar should be hidden
should_hide_polybar() {
    # Get current desktop layout
    layout=$(bspc query -T -d focused | grep -o '"layout":"[^"]*"' | cut -d'"' -f4)

    # Get focused window class
    focused_id=$(bspc query -N -n focused 2>/dev/null)
    if [ -z "$focused_id" ]; then
        echo "false"
        return
    fi

    # Get window class (mpv, vlc, etc)
    win_class=$(xprop -id "$focused_id" WM_CLASS 2>/dev/null | grep -o '"[^"]*"' | tr -d '"' | tail -1 | tr '[:upper:]' '[:lower:]')

    # Hide polybar if:
    # 1. Layout is monocle AND
    # 2. Focused window is a video player (mpv, vlc, etc)
    if [ "$layout" = "monocle" ] && [[ "$win_class" =~ ^(mpv|vlc|mplayer|smplayer)$ ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Function to update polybar visibility
update_polybar() {
    if [ "$(should_hide_polybar)" = "true" ]; then
        # Hide polybar
        polybar-msg cmd hide >/dev/null 2>&1
    else
        # Show polybar
        polybar-msg cmd show >/dev/null 2>&1
    fi
}

# Initial check
update_polybar

# Monitor bspwm events
bspc subscribe node_focus desktop_layout | while read -r event; do
    update_polybar
done