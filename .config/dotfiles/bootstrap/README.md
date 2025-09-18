# Dotfiles Bootstrap System

A clean, maintainable bootstrap system for Arch/CachyOS environments.

## Philosophy

This bootstrap system follows these core principles:

1. **Simplicity over Features** - Let tools do what they're good at
2. **Separation of Concerns** - Packages are data, scripts are logic
3. **Transparency** - You can see exactly what will happen
4. **Modularity** - Each script does one thing well
5. **Arch-Native** - Designed specifically for Arch/CachyOS

## Quick Start

```bash
# Preview what will happen (recommended first run)
bootstrap.sh --dry-run

# Full installation with all packages and setup
bootstrap.sh

# Minimal installation (core packages only)
bootstrap.sh --minimal

# Skip setup scripts (packages only)
bootstrap.sh --skip-setup
```

## Architecture

```
~/.config/dotfiles/bootstrap/
├── packages/           # Simple package lists (just names)
│   ├── core.txt       # Essential packages (bspwm, terminal, shell)
│   ├── tools.txt      # CLI enhancements (ripgrep, fzf, etc.)
│   ├── aur.txt        # AUR packages (fonts, themes)
│   └── npm.txt        # NPM global packages
├── setup/             # Modular setup scripts
│   ├── common/        # Scripts run on all machines
│   │   ├── 01-directories.sh   # Create directory structure
│   │   ├── 03-themes.sh        # GTK themes and icons
│   │   ├── 04-fonts.sh         # Font cache update
│   │   ├── 05-shell.sh         # Set Fish as default
│   │   ├── 06-services.sh      # Enable systemd services
│   │   ├── 07-permissions.sh   # Fix file permissions
│   │   └── 08-claude-code.sh   # Configure Claude Code
│   ├── laptop/        # Laptop-specific scripts
│   │   └── 02-brightness.sh    # ThinkPad brightness control
│   └── desktop/       # Desktop-specific scripts
│       └── .placeholder        # (Future: nvidia, multi-monitor, etc.)
└── DEPENDENCIES.md    # Detailed documentation of why each package

The main script lives at: ~/.local/bin/bootstrap.sh
```

## Design Decisions

### Why Simple Package Lists?

**Before** (complex, slow, error-prone):
```bash
bspwm           # Window manager - manages window tiling (bspwmrc)
```

**After** (simple, fast, reliable):
```
bspwm
```

- Package names only, no inline comments
- Documentation lives in DEPENDENCIES.md
- Let `pacman --needed` handle detection
- No parsing bugs possible

### Why Modular Setup Scripts?

Instead of one monolithic setup script:
- Each script has a single responsibility
- Easy to debug individual components
- Can run scripts independently
- Clear execution order from filenames

### Why Not Cross-Distribution?

Supporting multiple distributions adds complexity without benefit:
- Package names differ across distributions
- System paths vary
- Service managers differ
- We use Arch/CachyOS exclusively

## How It Works

### Phase 1: Package Installation

1. **Core packages** (always installed)
   - Reads `packages/core.txt`
   - Installs via: `cat core.txt | xargs sudo pacman -S --needed`

2. **Tool packages** (unless --minimal)
   - Reads `packages/tools.txt`
   - Same installation method

3. **AUR packages** (unless --minimal)
   - Checks if yay is installed
   - Installs yay if needed
   - Installs packages via yay

4. **NPM packages** (unless --minimal)
   - Sets npm prefix to ~/.local
   - Installs global packages

### Phase 2: System Setup

1. **Machine Detection**
   - Automatically detects laptop vs desktop
   - Laptop: Has battery or backlight in `/sys/class/`
   - Desktop: No battery/backlight detected

2. **Script Execution Order**
   - Runs all scripts from `setup/common/` first
   - Then runs machine-specific scripts from `setup/laptop/` or `setup/desktop/`
   - Scripts run in alphabetical order within each directory
   - Failures show warnings but don't stop execution
   - Each script is idempotent (safe to run multiple times)

## Adding New Packages

### System Packages (pacman)
Add package name to appropriate file:
```bash
echo "package-name" >> packages/core.txt    # If essential
echo "package-name" >> packages/tools.txt   # If optional tool
```

### AUR Packages
```bash
echo "aur-package-name" >> packages/aur.txt
```

### NPM Packages
```bash
echo "@scope/package" >> packages/npm.txt
```

### Future Package Managers

The structure easily accommodates new package managers:
```bash
packages/pip.txt     # Python packages (add pip installation to bootstrap.sh)
packages/cargo.txt   # Rust packages (add cargo installation to bootstrap.sh)
packages/go.txt      # Go packages (add go installation to bootstrap.sh)
```

## Adding Setup Scripts

### For All Machines (Common)
Create script in `setup/common/`:
```bash
# setup/common/09-new-feature.sh
#!/usr/bin/env bash
# Clear description of what this does

set -euo pipefail

# Color output (copy from existing scripts)
info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }

# Check if already configured (idempotent)
if [[ -f /some/config ]]; then
    success "Already configured"
    exit 0
fi

# Do the actual setup
info "Configuring feature..."
# ... setup commands ...
success "Feature configured"
```

### For Laptop Only
Create script in `setup/laptop/`:
```bash
# setup/laptop/10-battery-management.sh
#!/usr/bin/env bash
# Configure TLP or other laptop-specific features
```

### For Desktop Only
Create script in `setup/desktop/`:
```bash
# setup/desktop/10-nvidia-drivers.sh
#!/usr/bin/env bash
# Configure GPU drivers or multi-monitor setup
```

## Machine-Specific Configuration

The bootstrap automatically detects your machine type and runs appropriate scripts:

### Detection Logic
```bash
# Detects laptop if battery or backlight exists
if [[ -d /sys/class/backlight ]] || [[ -d /sys/class/power_supply/BAT* ]]; then
    machine_type="laptop"
else
    machine_type="desktop"
fi
```

### Execution Order
1. All scripts in `setup/common/` (alphabetically)
2. All scripts in `setup/$machine_type/` (alphabetically)

### Example Desktop Setup Scripts
```
setup/desktop/
├── 01-nvidia-drivers.sh    # GPU configuration
├── 02-multi-monitor.sh     # xrandr setup
└── 03-gaming-tools.sh      # Steam, Lutris, etc.
```

### Example Laptop Setup Scripts
```
setup/laptop/
├── 01-power-management.sh  # TLP configuration
├── 02-brightness.sh         # Backlight control
└── 03-touchpad.sh          # Touchpad settings
```

## Comparison with Old System

| Aspect | Old Bootstrap | New Bootstrap |
|--------|--------------|---------------|
| Lines of code | 675 | 307 |
| Package detection | Slow bash loops | Native pacman --needed |
| Package lists | Complex parsing | Simple names |
| Setup logic | Monolithic | Modular scripts |
| Debugging | Difficult | Straightforward |
| Maintenance | Error-prone | Simple |

## Troubleshooting

### Package installation fails
- The script continues on failure (by design)
- Check network connection
- For AUR failures, try manually: `yay -S package-name`

### Setup script fails
- Run individual script to see detailed error
- Scripts are in: `~/.config/dotfiles/bootstrap/setup/`
- Each script is independent

### Dry run shows everything will be installed
- This is normal - dry run doesn't check existing packages
- Actual run uses `--needed` flag to skip existing

## Design Rationale

### Why `|| true` Everywhere?
- Personal dotfiles shouldn't fail catastrophically
- Better to have partial success than complete failure
- You can always run again or fix manually

### Why No Package Detection in Script?
- `pacman --needed` already does this efficiently
- Bash package detection was slow and buggy
- Trust the package manager

### Why Separate Package Lists from Documentation?
- Package lists are data
- Documentation is for humans
- Mixing them created parsing complexity

### Why Not Use Ansible/Chezmoi?
- Ansible is overkill for a single machine
- Chezmoi is great for dotfiles, not for packages
- Bash is sufficient for our simple needs
- No additional dependencies

## Package Categories

### Core Packages (Required)
Essential for the dotfiles to function:
- Window manager (bspwm, sxhkd)
- Terminal (alacritty)
- Shell (fish)
- Bar (polybar)
- Basic utilities

### Tools (Recommended)
Enhanced command-line experience:
- Modern replacements (ripgrep, fd, eza)
- Productivity tools (fzf, tmux)
- Development tools (git, helix)

### AUR Packages (Appearance)
Fonts and themes:
- Nerd fonts for terminal icons
- GTK themes for consistency
- Icon themes

### AI Development Tools
- Claude Code AI assistant (from AUR)
- Context7 MCP server for real-time documentation (auto-configured)

## Setup Script Details

### Common Scripts (All Machines)
| Script | Purpose | Idempotent | Required |
|--------|---------|------------|----------|
| 01-directories.sh | Create ~/Projects, etc. | ✓ | No |
| 03-themes.sh | GTK/icon themes | ✓ | No |
| 04-fonts.sh | Update font cache | ✓ | After fonts |
| 05-shell.sh | Set Fish default | ✓ | No |
| 06-services.sh | Enable PipeWire | ✓ | For audio |
| 07-permissions.sh | Fix script perms | ✓ | Yes |
| 08-claude-code.sh | Configure Claude Code + context7 MCP | ✓ | If installed |

### Laptop Scripts
| Script | Purpose | Idempotent | Required |
|--------|---------|------------|----------|
| 02-brightness.sh | ThinkPad brightness control | ✓ | Yes for laptops |

### Desktop Scripts
| Script | Purpose | Idempotent | Required |
|--------|---------|------------|----------|
| (future) | GPU drivers, multi-monitor | - | - |

## Migration from Old System

The old bootstrap system had these issues:
1. **Inline comments broke package detection** - Script tried to install `bspwm # comment` as a package
2. **Slow detection loops** - Checking each package individually in bash
3. **Complex parsing** - Regular expressions to extract package names
4. **Monolithic setup** - 567-line setup-system.sh file
5. **Hard to maintain** - Adding features increased complexity exponentially

The new system solves these by:
1. **Simple package lists** - Just names, no comments
2. **Native detection** - Let pacman handle --needed
3. **No parsing** - Direct file reading
4. **Modular scripts** - 8 focused scripts instead of 1
5. **Easy maintenance** - Add a line to add a package

## Testing

### Test Package Installation
```bash
# See what would be installed
bootstrap.sh --dry-run

# Test minimal installation
bootstrap.sh --minimal --dry-run

# Test package lists are valid
cat packages/*.txt | xargs pacman -Sp >/dev/null
```

### Test Individual Setup Scripts
```bash
# Run single setup script
~/.config/dotfiles/bootstrap/setup/01-directories.sh

# Check if script is idempotent (run twice)
~/.config/dotfiles/bootstrap/setup/05-shell.sh
~/.config/dotfiles/bootstrap/setup/05-shell.sh  # Should say "already configured"
```

## Future Improvements

Potential enhancements (not yet implemented):

1. **Machine detection**
   ```bash
   if [[ -d /sys/class/backlight ]]; then
       # Laptop-specific setup
   fi
   ```

2. **Package validation mode**
   ```bash
   bootstrap.sh --check  # Verify all packages installed
   ```

3. **Selective setup**
   ```bash
   bootstrap.sh --only-setup 05-shell.sh
   ```

4. **Better error reporting**
   ```bash
   # Track and report failed packages at end
   ```

## Contributing

When adding to this bootstrap:
1. Keep it simple
2. Make scripts idempotent
3. Document the "why" in DEPENDENCIES.md
4. Test with --dry-run first
5. Ensure Arch/CachyOS compatibility

## License

Part of pentaxis93's dotfiles - personal configuration files.