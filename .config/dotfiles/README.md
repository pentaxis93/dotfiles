# pentaxis93's Dotfiles

Minimalist configuration files for CachyOS Linux with BSPWM, managed using a bare Git repository.

## 🎨 Theme

Entire system uses **Gruvbox Dark Hard** with cyan accent hierarchy for consistency across all applications.

## 🚀 Quick Install

### Prerequisites

- Git
- CachyOS Linux (or Arch-based distribution)
- sudo privileges

### Automated Installation (Recommended)

1. **Clone the bare repository:**
```bash
git clone --bare https://github.com/pentaxis93/dotfiles.git $HOME/.dotfiles
```

2. **Define temporary alias:**
```bash
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

3. **Checkout the actual content:**
```bash
dots checkout
```

If you receive errors about existing files, back them up:
```bash
mkdir -p .config-backup && \
dots checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}
```

Then retry the checkout:
```bash
dots checkout
```

4. **Set git to not show untracked files:**
```bash
dots config --local status.showUntrackedFiles no
```

5. **Run the bootstrap script:**
```bash
# Full installation with all packages and system setup
~/.local/bin/bootstrap.sh --setup

# OR minimal installation (core packages only)
~/.local/bin/bootstrap.sh --minimal --setup

# OR preview what would be installed
~/.local/bin/bootstrap.sh --dry-run
```

The bootstrap script will:
- ✅ Install all required packages (pacman & AUR)
- ✅ Configure brightness control (ThinkPad)
- ✅ Set up GTK themes and icons
- ✅ Configure Fish as default shell
- ✅ Enable audio services
- ✅ Set correct file permissions

### Manual Installation (Alternative)

If you prefer to install packages manually:

```bash
# Core packages (window manager, terminal, shell, utilities)
sudo pacman -S bspwm sxhkd polybar alacritty fish starship helix dmenu picom \
               git xclip htop neofetch base-devel \
               thunar btop networkmanager gsimplecal pavucontrol \
               pipewire pipewire-pulse pipewire-alsa wireplumber

# Optional CLI tools
sudo pacman -S ripgrep fd fzf bat eza tmux lazygit gh unzip p7zip

# Install yay for AUR packages
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si

# AUR packages (fonts & themes)
yay -S nerd-fonts-meslo ttf-font-awesome noto-fonts-emoji \
       gruvbox-material-gtk-theme-git papirus-folders

# System setup
~/.local/bin/setup-system.sh
```

## 📦 Package Management

### Bootstrap System

The dotfiles include an automated bootstrap system for **minimalist** dependency management:

```bash
# View all dependencies and their purposes
cat ~/.config/dotfiles/bootstrap/DEPENDENCIES.md

# Package lists (only what's actually used)
~/.config/dotfiles/bootstrap/
├── packages-core.txt    # Essential packages + polybar utilities
├── packages-tools.txt   # CLI tools we actually use
└── packages-aur.txt     # Fonts & themes only
```

**Philosophy**: This is a minimalist setup - no development packages, no wishlist items, only what's configured and used in the dotfiles.

### Bootstrap Options

```bash
bootstrap.sh [OPTIONS]
  -h, --help      Show help message
  -m, --minimal   Install core packages only
  -d, --dry-run   Preview what would be installed
  -s, --setup     Run system setup after installation
  -v, --verbose   Show detailed output
  -f, --force     Reinstall even if packages exist
```

## 📁 Structure

```
~/
├── .config/
│   ├── alacritty/      # Terminal emulator
│   ├── bspwm/          # Window manager
│   ├── fish/           # Shell configuration
│   ├── helix/          # Text editor
│   ├── polybar/        # Status bar
│   ├── starship.toml   # Shell prompt
│   └── sxhkd/          # Hotkey daemon
├── .local/
│   └── bin/            # User scripts
├── .config/
│   └── dotfiles/       # Documentation & bootstrap
├── .gitconfig          # Git configuration
└── .gitignore          # Ignore sensitive files
```

## ⌨️ Key Bindings

### Window Management
- `Super + Enter` - Open terminal
- `Super + Space` - Application launcher
- `Super + W` - Close window
- `Super + M` - Toggle monocle layout
- `Super + {1-9,0}` - Switch workspace
- `Super + Shift + {1-9,0}` - Move window to workspace

### System Controls
- `Super + F1` - Mute/unmute audio
- `Super + F2/F3` - Volume down/up
- `Super + F4` - Mute microphone
- `Super + F7/F8` - Brightness down/up
- `Super + B` - Toggle polybar visibility
- `Super + Escape` - Reload sxhkd config
- `Super + Alt + R` - Restart BSPWM

## 🛠️ Dotfiles Management

The `dots` command is a Fish function that manages the bare repository:

```bash
dots status          # Check status
dots add <file>      # Stage changes
dots commit -m "msg" # Commit
dots push           # Push to remote
dots pull           # Pull changes
dots diff           # View changes
```

### Fish Abbreviations

Quick shortcuts configured in Fish:
- `da` → `dots add`
- `dc` → `dots commit`
- `dp` → `dots push`
- `dst` → `dots status`
- `dd` → `dots diff`

## 🔧 Customization

### Adding New Configurations

1. Create/modify your config file
2. Add it to the repository:
```bash
dots add ~/.config/newapp/config
dots commit -m "Add newapp configuration"
dots push
```

### Machine-Specific Settings

Create `~/.config/fish/local.fish` for machine-specific configurations that won't be tracked.

## 📚 Documentation

- [CLAUDE.md](./CLAUDE.md) - Detailed system context and configuration notes
- [CHANGELOG.md](./docs/CHANGELOG.md) - Version history and changes
- [DEPENDENCIES.md](./bootstrap/DEPENDENCIES.md) - Complete package documentation

## 🐛 Troubleshooting

See the troubleshooting section in [CLAUDE.md](./CLAUDE.md#troubleshooting).

## 📝 License

These dotfiles are provided as-is for personal use and reference.

---

*Managed with care on CachyOS Linux* 🐧