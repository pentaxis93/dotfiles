#!/usr/bin/env bash
set -euo pipefail

# Configure Claude Code - installation, settings, and tools
# Runs after dotfiles are updated (no sudo required)

# Ensure Claude Code is installed/updated
if command -v claude &> /dev/null; then
    CURRENT_VERSION=$(claude --version | cut -d' ' -f1)
    echo "Claude Code v$CURRENT_VERSION found"
    # Auto-update is handled by the autoUpdates setting below
else
    echo "Installing Claude Code (native)..."
    if curl -fsSL https://claude.ai/install.sh | bash; then
        echo "✓ Claude Code installed"
    else
        echo "✗ Failed to install Claude Code"
        echo "Please install manually from https://docs.claude.com/en/docs/claude-code/installation"
        exit 1
    fi
fi

# Configure global settings
# Note: Claude CLI doesn't have a 'config set' command
# Settings are managed through ~/.claude/settings.json or command-line flags
# These lines were using invalid syntax and have been removed
# claude config set -g verbose true
# claude config set -g autoUpdates true
# claude config set -g theme dark
# claude config set -g preferredNotifChannel terminal_bell

echo "✓ Claude Code installation verified"

# Configure context7 MCP server for enhanced capabilities
# npm/npx installed by run_once_before_nodejs.sh
echo "Configuring context7 MCP server..."
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest 2>/dev/null || \
    echo "  context7 MCP server already configured"
echo "✓ context7 MCP configured"

# Configure private-journal MCP server for personal journaling
echo "Configuring private-journal MCP server..."
claude mcp add-json --scope user private-journal '{"command":"npx","args":["github:obra/private-journal-mcp"]}' 2>/dev/null || \
    echo "  private-journal MCP server already configured"
echo "✓ private-journal MCP configured"

echo "✓ Claude Code configuration complete"

# Check managed settings status
SETTINGS_FILE="/etc/claude-code/managed-settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 To install Claude Code managed settings (one-time setup), run:"
    echo "   chezmoi cd && ./scripts/setup-claude-code-managed-settings"
    echo ""
    echo "   Note: You are responsible for reviewing and maintaining"
    echo "   the content of managed settings after installation."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi