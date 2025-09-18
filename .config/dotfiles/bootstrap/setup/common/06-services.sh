#!/usr/bin/env bash
# Enable and start systemd services

set -euo pipefail

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }

info "Configuring systemd services..."

# PipeWire audio services (user services)
audio_services=(
    "pipewire.service"
    "pipewire-pulse.service"
    "wireplumber.service"
)

for service in "${audio_services[@]}"; do
    if systemctl --user is-enabled "$service" &>/dev/null; then
        info "$service is already enabled"
    else
        systemctl --user enable "$service" 2>/dev/null || true
        systemctl --user start "$service" 2>/dev/null || true
        success "Enabled and started $service"
    fi
done

# NetworkManager (system service) - if not already enabled
if command -v nmcli &>/dev/null; then
    if ! systemctl is-enabled NetworkManager &>/dev/null; then
        sudo systemctl enable NetworkManager
        sudo systemctl start NetworkManager
        success "Enabled NetworkManager"
    else
        info "NetworkManager already enabled"
    fi
fi

success "Services configured"