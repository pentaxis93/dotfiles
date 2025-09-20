#!/usr/bin/env bash
# ============================================================================
# MPV SCRIPTS SETUP
# ============================================================================
# Installs essential mpv Lua scripts for enhanced functionality
#
# Scripts installed:
#   - mpv-file-browser: Text-based file browser within mpv
#
# Related Files:
#   ~/.config/mpv/mpv.conf - Main mpv configuration
#   ~/.config/mpv/input.conf - Custom keybindings
# ============================================================================

set -euo pipefail

# Color output (simple version for setup scripts)
info() { echo "[INFO] $*"; }
success() { echo "[✓] $*"; }
warning() { echo "[!] $*"; }
error() { echo "[✗] $*" >&2; }

# Configuration
MPV_CONFIG_DIR="$HOME/.config/mpv"
SCRIPTS_DIR="$MPV_CONFIG_DIR/scripts"

# ============================================================================
# INSTALL MPV-FILE-BROWSER
# ============================================================================
install_file_browser() {
    local target_dir="$SCRIPTS_DIR/file-browser"

    info "Installing mpv-file-browser script..."

    # Create scripts directory if it doesn't exist
    if [[ ! -d "$SCRIPTS_DIR" ]]; then
        mkdir -p "$SCRIPTS_DIR"
        info "Created mpv scripts directory"
    fi

    # Check if already installed
    if [[ -d "$target_dir" ]]; then
        info "mpv-file-browser already installed, updating..."
        cd "$target_dir"
        if git pull; then
            success "mpv-file-browser updated"
        else
            warning "Failed to update mpv-file-browser (continuing...)"
        fi
        return 0
    fi

    # Clone the repository
    if git clone https://github.com/CogentRedTester/mpv-file-browser.git "$target_dir"; then
        success "mpv-file-browser installed"
    else
        error "Failed to install mpv-file-browser"
        return 1
    fi
}

# ============================================================================
# CONFIGURE KEYBINDING
# ============================================================================
configure_keybinding() {
    local input_conf="$MPV_CONFIG_DIR/input.conf"
    local keybinding="MENU script-binding browse-files"

    info "Configuring file browser keybinding..."

    # Check if keybinding already exists
    if [[ -f "$input_conf" ]] && grep -q "script-binding browse-files" "$input_conf"; then
        info "File browser keybinding already configured"
        return 0
    fi

    # Add keybinding to input.conf
    if [[ -f "$input_conf" ]]; then
        echo "" >> "$input_conf"
        echo "# ============================================================================" >> "$input_conf"
        echo "# FILE BROWSER SCRIPT" >> "$input_conf"
        echo "# ============================================================================" >> "$input_conf"
        echo "# Access the text-based file browser for selecting videos within mpv" >> "$input_conf"
        echo "" >> "$input_conf"
        echo "$keybinding            # Open file browser interface" >> "$input_conf"
        echo "                           # WHY: MENU key is rarely used and intuitive" >> "$input_conf"
        echo "                           # Alternative: Tab key if MENU not available" >> "$input_conf"
        echo "Tab script-binding browse-files  # Alternative file browser binding" >> "$input_conf"
        echo "                           # WHY: Tab is accessible on all keyboards" >> "$input_conf"

        success "File browser keybinding added to input.conf"
    else
        warning "input.conf not found, skipping keybinding configuration"
    fi
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    echo "Setting up mpv scripts..."

    # Check if mpv is installed
    if ! command -v mpv &>/dev/null; then
        warning "mpv not found, skipping script installation"
        return 0
    fi

    # Install file browser script
    if install_file_browser; then
        configure_keybinding
        success "mpv scripts setup complete"
    else
        error "mpv scripts setup failed"
        return 1
    fi

    info "File browser accessible with MENU or Tab key in mpv"
}

# Run main function
main "$@"