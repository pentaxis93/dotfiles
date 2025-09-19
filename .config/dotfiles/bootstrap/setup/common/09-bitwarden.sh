#!/usr/bin/env bash
# ============================================================================
# BITWARDEN CLI CONFIGURATION
# ============================================================================
# Purpose:
#   Set up Bitwarden CLI for secure API key and credential management
#
# What it does:
#   - Ensures bitwarden-cli is installed
#   - Configures Bitwarden for first-time use
#   - Sets up secure session management
#   - Creates example entries for API keys
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
#   - ~/.config/dotfiles/bootstrap/lib/secrets.sh (shared functions)
#   - ~/.config/dotfiles/bootstrap/setup/common/10-zen-mcp.sh (uses secrets)
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

# Import secrets library
SECRETS_LIB="${BASH_SOURCE%/*}/../../lib/secrets.sh"
if [[ -f "$SECRETS_LIB" ]]; then
    source "$SECRETS_LIB"
else
    error "Secrets library not found at $SECRETS_LIB"
    exit 1
fi

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
            info "To complete setup, you need to:"
            info "1. Run: bw login"
            info "2. Enter your Bitwarden email and master password"
            info "3. Create items in your vault named:"
            info "   - 'API Key - OpenRouter' (for zen-mcp-server)"
            info "   - Any other API keys you want to manage"
            info ""
            info "Items should have the API key in either:"
            info "   - The password field, OR"
            info "   - A custom field named 'api_key'"
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
create_helper_scripts() {
    info "Creating Bitwarden helper scripts..."

    # Create a simple script to retrieve API keys
    local helper_script="$HOME/.local/bin/bw-get-api-key"
    cat > "$helper_script" << 'EOF'
#!/usr/bin/env bash
# Quick helper to get API keys from Bitwarden

if [[ -z "$1" ]]; then
    echo "Usage: bw-get-api-key <service-name>"
    echo "Example: bw-get-api-key OpenRouter"
    exit 1
fi

# Source the secrets library
source ~/.config/dotfiles/bootstrap/lib/secrets.sh 2>/dev/null || {
    echo "Error: Could not load secrets library" >&2
    exit 1
}

# Get and output the API key
bw_get_api_key "$1"
EOF

    chmod +x "$helper_script"
    success "Created helper script: $helper_script"

    # Create session cleanup script
    local cleanup_script="$HOME/.local/bin/bw-cleanup"
    cat > "$cleanup_script" << 'EOF'
#!/usr/bin/env bash
# Clean up Bitwarden session

rm -f ~/.cache/bw-session
unset BW_SESSION
bw lock 2>/dev/null
echo "Bitwarden session cleaned up and vault locked"
EOF

    chmod +x "$cleanup_script"
    success "Created cleanup script: $cleanup_script"
}

# ============================================================================
# USAGE INSTRUCTIONS
# ============================================================================
show_usage_instructions() {
    info ""
    info "=== Bitwarden CLI Usage ==="
    info ""
    info "Helper commands available:"
    info "  bw-get-api-key <service>  - Retrieve API key for a service"
    info "  bw-cleanup                - Lock vault and clean session"
    info ""
    info "Example: Store OpenRouter API key:"
    info "  1. bw login (if not already logged in)"
    info "  2. bw create item --name 'API Key - OpenRouter'"
    info "  3. Add your API key to the password field"
    info "  4. bw sync"
    info ""
    info "Example: Retrieve OpenRouter API key:"
    info "  bw-get-api-key OpenRouter"
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

    # Create helper scripts
    create_helper_scripts

    # Show usage instructions
    show_usage_instructions

    # Create cache directory for sessions
    mkdir -p "$HOME/.cache"

    success "Bitwarden setup complete!"

    # Note about next steps
    info ""
    info "IMPORTANT: Before running zen-mcp setup, ensure you have:"
    info "1. Logged into Bitwarden: bw login"
    info "2. Created 'API Key - OpenRouter' item with your OpenRouter API key"
    info "3. Synced your vault: bw sync"
}

# Run main
main "$@"