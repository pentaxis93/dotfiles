#!/usr/bin/env bash
# Fix file permissions for scripts and configs

set -euo pipefail

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }

info "Fixing file permissions..."

# Make scripts executable
scripts=(
    "$HOME/.local/bin/bootstrap.sh"
    "$HOME/.local/bin/setup-system.sh"
    "$HOME/.local/bin/brightness"
    "$HOME/.config/bspwm/bspwmrc"
    "$HOME/.config/bspwm/polybar-autohide.sh"
    "$HOME/.config/polybar/launch.sh"
    "$HOME/.config/polybar/scripts/window-title-daemon.sh"
)

for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
        chmod +x "$script"
    fi
done

# Make all setup scripts executable
for script in "$HOME/.config/dotfiles/bootstrap/setup/"*.sh; do
    if [[ -f "$script" ]]; then
        chmod +x "$script"
    fi
done

# Ensure proper permissions on config directories
chmod 700 "$HOME/.config" 2>/dev/null || true
chmod 700 "$HOME/.local" 2>/dev/null || true

success "File permissions fixed"