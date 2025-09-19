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
#   - Retrieves OpenRouter API key from pass (unix password store)
#   - Updates Claude Code settings with secure configuration
#
# Dependencies:
#   - uv (from official repos)
#   - pass (unix password store)
#   - claude-code (from AUR)
#   - Python 3.10+
#
# API Keys Required:
#   - OpenRouter API key (stored in pass as 'api/openrouter')
#
# Related Files:
#   - ~/.local/bin/zen-mcp-wrapper (API key injection wrapper)
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

    # Check if pass is installed and initialized
    if ! command -v pass &>/dev/null; then
        error "Pass not installed"
        info "Run: sudo pacman -S pass"
        return 1
    fi

    if ! pass ls >/dev/null 2>&1; then
        error "Pass not initialized"
        info ""
        info "Please initialize pass with your GPG key:"
        info "1. Check GPG keys: gpg --list-secret-keys --keyid-format=long"
        info "2. Initialize pass: pass init <your-gpg-id>"
        info ""
        return 1
    fi

    # Check if API key exists in pass (without retrieving it)
    info "Checking for OpenRouter API key in pass..."
    if ! pass ls api/openrouter >/dev/null 2>&1; then
        error "OpenRouter API key not found in pass"
        info ""
        info "Please add your OpenRouter API key to pass:"
        info "1. Get your API key from: https://openrouter.ai/keys"
        info "2. Add to pass: pass insert api/openrouter"
        info "   (Enter the API key when prompted)"
        info ""
        return 1
    fi
    success "OpenRouter API key found in pass"

    # Create wrapper script for zen-mcp-server
    info "Creating zen-mcp-server wrapper script..."
    local wrapper_script="$HOME/.local/bin/zen-mcp-wrapper"

    cat > "$wrapper_script" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# Wrapper script for zen-mcp-server that retrieves API key from pass
#
# Security Note:
#   This script runs with user privileges and retrieves the API key
#   from pass (GPG-encrypted storage). The key is only exposed to
#   the zen-mcp-server process, never to Claude Code directly.

# Get API key from pass
OPENROUTER_API_KEY=$(pass show api/openrouter 2>/dev/null | head -n1)

if [[ -z "$OPENROUTER_API_KEY" ]]; then
    echo "Error: Could not retrieve OpenRouter API key from pass" >&2
    echo "Please ensure:" >&2
    echo "  1. Pass is initialized: pass init <gpg-id>" >&2
    echo "  2. API key is stored: pass insert api/openrouter" >&2
    echo "  3. GPG agent is running: gpg-connect-agent /bye" >&2
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
    info "Adding zen-mcp-server to Claude Code configuration (global)..."

    # Use claude mcp add command with user scope for global configuration
    # Capture error output for debugging
    local add_output
    if add_output=$(claude mcp add --scope user --transport stdio zen "$wrapper_script" 2>&1); then
        success "zen-mcp-server added to Claude Code global configuration"
    elif echo "$add_output" | grep -q "already exists"; then
        success "zen-mcp-server already configured in Claude Code"
    else
        warning "Could not add zen-mcp-server automatically"
        if [[ -n "$add_output" ]]; then
            info "Error details: $add_output"
        fi
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
        # Don't actually run the MCP server - just verify the API key exists in pass
        # We use 'pass ls' to check existence without retrieving (no passphrase needed)
        if pass ls api/openrouter >/dev/null 2>&1; then
            success "OpenRouter API key exists in pass"
        else
            warning "Cannot access OpenRouter API key - wrapper may fail"
            info "Ensure pass is initialized and API key is stored"
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
    info "  pass edit api/openrouter"
    info ""
    info "Note: GPG agent caches your passphrase for 8 hours (max 24)"
    info "      so you only need to unlock once per session"
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
    info "The zen-mcp-server will retrieve your API key from pass automatically"
}

# Run main
main "$@"