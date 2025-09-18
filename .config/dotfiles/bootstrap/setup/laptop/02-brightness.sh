#!/usr/bin/env bash
# Configure passwordless brightness control for ThinkPad

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warning() { echo -e "${YELLOW}[!]${RESET} $*"; }
error() { echo -e "${RED}[✗]${RESET} $*" >&2; }

info "Configuring brightness control..."

# Check if this is a laptop with backlight
if [[ ! -d /sys/class/backlight ]]; then
    info "No backlight detected, skipping brightness setup"
    exit 0
fi

# Find the backlight device
backlight_device=""
for device in /sys/class/backlight/*; do
    if [[ -d "$device" ]]; then
        backlight_device=$(basename "$device")
        break
    fi
done

if [[ -z "$backlight_device" ]]; then
    warning "No backlight device found"
    exit 0
fi

info "Found backlight device: $backlight_device"

# Check if already configured
RULE="${USER} ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/backlight/${backlight_device}/brightness"

if sudo grep -qF "$RULE" /etc/sudoers.d/brightness 2>/dev/null; then
    success "Brightness control already configured"
    exit 0
fi

# Setup passwordless brightness control
info "Setting up sudoers rule for brightness control..."
echo "$RULE" | sudo tee /etc/sudoers.d/brightness > /dev/null

# Validate the sudoers file
if sudo visudo -c -f /etc/sudoers.d/brightness &>/dev/null; then
    success "Brightness control configured successfully"

    # Test if brightness script exists and works
    if [[ -f ~/.local/bin/brightness ]]; then
        if ~/.local/bin/brightness get &>/dev/null; then
            success "Brightness script test passed"
        else
            warning "Brightness script test failed - check ~/.local/bin/brightness"
        fi
    fi
else
    error "Failed to configure brightness control"
    sudo rm -f /etc/sudoers.d/brightness
    exit 1
fi