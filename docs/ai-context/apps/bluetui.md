# Bluetui TUI Bluetooth Manager

## Ultra-Zen Philosophy
**"Devices connect through mindful pairing; wireless bonds manifest through intention"**

## Architecture
- **TUI Bluetooth Manager** - Terminal-based bluetooth device management
- **Vi Navigation** - Intuitive keyboard-driven interface with hjkl movement
- **BlueZ Integration** - Direct integration with Linux bluetooth stack
- **Device Pairing** - Interactive pairing and connection management
- **Waybar Integration** - Click bluetooth widget to launch bluetui in Alacritty

## Configuration
- **Package**: `home/.chezmoidata/packages.yaml` - Declaratively managed
- **Fish Function**: `bt` - Launch bluetui TUI manager
- **Waybar Integration**: Click bluetooth widget to launch bluetui in Alacritty

## Usage
```bash
bt                  # Launch bluetui TUI manager
```

### Within bluetui
- **hjkl** - Navigate devices
- **Enter** - Connect/disconnect device
- **s** - Scan for devices
- **p** - Pair with device
- **d** - Delete paired device
- **q** - Quit

## Features
- Visual device list with connection status
- Interactive pairing workflow
- Device scanning and discovery
- Connection management (connect/disconnect)
- Trusted device management
- Battery level display for supported devices
- Signal strength indicators

## Benefits
- **Keyboard-Driven** - No mouse required for all operations
- **Quick Access** - Launch from terminal with `bt` or click Waybar widget
- **Visual Feedback** - Clear device status and connection state
- **Consistent Pattern** - Follows same integration as network (nmtui) and volume (wiremix)
