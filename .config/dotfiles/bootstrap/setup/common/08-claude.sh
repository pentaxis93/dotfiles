#!/usr/bin/env bash
# Configure Claude Code AI assistant

set -euo pipefail

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warning() { echo -e "${YELLOW}[!]${RESET} $*"; }

info "Checking Claude Code..."

if command -v claude &>/dev/null; then
    success "Claude Code is installed"

    # Configure notification preference
    current_notif=$(claude config get -g preferredNotifChannel 2>/dev/null || echo "auto")
    if [[ "$current_notif" != "terminal_bell" ]]; then
        claude config set -g preferredNotifChannel terminal_bell
        success "Set notification preference to terminal bell"
    else
        info "Notification preference already set correctly"
    fi

    info "Run 'claude login' if you need to authenticate"
else
    warning "Claude Code not installed"
    info "Install with: npm install -g @anthropic-ai/claude-code"
fi