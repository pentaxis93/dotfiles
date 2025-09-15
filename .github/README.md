# pentaxis93's Dotfiles

Personal configuration files for CachyOS Linux with BSPWM, managed using a bare Git repository.

## 🎨 Theme

Entire system uses **Gruvbox Dark Hard** with cyan accent hierarchy for consistency across all applications.

## 🚀 Quick Install

### Prerequisites

- Git
- Fish shell
- CachyOS Linux (or Arch-based distribution)

### Installation

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

5. **Switch to Fish shell (if not already using):**
```bash
chsh -s /usr/bin/fish
```

6. **Install required packages:**
```bash
sudo pacman -S bspwm sxhkd polybar alacritty fish starship helix dmenu picom feh
```

7. **Install fonts:**
```bash
yay -S nerd-fonts-meslo
```

### Post-Installation Setup

#### Enable Brightness Control (ThinkPad users)
```bash
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/backlight/intel_backlight/brightness" | sudo tee /etc/sudoers.d/brightness
```

#### Set Gruvbox GTK Theme
```bash
yay -S gruvbox-material-gtk-theme-git
gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Dark"
```

#### Configure Papirus Icons with Teal Folders
```bash
sudo pacman -S papirus-icon-theme papirus-folders
papirus-folders -C teal
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
├── .gitconfig          # Git configuration
├── .gitignore          # Ignore sensitive files
└── CLAUDE.md           # AI assistant context
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

- [CLAUDE.md](CLAUDE.md) - Detailed system context and configuration notes
- [CHANGELOG.md](CHANGELOG.md) - Version history and changes

## 🐛 Troubleshooting

See the troubleshooting section in [CLAUDE.md](CLAUDE.md#troubleshooting).

## 📝 License

These dotfiles are provided as-is for personal use and reference.

---

*Managed with care on CachyOS Linux* 🐧