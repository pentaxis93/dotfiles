# Dotfiles

Personal configuration files managed with [chezmoi](https://www.chezmoi.io/).

**OS Support**: CachyOS (Arch-based) only

## Quick Start

### Prerequisites

**IMPORTANT**: Install these packages BEFORE running `chezmoi init` or `chezmoi apply` to avoid template processing errors.

#### Essential Tools
- `chezmoi` ([installation guide](https://www.chezmoi.io/install/))
- `git`

#### Template-Time Dependencies

These packages are called during template processing and must be installed first:

**Required (Always)**:
```bash
sudo pacman -S python-colour fortune-mod
```
- `python-colour`: Waybar color spectrum generation (LAB interpolation)
- `fortune-mod`: Fortune database index generation for Zen quotes

**Optional (Only if Using Secrets)**:
```bash
sudo pacman -S bitwarden-cli
# Then login and unlock:
bw login
export BW_SESSION=$(bw unlock --raw)
```
*Why*: VPN credentials, API keys, and secure secret templating. Skip if not using VPN or AI model access features.

**Quick Install (All Prerequisites)**:
```bash
# Full feature set (with secrets support)
sudo pacman -S --needed python-colour fortune-mod bitwarden-cli

# OR minimal (skip secrets)
sudo pacman -S --needed python-colour fortune-mod
```

### Setup

```bash
# 1. Install prerequisites (see above)

# 2. Initialize from this repository
chezmoi init https://github.com/pentaxis93/dotfiles.git

# 3. Preview changes
chezmoi diff

# 4. Apply configuration (will auto-install all other packages)
chezmoi apply -v
```

**Note**: All other packages (Helix, Fish, MPV, Qutebrowser, etc.) are installed automatically during `chezmoi apply` via the package management system. Only the template-time dependencies above need manual pre-installation.

### Updates

```bash
# Pull and apply latest changes
chezmoi update -v
```

## What's Included

- **Fish Shell** — Configuration and aliases with vi mode
- **Git** — Global configuration with user templates
- **Bitwarden CLI** — Secure password management integration
- **Claude Code** — Development environment settings
- **Package Management** — Declarative system package installation
- **ZFS Time Machine** — Automated snapshots with data integrity verification

## Common Tasks

### Add a configuration

```bash
# Add a file to chezmoi management
chezmoi add ~/.config/app

# Add with automatic templating
chezmoi add --autotemplate ~/.config/app/config.toml
```

### Edit a configuration

```bash
# Edit in source directory
chezmoi edit ~/.config/fish/config.fish

# Preview changes
chezmoi diff

# Apply changes
chezmoi apply -v
```

### Manage packages

System packages are declared in `.chezmoidata/packages.yaml`:

```yaml
packages:
  cachyos:
    pacman:
      - npm
      - bitwarden-cli  # Password manager
      - ripgrep  # example: add more packages here
```

After adding packages, run `chezmoi apply` to install them.

### Manage secrets

#### Configuration Data
Non-sensitive configuration is stored in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    email = "your.email@example.com"
    github_user = "yourusername"
```

#### Secure Secrets with Bitwarden
Sensitive data is managed through Bitwarden CLI integration:

```bash
# Unlock vault (creates session)
bwu  # or: bw-unlock

# Copy password to clipboard
bwc  # or: bw-copy

# Generate secure password
bwg  # or: bw-generate --copy

# Lock vault when done
bwl  # or: bw-lock
```

Secrets are referenced in templates:
```go-template
# SSH key from secure note
{{ template "bitwarden-note.tmpl" "ssh-private-key" }}

# Password field
{{ template "bitwarden-password.tmpl" "github-pat" }}
```

See example templates in `home/private_dot_ssh/` and `home/private_dot_aws/`.

### Manage ZFS snapshots

ZFS provides automatic time-machine snapshots with data integrity verification:

```bash
# Create manual snapshot before risky changes
zsnap zpcachyos/ROOT/cos/home before-upgrade

# View snapshot timeline
zlist                              # All snapshots
zlist zpcachyos/ROOT/cos/home     # Specific dataset

# Check pool health and integrity
zfsstatus

# Clean old automatic snapshots (90 days default)
zclean       # Interactive with confirmation
zclean 30    # More aggressive cleanup
```

**Time travel** - Access any snapshot via `.zfs/snapshot/`:
```bash
# Restore deleted file from yesterday's snapshot
cp /home/.zfs/snapshot/auto-2025-09-29-15h00/pentaxis93/important.txt ~/

# Compare current vs snapshot
diff ~/.bashrc /home/.zfs/snapshot/before-upgrade/pentaxis93/.bashrc
```

**Automated schedule**:
- Every 15 minutes (keep 4) — Last hour
- Hourly (keep 24) — Last day
- Daily (keep 31) — Last month
- Weekly (keep 8) — Last 2 months
- Monthly (keep 12) — Last year

**Data integrity**: Monthly scrubs verify all checksums automatically.

## Project Structure

```
~/.local/share/chezmoi/
├── README.md                          # This file
├── CLAUDE.md                          # Development guidelines
├── .chezmoidata/
│   └── packages.yaml                  # Declarative package list
├── .chezmoitemplates/                 # Reusable templates
│   ├── bitwarden-*.tmpl               # Secret retrieval helpers
│   └── color-*.tmpl                   # Color format converters
├── dot_config/                        # XDG configs
│   ├── chezmoi/
│   │   └── chezmoi.toml.tmpl          # Chezmoi configuration
│   └── fish/
│       ├── config.fish.tmpl           # Shell configuration
│       └── functions/
│           └── bw-*.fish.tmpl         # Bitwarden utilities
├── dot_gitconfig.tmpl                 # Templated git config
├── private_dot_ssh/                   # SSH keys (examples)
├── private_dot_aws/                   # AWS credentials (examples)
├── run_onchange_install-packages.sh.tmpl  # Package installation
└── run_after_*.sh                     # Post-apply hooks
```

## File Naming Convention

- `dot_<name>` → `.name`
- `dot_<name>.tmpl` → `.name` (with templating)
- `private_<name>` → 0600 permissions
- `executable_<name>` → executable scripts
- `run_once_` → run once on first apply
- `run_onchange_` → run when file content changes
- `run_after_` → run after each apply

## Troubleshooting

### Common Errors

**Error: "No module named 'colour'"**
```bash
# Cause: python-colour not installed before chezmoi apply
# Solution: Install the missing dependency
sudo pacman -S python-colour

# Then retry
chezmoi apply -v
```

**Error: "bw: executable file not found"**
```bash
# Cause: bitwarden-cli not installed or not logged in
# Solution: Install and login to Bitwarden

sudo pacman -S bitwarden-cli
bw login  # Enter email and master password
export BW_SESSION=$(bw unlock --raw)  # Unlock vault
chezmoi apply -v

# Or skip if not using secrets (VPN/API keys) - install later when needed
```

**Error: "strfile: command not found"**
```bash
# Cause: fortune-mod not installed before chezmoi apply
# Solution: Install fortune-mod
sudo pacman -S fortune-mod
chezmoi apply -v
```

### General Debugging

```bash
# Check configuration
chezmoi doctor

# Verify managed files
chezmoi managed

# See what would change
chezmoi apply --dry-run -v
```

## Philosophy

Simplicity over complexity. Each configuration serves a clear purpose.