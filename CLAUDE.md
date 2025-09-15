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

## System Theme: Gruvbox Dark Hard

The entire system uses the **Gruvbox Dark Hard** color scheme with a custom cyan accent hierarchy for semantic consistency across all applications.

### Color Palette Reference

#### Core Colors
- **Background**: `#1d2021` (hard dark) - Primary background
- **Background Alt**: `#3c3836` (dark gray) - Secondary backgrounds, inactive elements
- **Foreground**: `#ebdbb2` (light cream) - Primary text
- **Disabled**: `#928374` (gray) - Disabled or muted elements

#### Accent Colors (Our Cyan Hierarchy)
- **Primary Accent**: `#8ec07c` (bright aqua) - Active/focused/selected elements
- **Secondary Accent**: `#689d6a` (regular aqua) - Labels, informational text, inactive accents

#### Semantic Colors
- **Error/Alert**: `#fb4934` (bright red) - Errors, alerts, urgent items
- **Warning**: `#fabd2f` (bright yellow) - Warnings, caution states
- **Success**: `#b8bb26` (bright green) - Success states, confirmations
- **Info**: `#83a598` (bright blue) - Informational messages

### Why Aqua Looks "Greenish"
The Gruvbox "aqua" colors (`#8ec07c` and `#689d6a`) intentionally lean toward green rather than pure cyan. This creates a warmer, more organic feel that fits Gruvbox's retro, earthy aesthetic. This is not a bug but a deliberate design choice that distinguishes Gruvbox from cooler, more synthetic color schemes.

### Applied Configurations
- **Terminal**: Alacritty, Tmux, Fish shell with Gruvbox colors
- **Window Manager**: BSPWM with aqua borders (`#8ec07c`)
- **Status Bar**: Polybar with cyan accent hierarchy
- **Prompt**: Starship with clean aqua accents
- **Editor**: Helix and Vim with gruvbox_dark_hard
- **File Manager**: Thunar with custom GTK overrides
- **Icons**: Papirus-Dark with teal folders (closest to our aqua)
- **GTK Theme**: Gruvbox-Teal-Dark with custom CSS overrides in `~/.config/gtk-3.0/gtk.css`

## Configuration Documentation Best Practices

When modifying configuration files, follow these guidelines to ensure maintainability:

### 1. Always Explain the "Why"
Don't just document what a setting does - explain why you chose it.

**Bad:**
```bash
bspc config focused_border_color "#8ec07c"  # Set border color
```

**Good:**
```bash
bspc config focused_border_color "#8ec07c"  # Bright aqua - matches our terminal accent color
```

### 2. Document Color Semantics
Explain what each color represents in your UI hierarchy.

```css
/* Color hierarchy:
 * - Bright aqua (#8ec07c): Active/focused elements (grabs attention)
 * - Regular aqua (#689d6a): Informational text (provides context)
 * - Gray (#928374): Disabled items (de-emphasized)
 */
```

### 3. Include Both Hex Codes and Names
Always provide both for clarity:
```css
color: #8ec07c;  /* bright aqua */
```

### 4. Cross-Reference Related Configs
Note when settings should match across tools:
```bash
# This should match the border color in ~/.config/bspwm/bspwmrc
set -g pane-active-border-style 'fg=#8ec07c'
```

### 5. Explain Non-Obvious Choices
Document anything that might confuse future you:
```css
/* Using 30% opacity to keep text readable while showing selection.
 * Higher opacity makes the underlying text too hard to read. */
background-color: rgba(142, 192, 124, 0.3);
```

### 6. Document Overrides and Workarounds
Explain why you're overriding defaults:
```css
/* Override Gruvbox-Teal theme selection color (#89b482)
 * to match our consistent aqua accent (#8ec07c) */
.thunar .sidebar row:selected {
  background-color: rgba(142, 192, 124, 0.3);
}
```

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