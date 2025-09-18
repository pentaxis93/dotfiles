#!/usr/bin/env bash
# Update font cache for newly installed fonts

set -euo pipefail

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warning() { echo -e "${YELLOW}[!]${RESET} $*"; }

info "Updating font cache..."

if command -v fc-cache &>/dev/null; then
    fc-cache -fv &>/dev/null
    success "Font cache updated"

    # Verify Nerd Fonts are available
    if fc-list | grep -qi "meslo.*nerd" &>/dev/null; then
        success "Nerd Fonts detected"
    else
        warning "Nerd Fonts not detected - terminal may not display icons correctly"
        info "Install with: yay -S ttf-meslo-nerd-font-powerlevel10k"
    fi
else
    warning "fc-cache not found, skipping font cache update"
fi