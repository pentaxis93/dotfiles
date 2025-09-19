#!/usr/bin/env bash
# ============================================================================
# COMMON BOOTSTRAP LIBRARY
# ============================================================================
# Purpose:
#   Shared functions for bootstrap setup scripts
#
# Usage:
#   source this file from setup scripts to get common functions
# ============================================================================

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Output functions
info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warning() { echo -e "${YELLOW}[!]${RESET} $*"; }
error() { echo -e "${RED}[✗]${RESET} $*" >&2; }
header() { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if package is installed
package_installed() {
    pacman -Q "$1" &>/dev/null 2>&1
}

# Create directory with proper permissions
create_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        info "Created directory: $dir"
    fi
}

# Backup file before modifying
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        info "Backed up $file to $backup"
    fi
}

# Create symlink safely
create_symlink() {
    local source="$1"
    local target="$2"

    if [[ -L "$target" ]]; then
        info "Symlink already exists: $target"
    elif [[ -f "$target" ]]; then
        warning "File exists at target: $target (skipping symlink)"
    else
        ln -s "$source" "$target"
        success "Created symlink: $target -> $source"
    fi
}

# Enable systemd service
enable_service() {
    local service="$1"
    local user_flag="${2:-}"  # Optional --user flag

    if [[ "$user_flag" == "--user" ]]; then
        if systemctl --user is-enabled "$service" &>/dev/null; then
            info "Service already enabled: $service (user)"
        else
            systemctl --user enable "$service"
            success "Enabled user service: $service"
        fi
    else
        if systemctl is-enabled "$service" &>/dev/null; then
            info "Service already enabled: $service"
        else
            sudo systemctl enable "$service"
            success "Enabled service: $service"
        fi
    fi
}

# Start systemd service
start_service() {
    local service="$1"
    local user_flag="${2:-}"  # Optional --user flag

    if [[ "$user_flag" == "--user" ]]; then
        if systemctl --user is-active "$service" &>/dev/null; then
            info "Service already running: $service (user)"
        else
            systemctl --user start "$service"
            success "Started user service: $service"
        fi
    else
        if systemctl is-active "$service" &>/dev/null; then
            info "Service already running: $service"
        else
            sudo systemctl start "$service"
            success "Started service: $service"
        fi
    fi
}

# Install AUR package with yay
install_aur_package() {
    local package="$1"

    if package_installed "$package"; then
        info "$package is already installed"
    else
        info "Installing $package from AUR..."
        yay -S --needed --noconfirm "$package"
        success "$package installed"
    fi
}

# Check for required environment variables
require_env() {
    local var_name="$1"
    local var_value="${!var_name:-}"

    if [[ -z "$var_value" ]]; then
        error "Required environment variable not set: $var_name"
        return 1
    fi
}

# Export common paths
export DOTFILES_DIR="$HOME/.config/dotfiles"
export BOOTSTRAP_DIR="$DOTFILES_DIR/bootstrap"
export CONFIG_DIR="$HOME/.config"