#!/usr/bin/env bash
# ============================================================================
# ZEN-MCP-SERVER CONFIGURATION
# ============================================================================
# Purpose:
#   Install and configure zen-mcp-server for multi-model AI orchestration
#
# What it does:
#   - Installs uv (Python package manager) if needed
#   - Configures zen-mcp-server to run via uvx
#   - Integrates with Claude Code via MCP protocol
#   - Retrieves OpenRouter API key from Bitwarden
#   - Updates Claude Code settings with secure configuration
#
# Dependencies:
#   - uv (from official repos)
#   - bitwarden-cli (configured)
#   - claude-code (from AUR)
#   - Python 3.10+
#
# API Keys Required:
#   - OpenRouter API key (stored in Bitwarden as 'API Key - OpenRouter')
#
# Related Files:
#   - ~/.config/dotfiles/bootstrap/lib/secrets.sh (secret management)
#   - ~/.claude/settings.json (Claude Code configuration)
#   - ~/.config/dotfiles/CLAUDE.md (usage documentation)
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
    warning "Please run the Bitwarden setup first: 09-bitwarden.sh"
    exit 1
fi

# ============================================================================
# INSTALLATION
# ============================================================================
ensure_uv_installed() {
    if command -v uv &>/dev/null; then
        success "uv is already installed ($(uv --version 2>&1 | head -1))"
        return 0
    fi

    info "Installing uv (Python package manager)..."
    if sudo pacman -S --needed --noconfirm uv; then
        success "uv installed successfully"

        # Verify uvx is available
        if command -v uvx &>/dev/null || uv tool --help &>/dev/null; then
            success "uvx command available"
        else
            info "uvx is part of uv tool command"
        fi
    else
        error "Failed to install uv"
        return 1
    fi
}

# ============================================================================
# CLAUDE CODE CONFIGURATION
# ============================================================================
configure_zen_mcp() {
    info "Configuring zen-mcp-server for Claude Code..."

    # Check if Claude Code is installed
    if ! command -v claude &>/dev/null; then
        warning "Claude Code not installed, skipping MCP configuration"
        info "Install Claude Code first: yay -S claude-code"
        return 1
    fi

    # Check if API key exists in Bitwarden
    info "Checking for OpenRouter API key in Bitwarden..."
    if ! bw_get_api_key "OpenRouter" >/dev/null 2>&1; then
        error "OpenRouter API key not found in Bitwarden"
        info ""
        info "Please add your OpenRouter API key to Bitwarden:"
        info "1. Get your API key from: https://openrouter.ai/keys"
        info "2. Run: bw login (if not logged in)"
        info "3. Create item: bw create item"
        info "   Name: 'API Key - OpenRouter'"
        info "   Password: <your-api-key>"
        info "4. Sync: bw sync"
        info ""
        return 1
    fi
    success "OpenRouter API key found in Bitwarden"

    # Create wrapper script for zen-mcp-server
    info "Creating zen-mcp-server wrapper script..."
    local wrapper_script="$HOME/.local/bin/zen-mcp-wrapper"

    cat > "$wrapper_script" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# Wrapper script for zen-mcp-server that retrieves API key from Bitwarden

# Source secrets library
source ~/.config/dotfiles/bootstrap/lib/secrets.sh 2>/dev/null || {
    echo "Error: Could not load secrets library" >&2
    exit 1
}

# Get API key from Bitwarden
OPENROUTER_API_KEY=$(bw_get_api_key "OpenRouter" 2>/dev/null)

if [[ -z "$OPENROUTER_API_KEY" ]]; then
    echo "Error: Could not retrieve OpenRouter API key from Bitwarden" >&2
    echo "Please ensure you're logged in: bw login" >&2
    exit 1
fi

# Export for zen-mcp-server
export OPENROUTER_API_KEY

# Find and execute uvx
for p in $(which uvx 2>/dev/null) \
         $(which uv 2>/dev/null | xargs -I {} echo {} tool) \
         $HOME/.local/bin/uvx \
         /usr/local/bin/uvx \
         /usr/bin/uvx; do
    if [[ -x "$p" ]] || [[ "$p" == *"uv tool" ]]; then
        if [[ "$p" == *"uv tool" ]]; then
            exec uv tool run --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server "$@"
        else
            exec "$p" --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server "$@"
        fi
    fi
done

echo "Error: uvx not found" >&2
exit 1
WRAPPER_EOF

    chmod +x "$wrapper_script"
    success "Created wrapper script: $wrapper_script"

    # Configure Claude Code to use zen-mcp-server
    info "Adding zen-mcp-server to Claude Code configuration..."

    # Use claude mcp add command instead of manual JSON editing
    if claude mcp add --transport stdio zen "$wrapper_script" 2>/dev/null; then
        success "zen-mcp-server added to Claude Code"
    else
        warning "Could not add zen-mcp-server automatically"
        info "You may need to add it manually to ~/.claude/settings.json"
        show_manual_config
    fi
}

# ============================================================================
# MANUAL CONFIGURATION
# ============================================================================
show_manual_config() {
    info ""
    info "To manually configure, add this to your ~/.claude/settings.json:"
    cat << 'CONFIG_EOF'

{
  "mcpServers": {
    "zen": {
      "command": "/home/$USER/.local/bin/zen-mcp-wrapper",
      "args": [],
      "env": {
        "PATH": "/usr/local/bin:/usr/bin:/bin:~/.local/bin",
        "DEFAULT_MODEL": "auto",
        "DISABLED_TOOLS": ""
      }
    }
  }
}

CONFIG_EOF
    info ""
    info "Replace $USER with your actual username"
}

# ============================================================================
# TESTING
# ============================================================================
test_zen_mcp() {
    info "Testing zen-mcp-server installation..."

    # Test wrapper script
    if [[ -x "$HOME/.local/bin/zen-mcp-wrapper" ]]; then
        info "Testing wrapper script..."
        if timeout 5 "$HOME/.local/bin/zen-mcp-wrapper" --version 2>/dev/null; then
            success "zen-mcp-server wrapper is working"
        else
            warning "zen-mcp-server wrapper test failed (this may be normal)"
            info "The server may only respond to MCP protocol commands"
        fi
    fi

    # Test MCP connection
    if command -v claude &>/dev/null; then
        info "Checking MCP server list..."
        if claude mcp list 2>/dev/null | grep -q "zen"; then
            success "zen-mcp-server is configured in Claude Code"
        else
            warning "zen-mcp-server not found in MCP server list"
        fi
    fi
}

# ============================================================================
# USAGE INSTRUCTIONS
# ============================================================================
show_usage() {
    info ""
    info "=== zen-mcp-server Usage ==="
    info ""
    info "The server enables multi-model AI orchestration in Claude Code."
    info ""
    info "To use zen-mcp-server:"
    info "1. Start a new Claude Code session"
    info "2. Ask Claude to use multiple models for a complex task"
    info "3. Example: 'Use zen to analyze this code with multiple AI perspectives'"
    info ""
    info "Available models (via OpenRouter):"
    info "  - GPT-4, GPT-3.5"
    info "  - Claude models"
    info "  - Gemini models"
    info "  - Open source models (Llama, Mistral, etc.)"
    info ""
    info "To check server status:"
    info "  claude mcp list"
    info ""
    info "To update your OpenRouter API key:"
    info "  bw edit item 'API Key - OpenRouter'"
    info "  bw sync"
    info ""
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    info "Setting up zen-mcp-server..."

    # Ensure uv is installed
    if ! ensure_uv_installed; then
        error "Failed to install uv"
        return 1
    fi

    # Configure zen-mcp-server
    if ! configure_zen_mcp; then
        warning "zen-mcp-server configuration incomplete"
        info "Please complete the manual steps shown above"
        return 1
    fi

    # Test the installation
    test_zen_mcp

    # Show usage instructions
    show_usage

    success "zen-mcp-server setup complete!"

    # Final notes
    info ""
    info "IMPORTANT: Restart Claude Code for changes to take effect"
    info "The zen-mcp-server will retrieve your API key from Bitwarden automatically"
}

# Run main
main "$@"