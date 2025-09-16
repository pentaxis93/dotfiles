# Polybar Crash Investigation and Solutions

**Date**: September 16, 2025
**Issue**: Polybar randomly crashes/terminates without clear error messages
**Status**: Investigation complete, solutions identified

## Problem Description

Polybar has been experiencing random crashes where:
- Process silently terminates (no segfaults or coredumps)
- Polybar-autohide daemon continues running but logs "Failed to show polybar"
- No kernel-level errors detected in dmesg or journalctl
- Crashes occur both before and after configuration changes

### Symptoms
1. Polybar process disappears from process list
2. IPC socket becomes orphaned (e.g., `/tmp/polybar_mqueue.450289`)
3. Autohide script fails with repeated "Failed to show polybar" messages
4. No crash dumps in `/var/crash/` or systemd coredumps

## Investigation Findings

### System Environment
- **OS**: CachyOS Linux (Arch-based)
- **Polybar Version**: 3.7.2-2.1
- **Window Manager**: BSPWM
- **Display Server**: X11 (stable, no connection issues detected)

### Log Analysis

#### Polybar Logs (`/tmp/polybar.log`)
- Shows normal startup and module loading
- Contains deprecation warnings (addressed separately)
- Background manager warnings about missing wallpaper (non-fatal)
- Sometimes shows "Termination signal received" before crash
- Often no error message before disappearing

#### System Logs
- No segmentation faults in kernel logs
- No coredumps recorded by systemd
- journalctl shows no polybar-related errors

### Resource Analysis
- System memory is adequate (15GB total, 10GB available)
- No memory leaks detected
- CPU usage normal

## Completed Fix: Tray Module Migration

### Issue
Polybar was using deprecated bar-level tray settings causing warnings:
```
polybar|warn:  tray: bar/main.tray-position is deprecated
polybar|warn:  tray: bar/main.tray-padding is deprecated
```

### Solution Applied
Migrated from deprecated bar-level settings to the new internal/tray module format:

**Before** (in `[bar/main]`):
```ini
tray-position = right
tray-padding = 2
```

**After** (using module):
```ini
modules-right = ... systray

[module/systray]
type = internal/tray
format-margin = 8pt
tray-spacing = 16pt
tray-padding = 2
```

## Proposed Solution: Polybar Watchdog

### Concept
Create a lightweight daemon that monitors polybar health and automatically restarts it when crashes occur.

### Implementation Plan

#### 1. Watchdog Script (`~/.local/bin/polybar-watchdog.sh`)
```bash
#!/bin/bash
# ============================================================================
# POLYBAR WATCHDOG DAEMON
# ============================================================================
# Purpose:
#   Monitors polybar process health and automatically restarts it if it crashes.
#   Prevents manual intervention and ensures bar availability.
#
# Features:
#   - Checks polybar status every 10 seconds
#   - Automatically restarts crashed instances
#   - Prevents restart loops with counter/cooldown
#   - Logs all restart events for debugging
#
# Installation:
#   1. Place in ~/.local/bin/polybar-watchdog.sh
#   2. Make executable: chmod +x ~/.local/bin/polybar-watchdog.sh
#   3. Launch from bspwmrc instead of direct polybar launch
# ============================================================================

LOG_FILE="/tmp/polybar-watchdog.log"
PIDFILE="/tmp/polybar-watchdog.pid"
CHECK_INTERVAL=10        # seconds between health checks
MAX_RESTARTS=5          # max restarts within RESET_TIME
RESET_TIME=300          # seconds to reset restart counter
LAUNCH_SCRIPT="$HOME/.config/polybar/launch.sh"

restart_count=0
last_reset=$(date +%s)

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_restart_limit() {
    current_time=$(date +%s)
    time_diff=$((current_time - last_reset))

    if [ $time_diff -gt $RESET_TIME ]; then
        restart_count=0
        last_reset=$current_time
        log_msg "Reset restart counter after cooldown"
    fi

    if [ $restart_count -ge $MAX_RESTARTS ]; then
        log_msg "ERROR: Max restarts ($MAX_RESTARTS) reached within $RESET_TIME seconds"
        log_msg "Watchdog stopping to prevent restart loop"
        exit 1
    fi
}

restart_polybar() {
    log_msg "Polybar not found, attempting restart (attempt $((restart_count + 1))/$MAX_RESTARTS)"

    # Launch polybar using existing launch script
    if $LAUNCH_SCRIPT >> "$LOG_FILE" 2>&1; then
        restart_count=$((restart_count + 1))
        log_msg "Polybar restarted successfully"
        sleep 2  # Give polybar time to fully start
    else
        log_msg "ERROR: Failed to restart polybar"
    fi
}

cleanup() {
    log_msg "Watchdog shutting down"
    rm -f "$PIDFILE"
    exit 0
}

trap cleanup EXIT SIGINT SIGTERM

# Check for existing instance
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Watchdog already running (PID: $OLD_PID)"
        exit 1
    fi
    rm -f "$PIDFILE"
fi

echo $$ > "$PIDFILE"
log_msg "=== Polybar watchdog started (PID: $$) ==="

# Initial polybar launch if not running
if ! pgrep -x polybar > /dev/null; then
    log_msg "Polybar not running at startup, launching..."
    restart_polybar
fi

# Main monitoring loop
while true; do
    if ! pgrep -x polybar > /dev/null; then
        check_restart_limit
        restart_polybar
    fi

    sleep $CHECK_INTERVAL
done
```

#### 2. Integration with bspwmrc

Replace the current polybar launch in `~/.config/bspwm/bspwmrc`:

**Current**:
```bash
# Launch polybar
$HOME/.config/polybar/launch.sh
```

**New**:
```bash
# Kill any existing watchdog
pkill -f polybar-watchdog.sh 2>/dev/null
sleep 0.5

# Launch polybar via watchdog (ensures auto-restart on crashes)
nohup "$HOME/.local/bin/polybar-watchdog.sh" >/dev/null 2>&1 &
```

### Benefits
1. **Automatic Recovery**: Polybar restarts within 10 seconds of crash
2. **Logging**: All crashes and restarts are logged for analysis
3. **Loop Prevention**: Max restart limit prevents infinite loops
4. **Compatibility**: Works with existing autohide and launch scripts
5. **Zero Maintenance**: No manual intervention needed

## Debugging Commands

### Check polybar status
```bash
pgrep -x polybar                          # Check if running
polybar-msg cmd show                      # Test IPC connection
tail -f /tmp/polybar.log                  # Monitor polybar logs
tail -f /tmp/polybar-autohide.log         # Monitor autohide logs
tail -f /tmp/polybar-watchdog.log         # Monitor watchdog logs (after implementation)
```

### Manual restart
```bash
~/.config/polybar/launch.sh               # Restart using launch script
killall -q polybar && polybar main &      # Quick restart
```

### Check for crashes
```bash
journalctl --user -xe | grep polybar      # User journal
dmesg | grep polybar                      # Kernel messages (requires sudo)
coredumpctl list | grep polybar           # Coredumps
ls /var/crash/                           # Crash dumps
```

### Clean up orphaned IPC sockets
```bash
rm -f /tmp/polybar_mqueue.*              # Remove all orphaned sockets
```

## Related Files

| File | Purpose | Status |
|------|---------|--------|
| `~/.config/polybar/config.ini` | Main polybar configuration | ✅ Updated (tray module) |
| `~/.config/polybar/launch.sh` | Launch script with error handling | ✅ Working |
| `~/.config/bspwm/polybar-autohide.sh` | Auto-hide for video players | ✅ Working |
| `~/.config/bspwm/bspwmrc` | Window manager startup | 🔄 Needs watchdog integration |
| `~/.local/bin/polybar-watchdog.sh` | Watchdog daemon | 📝 To be created |

## Next Steps

1. **Implement watchdog daemon**
   - Create the watchdog script
   - Make it executable
   - Test thoroughly

2. **Update bspwmrc**
   - Replace direct polybar launch with watchdog
   - Test on system restart

3. **Monitor stability**
   - Check watchdog logs after implementation
   - Analyze crash patterns if they continue
   - Consider upstream bug report if crashes persist

## Possible Root Causes

Based on investigation, the crashes might be due to:
1. **X11 resource issues**: Background manager warnings suggest X11 resource problems
2. **Memory pressure**: Though system has adequate RAM, polybar might hit internal limits
3. **IPC issues**: Orphaned sockets suggest IPC communication problems
4. **Module bugs**: Specific modules might have stability issues in version 3.7.2

## Alternative Solutions

If the watchdog approach doesn't resolve the issue:
1. **Downgrade polybar**: Try version 3.6.x if available
2. **Compile from source**: Build latest development version
3. **Switch to alternative bars**: Consider waybar or i3bar
4. **Debug build**: Compile polybar with debug symbols for better crash analysis

---

*This document will be updated as we implement solutions and gather more data about the crash patterns.*