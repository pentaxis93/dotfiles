# Wiremix TUI Audio Mixer

## Architecture
- **Kanagawa Theme** - Full color customization from centralized palette
- **PipeWire Native** - Designed specifically for PipeWire audio system
- **Helix-Native Keybindings** - Vi navigation with semantic improvements (ge for end, hjkl movement)
- **Volume Shortcuts** - Shift+0-9 for quick volume percentages (0=mute, 5=50%, 0=100%)
- **Tab Navigation** - Number keys 1-5 for quick tab switching

## Configuration
- **File**: `home/dot_config/wiremix/wiremix.toml.tmpl` - Extensive customization
- **Zsh Functions**: `vol` (launch mixer), `volu/vold` (volume up/down), `volm` (mute toggle), `vols` (status)
- **Waybar Integration**: Click volume widget to launch wiremix in Kitty

## Features
- Peak meters with visual audio level monitoring
- Overload detection for audio
- Device management (set defaults, configure routes, manage profiles)
- Tab organization: Playback, Recording, Outputs, Inputs, Config