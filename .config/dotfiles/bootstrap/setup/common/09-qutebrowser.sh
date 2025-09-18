#!/usr/bin/env bash
# ============================================================================
# QUTEBROWSER USERSCRIPTS & PASSWORD MANAGER SETUP
# ============================================================================
# Purpose:
#   - Set up qutebrowser userscripts directory
#   - Install qute-bitwarden for password management
#   - Configure dependencies for enhanced browsing
#
# Dependencies (installed via tools.txt):
#   - bitwarden-cli: Password manager CLI
#   - python-tldextract: Domain parsing for qute-bitwarden
#   - python-pyperclip: Clipboard support for TOTP codes
#   - rofi: Selection UI for multiple password matches
# ============================================================================

set -euo pipefail

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warning() { echo -e "${YELLOW}[!]${RESET} $*"; }
header() { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }

header "Setting up qutebrowser userscripts"

# Create userscripts directory
USERSCRIPTS_DIR="$HOME/.local/share/qutebrowser/userscripts"
if [[ ! -d "$USERSCRIPTS_DIR" ]]; then
    mkdir -p "$USERSCRIPTS_DIR"
    success "Created userscripts directory"
else
    info "Userscripts directory already exists"
fi

# Download qute-bitwarden from official qutebrowser repository
QUTE_BITWARDEN="$USERSCRIPTS_DIR/qute-bitwarden"
if [[ ! -f "$QUTE_BITWARDEN" ]]; then
    info "Downloading qute-bitwarden userscript..."
    if curl -sS -o "$QUTE_BITWARDEN" \
        "https://raw.githubusercontent.com/qutebrowser/qutebrowser/main/misc/userscripts/qute-bitwarden"; then
        chmod +x "$QUTE_BITWARDEN"
        success "Installed qute-bitwarden userscript"
    else
        warning "Failed to download qute-bitwarden"
    fi
else
    info "qute-bitwarden already installed"
    chmod +x "$QUTE_BITWARDEN"  # Ensure it's executable
fi

# Check if Bitwarden CLI is available
if command -v bw &>/dev/null; then
    success "Bitwarden CLI is available"

    # Check if user is logged in
    if bw status 2>/dev/null | grep -q '"status":"unauthenticated"'; then
        echo
        warning "Bitwarden CLI is not logged in"
        echo -e "${CYAN}To use Bitwarden with qutebrowser:${RESET}"
        echo "  1. Login to Bitwarden:  bw login"
        echo "  2. Unlock your vault:   bw unlock"
        echo "  3. In qutebrowser, press Alt+P to fill passwords"
    else
        info "Bitwarden appears to be configured"
    fi
else
    warning "Bitwarden CLI not found - install may be pending"
fi

# Display usage information
echo
header "Qutebrowser Password Manager Setup Complete!"
echo
echo -e "${BOLD}Quick Reference:${RESET}"
echo "  • ${CYAN}Alt+P${RESET}        - Fill password for current site"
echo "  • ${CYAN}Alt+Shift+P${RESET}  - Fill TOTP/2FA code"
echo
echo -e "${BOLD}First-time setup:${RESET}"
echo "  1. Login to Bitwarden:     ${CYAN}bw login${RESET}"
echo "  2. Import Firefox passwords via Bitwarden web vault"
echo "  3. Use Alt+P in qutebrowser when on a login page"
echo
echo -e "${BOLD}Tips:${RESET}"
echo "  • Multiple matches will show a rofi selection menu"
echo "  • The session auto-locks after 15 minutes by default"
echo "  • Run 'bw unlock' if you get authentication errors"

success "Qutebrowser userscripts configuration complete"