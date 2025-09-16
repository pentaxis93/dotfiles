# Dotfiles Dependencies Documentation

This document provides comprehensive information about all packages required for the dotfiles to function properly. This is a **minimalist setup** - only what's actually used.

## Table of Contents

- [Quick Installation](#quick-installation)
- [Core System](#core-system)
- [Window Management](#window-management)
- [Terminal & Shell](#terminal--shell)
- [Text Editor](#text-editor)
- [Polybar Click Utilities](#polybar-click-utilities)
- [Audio System](#audio-system)
- [CLI Tools](#cli-tools)
- [Fonts & Themes](#fonts--themes)
- [Package Management](#package-management)
- [Troubleshooting](#troubleshooting)

## Quick Installation

```bash
# Install all dependencies
~/.local/bin/bootstrap.sh

# Minimal installation (core only)
~/.local/bin/bootstrap.sh --minimal

# Dry run to see what would be installed
~/.local/bin/bootstrap.sh --dry-run

# Full installation with system setup
~/.local/bin/bootstrap.sh --setup
```

## Core System

### Essential Utilities

| Package | Purpose | Config Files | Required |
|---------|---------|--------------|----------|
| **git** | Version control, dotfiles management | `.gitconfig`, Fish functions | ✅ Yes |
| **curl** | Download files, API calls | Various scripts | ✅ Yes |
| **wget** | Alternative downloader | Various scripts | ✅ Yes |
| **base-devel** | Build tools for AUR packages | N/A | ✅ Yes (for AUR) |
| **man-db** | Manual pages | N/A | ✅ Yes |
| **htop** | Process viewer | N/A | Optional |
| **neofetch** | System info display | N/A | Optional |

## Window Management

### Display Server & Window Manager

| Package | Purpose | Config Files | Required |
|---------|---------|--------------|----------|
| **bspwm** | Tiling window manager | `~/.config/bspwm/bspwmrc` | ✅ Yes |
| **sxhkd** | Hotkey daemon | `~/.config/sxhkd/sxhkdrc` | ✅ Yes |
| **polybar** | Status bar | `~/.config/polybar/` | ✅ Yes |
| **picom** | Compositor (transparency) | `~/.config/picom/` | Optional |
| **dmenu** | Application launcher | sxhkd keybindings | ✅ Yes |
| **xclip** | X11 clipboard | Scripts, terminal | ✅ Yes |

### Dependencies Chain
```
bspwm
└── sxhkd (keybindings)
    └── polybar (status bar)
        └── Various click utilities (see below)
```

## Terminal & Shell

| Package | Purpose | Config Files | Required |
|---------|---------|--------------|----------|
| **alacritty** | GPU-accelerated terminal | `~/.config/alacritty/` | ✅ Yes |
| **fish** | Interactive shell | `~/.config/fish/` | ✅ Yes |
| **starship** | Cross-shell prompt | `~/.config/starship.toml` | ✅ Yes |
| **tmux** | Terminal multiplexer | `~/.tmux.conf` | Optional |

## Text Editor

| Package | Purpose | Config Files | Required |
|---------|---------|--------------|----------|
| **helix** | Modern modal editor | `~/.config/helix/` | ✅ Yes |

We use **only Helix** to encourage mastery of a single editor rather than switching between multiple editors.

## Polybar Click Utilities

These programs are launched when clicking on polybar modules:

| Package | Purpose | Polybar Module | Click Action |
|---------|---------|----------------|--------------|
| **thunar** | File manager | filesystem | Right-click opens file manager |
| **btop** | System monitor | cpu, memory | Right-click opens system monitor |
| **networkmanager** | Network management | wlan | Right-click opens nmtui |
| **gsimplecal** | Calendar popup | date | Right-click shows calendar |
| **pavucontrol** | Audio control GUI | pulseaudio | Right-click opens audio mixer |

### Polybar Module Actions
```ini
# From polybar config.ini:
[module/filesystem]
format-mounted = %{A3:thunar:}<label-mounted>%{A}

[module/memory]
format = %{A3:alacritty -e btop:}<label>%{A}

[module/cpu]
format = %{A3:alacritty -e btop:}<label>%{A}

[module/wlan]
format-connected = %{A3:alacritty -e nmtui:}<label-connected>%{A}

[module/date]
format = %{A3:gsimplecal:}<label>%{A}

[module/pulseaudio]
click-right = pavucontrol
```

## Audio System

### PipeWire Stack

| Package | Purpose | Config Files | Required |
|---------|---------|--------------|----------|
| **pipewire** | Audio server | System service | ✅ Yes |
| **pipewire-pulse** | PulseAudio compatibility | N/A | ✅ Yes |
| **pipewire-alsa** | ALSA compatibility | N/A | ✅ Yes |
| **wireplumber** | Session manager | System service | ✅ Yes |

### Audio Dependencies Chain
```
pipewire (main server)
├── pipewire-pulse (for pactl/wpctl commands)
├── pipewire-alsa (for ALSA apps)
└── wireplumber (session management)
    └── pavucontrol (GUI control)
```

## CLI Tools

### Modern CLI Replacements

These are **optional** but recommended tools that enhance the command-line experience:

| Package | Replaces | Purpose | Used By |
|---------|----------|---------|---------|
| **ripgrep** | grep | Fast text search | Claude Code |
| **fd** | find | Fast file finder | General use |
| **bat** | cat | Syntax highlighting | General use |
| **eza** | ls | Better ls with git info | General use |
| **fzf** | N/A | Fuzzy finder | Fish config checks for it |
| **zoxide** | cd history | Smart directory jumper (z command) | Fish config initializes it |

### Git Enhancement

| Package | Purpose | Config Files | Required |
|---------|---------|--------------|----------|
| **lazygit** | Git TUI | Fish functions (`lazydots`) | Optional |
| **gh** | GitHub CLI | `.config/gh/` | Optional |

### Archive Tools

| Package | Purpose | Required |
|---------|---------|----------|
| **unzip** | ZIP extraction | Optional |
| **p7zip** | 7-Zip support | Optional |

## Fonts & Themes

### Fonts (AUR)

| Package | Purpose | Used By | Required |
|---------|---------|---------|----------|
| **nerd-fonts-meslo** | Terminal font with icons | Alacritty, Starship | ✅ Yes |
| **ttf-font-awesome** | Icon font | Polybar | ✅ Yes |
| **noto-fonts-emoji** | Emoji support | System-wide | ✅ Yes |

### Why Emoji Support Matters

Without `noto-fonts-emoji`, emojis display as boxes (□) in terminals. With it, you get proper emoji rendering for:
- Git commit messages
- Modern CLI tools that use emojis
- Documentation/README files
- System notifications

### Themes (AUR)

| Package | Purpose | Config Files | Required |
|---------|---------|--------------|----------|
| **gruvbox-material-gtk-theme-git** | GTK theme | GTK apps | Optional |
| **papirus-icon-theme** | Icon theme | System-wide | Optional |
| **papirus-folders** | Folder color tool | N/A | Optional |

## Package Management

### Package List Files

The bootstrap system uses these files to organize packages:

- **packages-core.txt**: Essential packages (always installed)
- **packages-tools.txt**: CLI enhancements (recommended)
- **packages-aur.txt**: AUR packages (fonts, themes)

Note: `packages-dev.txt` has been removed - this is a minimalist setup focused on dotfiles management, not development environments.

### Installation Order

1. **Core packages** (pacman) - Window manager, terminal, shell
2. **Tools packages** (pacman) - Modern CLI replacements
3. **AUR packages** (yay) - Fonts and themes

## Troubleshooting

### Missing Icons in Terminal
**Problem**: Powerline symbols or icons not showing
**Solution**: Install nerd fonts
```bash
yay -S nerd-fonts-meslo
fc-cache -fv
```

### Audio Not Working
**Problem**: No sound or volume controls not working
**Solution**: Ensure PipeWire is running
```bash
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

### Brightness Keys Not Working
**Problem**: Function keys for brightness don't work
**Solution**: Run system setup
```bash
~/.local/bin/setup-system.sh
```

### Polybar Click Actions Not Working
**Problem**: Clicking polybar modules doesn't launch programs
**Solution**: Ensure the required utilities are installed
```bash
# Check what's missing
for cmd in thunar btop nmtui gsimplecal pavucontrol; do
    command -v $cmd >/dev/null 2>&1 && echo "✓ $cmd" || echo "✗ $cmd"
done

# Install missing ones
sudo pacman -S thunar btop networkmanager gsimplecal pavucontrol
```

### Theme Not Applied
**Problem**: GTK apps not using Gruvbox theme
**Solution**: Set theme properly
```bash
gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Dark"
papirus-folders -C teal
```

## Minimal vs Full Installation

### Minimal Installation
Core packages only - basic functional system:
- Window manager (bspwm, sxhkd)
- Terminal (alacritty)
- Shell (fish)
- Editor (helix)
- Essential utilities

```bash
~/.local/bin/bootstrap.sh --minimal
```

### Full Installation
All packages including enhancements:
- All minimal packages
- Modern CLI tools (ripgrep, fd, fzf, etc.)
- Fonts and themes
- Polybar click utilities

```bash
~/.local/bin/bootstrap.sh
```

## System Requirements

- **OS**: Arch Linux or derivative (CachyOS, Manjaro, EndeavourOS)
- **Display Server**: X11 (Wayland not supported)
- **Architecture**: x86_64 or aarch64
- **RAM**: 2GB minimum, 4GB recommended
- **Disk**: ~500MB for all packages

## Verification

Check if all core dependencies are installed:

```bash
# Run dependency check
for cmd in bspwm sxhkd polybar alacritty fish helix git dmenu xclip; do
    command -v $cmd >/dev/null 2>&1 && echo "✓ $cmd" || echo "✗ $cmd"
done
```

## Maintenance

### Adding New Dependencies

When adding a new tool to your dotfiles:

1. Add the package to the appropriate list file:
```bash
echo "package-name" >> ~/.config/bootstrap/packages-tools.txt
```

2. Document it in this file with:
   - What it does
   - Why it's needed
   - Which config files use it

3. Test installation:
```bash
~/.local/bin/bootstrap.sh --dry-run
```

### Removing Packages

The bootstrap system only installs packages, it doesn't remove them:

```bash
# Remove a package and its dependencies
sudo pacman -Rns package-name

# Remove orphaned dependencies
sudo pacman -Rns $(pacman -Qtdq)
```

## Philosophy

This dotfiles setup follows a **minimalist philosophy**:

1. **Only what's used**: No wishlist items or "might need someday" packages
2. **Single tool mastery**: One editor (Helix), not multiple
3. **Clear purpose**: Every package has a documented reason for being included
4. **Polybar integration**: Click utilities enhance the desktop experience
5. **No development bloat**: This is for dotfiles, not a development environment

---

*Last updated: When bootstrap system was cleaned up for minimalism*
*Maintained as part of pentaxis93's dotfiles*