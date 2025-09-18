#!/usr/bin/env bash
# Set Fish as the default shell

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warning() { echo -e "${YELLOW}[!]${RESET} $*"; }
error() { echo -e "${RED}[✗]${RESET} $*" >&2; }

info "Configuring default shell..."

# Check current shell
current_shell=$(basename "$SHELL")

if [[ "$current_shell" == "fish" ]]; then
    success "Fish is already the default shell"
    exit 0
fi

# Check if Fish is installed
if ! command -v fish &>/dev/null; then
    error "Fish shell not installed"
    info "Install with: sudo pacman -S fish"
    exit 1
fi

# Get Fish path
fish_path=$(command -v fish)

# Check if Fish is in /etc/shells
if ! grep -q "^${fish_path}$" /etc/shells; then
    info "Adding Fish to /etc/shells..."
    echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
    success "Fish added to valid shells"
fi

# Change default shell
info "Changing default shell to Fish..."
if chsh -s "$fish_path"; then
    success "Default shell changed to Fish"
    info "Log out and back in for the change to take effect"
else
    error "Failed to change default shell"
    info "You can manually change it with: chsh -s $fish_path"
    exit 1
fi