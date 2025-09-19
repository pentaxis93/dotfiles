#!/usr/bin/env bash
# ============================================================================
# PASS PASSWORD MANAGER SETUP
# ============================================================================
# Purpose:
#   Configure pass (the standard unix password manager) for secure secret
#   storage with GPG encryption and agent caching.
#
# How it works:
#   - Installs pass package if not present
#   - Configures GPG agent for 8-24 hour passphrase caching
#   - Sets up pinentry for terminal use (no GUI dependencies)
#   - Creates directory structure for organized secret storage
#
# Dependencies:
#   - gnupg (for GPG key management)
#   - pass (the password store)
#   - pinentry-curses (terminal-based PIN entry)
#
# Security Model:
#   - Pass for automation secrets (API keys, tokens)
#   - Bitwarden CLI for web passwords only
#   - No overlap between the two systems
#
# Post-Install Steps (User must do manually):
#   1. Generate GPG key if needed: gpg --gen-key
#   2. Initialize pass: pass init <your-gpg-id>
#   3. Add secrets: pass insert api/openrouter
# ============================================================================

set -euo pipefail

source "$(dirname "$0")/../../lib/common.sh"

info "Setting up Pass Password Manager"

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================
info "Checking if pass is installed..."
if ! command -v pass &>/dev/null; then
    info "Installing pass (gnupg and pinentry will be pulled as dependencies)..."
    if sudo pacman -S --needed --noconfirm pass; then
        success "Pass installed successfully"
    else
        error "Failed to install pass"
        return 1
    fi
else
    success "Pass is already installed"
fi

# ============================================================================
# GPG AGENT CONFIGURATION
# ============================================================================
info "Configuring GPG agent for extended cache duration..."

# Create GPG directory if it doesn't exist
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg

# Configure GPG agent with 8-24 hour cache
# - default-cache-ttl: 8 hours (28800 seconds)
# - max-cache-ttl: 24 hours (86400 seconds)
cat > ~/.gnupg/gpg-agent.conf << 'EOF'
# Cache passphrase for 8 hours by default
default-cache-ttl 28800

# Maximum cache time of 24 hours
max-cache-ttl 86400

# Use auto-detecting pinentry (chooses GUI or terminal based on environment)
# This allows GUI pinentry when available (for Claude Code) and falls back to
# terminal when in SSH or console sessions
pinentry-program /usr/bin/pinentry

# Enable SSH support (optional, useful for SSH keys via GPG)
enable-ssh-support
EOF

# Set proper permissions
chmod 600 ~/.gnupg/gpg-agent.conf

# Reload GPG agent to apply new settings
# Note: This will clear any cached passphrases
if gpg-connect-agent reloadagent /bye 2>/dev/null; then
    success "GPG agent reloaded with new cache settings"
    info "Note: Any cached passphrases have been cleared"
else
    info "GPG agent will use new settings on next start"
fi

# ============================================================================
# PASS DIRECTORY STRUCTURE
# ============================================================================
info "Creating pass directory structure..."

# Pass stores everything in ~/.password-store
# We'll create a logical structure for different secret types
# (These directories will be created when secrets are added)
cat > ~/.local/bin/pass-structure-guide << 'EOF'
#!/usr/bin/env bash
# Pass directory structure guide
#
# Recommended organization:
#   api/          - API keys for services
#   tokens/       - Authentication tokens
#   ssh/          - SSH keys and passphrases
#   services/     - Service-specific credentials
#   personal/     - Personal non-web passwords
#
# Examples:
#   pass insert api/openrouter
#   pass insert api/github
#   pass insert tokens/npm
#   pass insert services/database
#
# Web passwords should remain in Bitwarden for browser integration
EOF
chmod +x ~/.local/bin/pass-structure-guide

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================
info "Creating pass helper functions..."

# Create a fish function for quick API key retrieval
mkdir -p ~/.config/fish/functions
cat > ~/.config/fish/functions/get-api-key.fish << 'EOF'
function get-api-key --description "Retrieve an API key from pass"
    if test (count $argv) -eq 0
        echo "Usage: get-api-key <service>"
        echo "Example: get-api-key openrouter"
        return 1
    end

    set -l service $argv[1]
    set -l key_path "api/$service"

    # Check if key exists
    if not pass show $key_path >/dev/null 2>&1
        echo "API key for '$service' not found in pass" >&2
        echo "Add it with: pass insert api/$service" >&2
        return 1
    end

    # Return the key (single line, no output)
    pass show $key_path 2>/dev/null | head -n1
end
EOF

# ============================================================================
# POST-INSTALL INSTRUCTIONS
# ============================================================================
echo ""
warning "=== Manual Setup Required ==="
echo ""
echo "Pass has been installed and configured, but you need to:"
echo ""
echo "1. Check if you have a GPG key:"
info "   gpg --list-secret-keys --keyid-format=long"
echo ""
echo "2. If no key exists, generate one:"
info "   gpg --gen-key"
echo "   (Choose RSA and RSA, 4096 bits, 2y expiry)"
echo ""
echo "3. Initialize pass with your GPG key ID:"
info "   pass init <your-gpg-id>"
echo ""
echo "4. Add your OpenRouter API key:"
info "   pass insert api/openrouter"
echo "   (Enter the API key when prompted)"
echo ""
echo "5. Test retrieval:"
info "   pass show api/openrouter"
echo ""
success "Pass setup complete!"
echo ""
info "GPG agent will cache your passphrase for 8 hours (max 24 hours)"
info "Use 'pass-structure-guide' to see recommended organization"