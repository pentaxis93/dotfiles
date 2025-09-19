#!/usr/bin/env bash
# ============================================================================
# BITWARDEN CLI CONFIGURATION
# ============================================================================
# Purpose:
#   Set up Bitwarden CLI for web password management and browser integration
#
# What it does:
#   - Ensures bitwarden-cli is installed
#   - Configures Bitwarden for first-time use
#   - Sets up secure session management for browser integration
#   - Supports qutebrowser password autofill
#
# Dependencies:
#   - bitwarden-cli (from community repo)
#
# Usage:
#   This script is run by bootstrap.sh during system setup
#   Can also be run manually: ~/.local/bin/bootstrap.sh --setup
#
# Security Notes:
#   - Never stores passwords in files
#   - Sessions expire after 30 minutes
#   - All secrets remain in Bitwarden vault
#
# Related Files:
#   - ~/.config/qutebrowser/userscripts/qute-bitwarden (browser integration)
#   - ~/.config/dotfiles/CLAUDE.md (usage documentation)
#
# Note: API keys and automation secrets are managed by pass, not Bitwarden.
#       See ADR-006 for architectural decision.
# ============================================================================

set -euo pipefail

# Import common functions if available
if [[ -f "${BASH_SOURCE%/*}/../lib/common.sh" ]]; then
    source "${BASH_SOURCE%/*}/../lib/common.sh"
else
    # Fallback definitions
    info() { echo "[INFO] $*"; }
    success() { echo "[✓] $*"; }
    warning() { echo "[!] $*"; }
    error() { echo "[✗] $*" >&2; }
fi

# Note: secrets library no longer needed as API keys moved to pass

# ============================================================================
# INSTALLATION CHECK
# ============================================================================
ensure_bitwarden_installed() {
    if command -v bw &>/dev/null; then
        success "Bitwarden CLI already installed"
        return 0
    fi

    info "Bitwarden CLI not found, it should have been installed by bootstrap"
    warning "Please ensure 'bitwarden-cli' is in your package lists"
    return 1
}

# ============================================================================
# CONFIGURATION
# ============================================================================
configure_bitwarden() {
    info "Checking Bitwarden CLI configuration..."

    # Check if already configured
    local status=$(bw status 2>/dev/null | jq -r .status 2>/dev/null || echo "error")

    case "$status" in
        "unauthenticated")
            info "Bitwarden CLI not logged in"
            info ""
            info "To complete setup:"
            info "1. Run: bw login"
            info "2. Enter your Bitwarden email and master password"
            info "3. Add your website credentials for browser autofill"
            info ""
            info "Note: API keys should be stored in pass, not Bitwarden"
            info "      Use 'pass insert api/<service>' for API keys"
            ;;
        "locked")
            success "Bitwarden CLI is configured (currently locked)"
            info "Run 'bw unlock' when you need to access secrets"
            ;;
        "unlocked")
            success "Bitwarden CLI is configured and unlocked"
            ;;
        *)
            warning "Unknown Bitwarden status: $status"
            info "You may need to configure Bitwarden manually"
            ;;
    esac
}

# ============================================================================
# HELPER SCRIPTS
# ============================================================================
# USAGE INSTRUCTIONS
# ============================================================================
show_usage_instructions() {
    info ""
    info "=== Bitwarden CLI Usage ==="
    info ""
    info "Basic commands:"
    info "  bw lock - Lock vault when done"
    info ""
    info "Example: Store website credentials:"
    info "  1. bw login (if not already logged in)"
    info "  2. Import passwords from browser or add manually"
    info "  3. bw sync"
    info ""
    info "Browser integration:"
    info "  Alt+P in qutebrowser - Autofill password for current site"
    info "  Alt+Shift+P - Fill TOTP code"
    info ""
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    info "Setting up Bitwarden CLI..."

    # Ensure bitwarden-cli is installed
    if ! ensure_bitwarden_installed; then
        error "Bitwarden CLI is required but not installed"
        info "Install with: sudo pacman -S bitwarden-cli"
        return 1
    fi

    # Configure Bitwarden
    configure_bitwarden

    # Show usage instructions
    show_usage_instructions

    # Create cache directory for sessions
    mkdir -p "$HOME/.cache"

    success "Bitwarden setup complete!"

    # Note about separation of concerns
    info ""
    info "Note: Bitwarden is for web passwords only."
    info "      For API keys and automation secrets, use pass:"
    info "      pass insert api/<service>"
}

# Run main
main "$@"