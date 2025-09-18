#!/usr/bin/env bash
# Create necessary directories for dotfiles environment

set -euo pipefail

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }

info "Creating directory structure..."

# Essential directories
directories=(
    "$HOME/.config"
    "$HOME/.local/bin"
    "$HOME/.local/share"
    "$HOME/.cache"
    "$HOME/Documents"
    "$HOME/Downloads"
    "$HOME/Pictures"
    "$HOME/Projects"
)

for dir in "${directories[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        success "Created $dir"
    fi
done

success "Directory structure ready"