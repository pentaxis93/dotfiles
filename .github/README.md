# CachyOS Dotfiles

Personal configuration files for my CachyOS setup with bspwm, managed using a git bare repository.

## Contents

- **bspwm** - Tiling window manager configuration
- **sxhkd** - Hotkey daemon for bspwm
- **polybar** - Status bar with workspace indicators and system info
- **fish** - Modern shell with vi mode and useful abbreviations

## Installation on a New Machine

### 1. Clone the Repository

```bash
# Clone as a bare repository
git clone --bare https://github.com/YOUR_USERNAME/dotfiles.git $HOME/.dotfiles

# Define temporary alias
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Configure to not show untracked files
dots config --local status.showUntrackedFiles no

# Checkout the actual content
dots checkout
```

If you get errors about existing files, back them up:
```bash
mkdir -p .config-backup && \
dots checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}
```

Then run `dots checkout` again.

### 2. Install Dependencies

```bash
# Core packages
sudo pacman -S bspwm sxhkd polybar fish starship

# Optional but recommended
sudo pacman -S eza bat fzf fastfetch
```

### 3. Set Fish as Default Shell

```bash
chsh -s /bin/fish
```

### 4. Reload bspwm

Press `Super + Alt + R` or log out and back in.

## Daily Usage

The `dots` command works just like git:

```bash
# Check status
dots status

# Add files
dots add ~/.config/some-new-config

# Commit changes
dots commit -m "Add new config"

# Push to remote
dots push

# Pull changes from remote
dots pull
```

### Fish Abbreviations

Quick shortcuts available in fish:

**Dotfiles:**
- `dst` - Check dotfiles status
- `da <file>` - Add file to dotfiles
- `dc` - Commit dotfiles changes
- `dp` - Push dotfiles

**Git:**
- `g` - git
- `gst` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push

**System:**
- `syu` - System update
- `install` - Install package
- `search` - Search packages

**Config Editing:**
- `fishconfig` - Edit fish config
- `bspconfig` - Edit bspwm config
- `sxhkdconfig` - Edit sxhkd config
- `polybarconfig` - Edit polybar config

## Key Bindings

### Window Manager (bspwm)

- `Super + Enter` - Open terminal
- `Super + Space` - App launcher
- `Super + {1-9,0}` - Switch to workspace
- `Super + Shift + {1-9,0}` - Move window to workspace
- `Super + Alt + R` - Reload bspwm config
- `Super + Alt + Q` - Quit bspwm

### Fish Shell

Vi mode is enabled:
- `Esc` - Enter normal mode
- `i` - Enter insert mode
- In normal mode: navigate with `hjkl`, use vim motions

## Customization

### Local Settings

Create `~/.config/fish/local.fish` for machine-specific settings that won't be committed.

### Changing Editor

When nvim is installed, update fish config:
```fish
set -gx EDITOR nvim
set -gx VISUAL nvim
```

## Structure

```
~
├── .config/
│   ├── bspwm/
│   │   └── bspwmrc
│   ├── sxhkd/
│   │   └── sxhkdrc
│   ├── polybar/
│   │   ├── config.ini
│   │   └── launch.sh
│   └── fish/
│       ├── config.fish
│       └── functions/
│           └── dots.fish
└── .dotfiles/  (bare git repository)
```

## Resources

- [bspwm documentation](https://github.com/baskerville/bspwm)
- [Fish shell documentation](https://fishshell.com/docs/current/)
- [Polybar wiki](https://github.com/polybar/polybar/wiki)
- [Starship prompt](https://starship.rs/)

---

*Managed with a bare git repository for clean dotfile versioning*