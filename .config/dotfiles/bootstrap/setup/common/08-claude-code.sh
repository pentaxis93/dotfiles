#!/usr/bin/env bash
# ============================================================================
# CLAUDE CODE CONFIGURATION
# ============================================================================
# Purpose:
#   Configure Claude Code with useful MCP servers
#
# What it does:
#   - Sets up context7 MCP server for up-to-date documentation
#   - Only runs if Claude Code is installed
#   - Idempotent (safe to run multiple times)
#
# Dependencies:
#   - claude-code (from AUR)
#
# Related Files:
#   - ~/.claude/settings.json (user preferences)
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
# CONFIGURE CONTEXT7
# ============================================================================
configure_context7() {
    info "Configuring context7 MCP server for documentation lookup..."

    # Check if context7 is already configured
    if claude mcp list 2>/dev/null | grep -q "context7"; then
        success "context7 MCP server already configured"
        return 0
    fi

    # Add context7 MCP server (no API key needed for free tier)
    if claude mcp add --transport http context7 https://mcp.context7.com/mcp; then
        success "context7 MCP server configured successfully"
        info "Use 'use context7' in prompts to get up-to-date documentation"
    else
        warning "Failed to configure context7 MCP server"
        return 1
    fi
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    # Check if Claude Code is installed
    if ! command -v claude &>/dev/null; then
        info "Claude Code not installed, skipping configuration"
        return 0
    fi

    info "Configuring Claude Code..."

    # Configure MCP servers
    configure_context7

    success "Claude Code configuration complete"

    # Provide usage hint
    info "Tip: When you need accurate documentation, add 'use context7' to your prompts"
    info "Example: 'use context7 to get the latest tmux configuration options'"
}

# Run main
main "$@"