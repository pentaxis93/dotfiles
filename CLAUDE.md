# System Configuration Context

When Claude Code is invoked in this directory (`/home/pentaxis93`), we are likely working on **system configuration and dotfiles management**.

## System Overview

- **OS**: CachyOS Linux (Arch-based distribution)
- **Kernel**: Linux 6.16.7-2-cachyos
- **Window Manager**: BSPWM (Binary Space Partitioning Window Manager)
- **Hotkey Daemon**: SXHKD
- **Audio Server**: PipeWire 1.4.8 (with PulseAudio compatibility)
- **Hardware**: ThinkPad (Model: 20W4002HUS)
- **Shell**: Zsh (default), Fish shell available
- **Terminal**: Alacritty
- **Editor**: Vim

## Dotfiles Management

This system uses a **bare Git repository** for dotfiles management, accessible via the `dots` command.

### How It Works

The dotfiles are managed using a bare Git repository located at `~/.dotfiles/`. This approach allows version control of configuration files without turning the entire home directory into a Git repository.

### The `dots` Command

`dots` is a Fish shell function defined in `~/.config/fish/functions/dots.fish`:
```bash
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
```

### Common Dotfiles Commands

```bash
dots status           # Check status of tracked files
dots add <file>       # Stage a file for commit
dots commit -m "msg"  # Commit changes
dots push            # Push to remote repository
dots diff            # View unstaged changes
dots log             # View commit history
```

### Fish Shell Abbreviations

The following abbreviations are configured in Fish:
- `da` → `dots add`
- `dc` → `dots commit`
- `dp` → `dots push`
- `dst` → `dots status`
- `dd` → `dots diff`

### Important: Using `dots` from Other Shells

When not in Fish shell, use:
```bash
fish -c "dots <command>"
# OR directly:
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME <command>
```

## Key Configuration Files

### Window Manager & Hotkeys
- `~/.config/bspwm/bspwmrc` - BSPWM configuration
- `~/.config/sxhkd/sxhkdrc` - Keyboard shortcuts (including ThinkPad function keys)

### Shell Configurations
- `~/.config/fish/config.fish` - Fish shell configuration
- `~/.config/fish/functions/` - Custom Fish functions (including `dots`)
- `~/.zshrc` - Zsh configuration (default shell)

### Other Important Configs
- `~/.config/alacritty/` - Terminal emulator configuration
- `~/.config/polybar/` - Status bar configuration

## ThinkPad Function Keys

The following function keys are configured in SXHKD:

### Volume Controls
- **Fn+F1** or **Super+F1** → Mute/unmute audio
- **Fn+F2** or **Super+F2** → Volume down (5%)
- **Fn+F3** or **Super+F3** → Volume up (5%)

### Microphone
- **Fn+F4** or **Super+F4** → Mute/unmute microphone

### Display & Brightness
- **Fn+F7** or **Super+F7** → Brightness down (5%)
- **Fn+F8** or **Super+F8** → Brightness up (5%)

## Common Tasks

### Adding New Configuration to Dotfiles
```bash
fish -c "dots add ~/.config/newapp/config"
fish -c "dots commit -m 'Add newapp configuration'"
fish -c "dots push"
```

### Reloading Configurations
```bash
# Reload SXHKD (or use Super+Escape)
pkill -USR1 -x sxhkd

# Restart BSPWM (or use Super+Alt+R)
bspc wm -r
```

### Audio Management
```bash
# Using wpctl (PipeWire)
wpctl get-volume @DEFAULT_AUDIO_SINK@
wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
```

### Brightness Control
Brightness is controlled via sysfs. Note: Requires sudo privileges.
```bash
# Current brightness
cat /sys/class/backlight/intel_backlight/brightness

# Set brightness (max is 19393)
echo 10000 | sudo tee /sys/class/backlight/intel_backlight/brightness
```

## Documentation Lookup

### Using Context7 for Documentation
When you need documentation for tools, libraries, or terminal emulators, use the context7 MCP server instead of web searches. This provides more accurate and up-to-date documentation.

Examples of when to use context7:
- Terminal emulator documentation (kitty, alacritty, wezterm)
- Tool configurations (tmux, vim, neovim, fish)
- Programming libraries and frameworks
- System tools and utilities

To use: Ask Claude Code to "use context7 to get documentation for [tool/library]"

## Development Patterns

### Configuration Philosophy
- **Simplicity First**: Prefer direct inline commands over helper scripts when possible
- **Version Control**: All configuration changes should be committed to the dotfiles repo
- **Documentation**: Update this file when adding new tools or changing workflows

### When Making Configuration Changes
1. Test changes locally first
2. Use `dots diff` to review changes
3. Commit with descriptive messages
4. Avoid adding attribution footers to commits

### Best Practices
- Keep SXHKD keybindings simple and well-commented
- Use tabs (not spaces) for indentation in SXHKD config
- Test keybindings after reloading SXHKD
- Document any new tools or scripts added to the system

## System-Specific Notes

- **Package Manager**: `pacman` (with `yay` for AUR packages)
- **Init System**: systemd
- **Graphics**: Intel integrated graphics (Tiger Lake-LP)
- **Backlight Path**: `/sys/class/backlight/intel_backlight/`

## Troubleshooting

### If `dots` command not found
Ensure you're using Fish shell or use the full Git command:
```bash
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME status
```

### If keybindings don't work
1. Check SXHKD is running: `pgrep sxhkd`
2. Reload configuration: `pkill -USR1 -x sxhkd`
3. Check for syntax errors: `sxhkd -c ~/.config/sxhkd/sxhkdrc`

### Audio issues
- Check PipeWire status: `systemctl --user status pipewire`
- List audio sinks: `pactl list sinks short`
- Check current default: `wpctl status`

---

*This file helps Claude Code understand the system context and common workflows. Update it when making significant system changes.*