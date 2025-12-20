# System Automation Tools

## Ultra-Zen Philosophy
**"The agent's intention becomes action; keyboard and mouse flow through code"**

## Architecture
- **ydotool** - Wayland input automation (keyboard/mouse simulation)
- **wev** - Wayland event viewer (debugging input events)
- **socat** - Socket manipulation (advanced IPC)
- **slurp** - Interactive region selection for screenshots
- **grim** - Screenshot capture utility

## Configuration Files
- **Service**: `home/dot_config/systemd/user/ydotool.service` - ydotool daemon service
- **Setup Script**: `home/run_once_setup-ydotool.sh.tmpl` - Auto-enable daemon
- **Package**: `home/.chezmoidata/packages.yaml` - Declaratively managed

## Usage

### ydotool - Input Automation

**Keyboard Simulation:**
```bash
# Type text
ydotool type "Hello World"

# Press specific keys
ydotool key 28:1 28:0          # Press and release Enter
ydotool key 29:1 45:1 45:0 29:0  # Ctrl+X (hold ctrl, press x, release both)

# Key codes: See /usr/include/linux/input-event-codes.h
# Common: Enter=28, ESC=1, Space=57, Tab=15
```

**Mouse Simulation:**
```bash
# Move mouse (relative)
ydotool mousemove -x 100 -y 50

# Move mouse (absolute)
ydotool mousemove --absolute -x 500 -y 300

# Click
ydotool click 0xC0  # Left click (0x40 = press, 0x80 = release)
ydotool click 0xC1  # Right click

# Double click
ydotool click 0xC0 0xC0
```

**Daemon Management:**
```bash
# Check daemon status
systemctl --user status ydotool

# Restart daemon
systemctl --user restart ydotool

# View logs
journalctl --user -u ydotool -f
```

### wev - Event Viewer

Debug Wayland events to understand what inputs to simulate:

```bash
# Launch event viewer (focus a window and interact)
wev

# Filter specific event types
wev | grep keyboard
wev | grep pointer
```

### socat - Socket Communication

Advanced IPC and service communication:

```bash
# Connect to Unix socket
socat - UNIX-CONNECT:/path/to/socket

# TCP port forwarding
socat TCP-LISTEN:8080,fork TCP:localhost:3000

# Bidirectional relay
socat TCP-LISTEN:1234 EXEC:'/bin/bash'
```

### Screenshots

```bash
# Full screen
grim screenshot.png

# Interactive region selection
grim -g "$(slurp)" screenshot.png

# Specific output
grim -o eDP-1 screenshot.png

# With annotation
grim -g "$(slurp)" - | satty -f -
```

## Agentic Use Cases

### GUI Automation
```bash
# Focus a window, type text, submit
niri msg action focus-window --id <window-id>
sleep 0.1
ydotool type "automated input"
ydotool key 28:1 28:0  # Enter
```

### Form Filling
```bash
# Navigate through form fields with Tab and fill data
ydotool type "username"
ydotool key 15:1 15:0  # Tab
ydotool type "password"
ydotool key 28:1 28:0  # Enter
```

### Screenshot Automation
```bash
# Capture specific region programmatically
grim -g "100,200 800x600" region.png
```

### Process Control
```bash
# Get window list, focus specific app, send input
niri msg windows -j | jq '.[] | select(.app_id=="firefox")'
niri msg action focus-window --id <id>
ydotool key 29:1 36:1 36:0 29:0  # Ctrl+J (downloads)
```

## Integration with Playwright MCP

Playwright handles **browser automation**, while these tools handle **everything else**:

- **Playwright**: Web apps, forms, JavaScript-heavy sites
- **ydotool**: Native GUI apps, system dialogs, non-web interfaces
- **niri msg**: Window management, workspace switching, layout control

## Benefits

- **Universal Control** - Automate any GUI application
- **Wayland Native** - Works with modern compositor (niri)
- **Debugging Tools** - wev helps understand events
- **Screenshot Capability** - Full screen or region capture
- **IPC Flexibility** - socat for advanced communication
- **Auto-Start** - ydotool daemon enabled by systemd

## Troubleshooting

### ydotool commands not working
```bash
# Check daemon is running
systemctl --user status ydotool

# Check socket exists
ls -la /tmp/.ydotool_socket

# Restart daemon
systemctl --user restart ydotool
```

### Wrong key codes
```bash
# Use wev to find correct key codes
wev | grep keyboard

# Reference: /usr/include/linux/input-event-codes.h
```

### Permission issues
```bash
# Ensure user has access to input devices (usually automatic in Wayland)
# Check groups
groups

# ydotool should work without special permissions in user session
```

---

*"The keyboard becomes conscious; the mouse gains intention; automation flows from code."*
