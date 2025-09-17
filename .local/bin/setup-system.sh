#!/usr/bin/env bash

# ============================================================================
# SYSTEM SETUP SCRIPT
# ============================================================================
# Purpose:
#   Configure system settings after package installation. This script handles
#   all the post-installation setup that can't be done through package
#   installation alone.
#
# How it works:
#   1. Sets up passwordless brightness control (ThinkPad)
#   2. Configures GTK themes and icons
#   3. Updates font cache
#   4. Sets default shell to Fish
#   5. Configures systemd services
#   6. Creates necessary directories
#
# Dependencies:
#   - sudo privileges for system configurations
#   - Packages should be installed first (run bootstrap.sh)
#
# Usage:
#   setup-system.sh [OPTIONS]
#
# Options:
#   -h, --help      Show this help message
#   -y, --yes       Skip confirmation prompts
#   -v, --verbose   Show detailed output
#
# Examples:
#   setup-system.sh           # Interactive setup
#   setup-system.sh --yes     # Non-interactive (accept all)
#
# Exit codes:
#   0 - Success
#   1 - General failure
#   2 - Missing dependencies
#   3 - User cancelled
#
# Related files:
#   ~/.local/bin/bootstrap.sh    - Package installation script
#   ~/.config/bootstrap/*        - Package lists
#   ~/CLAUDE.md                  - System documentation
#
# Author: pentaxis93's dotfiles
# ============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# COLOR OUTPUT FUNCTIONS
# ============================================================================
# Consistent colored output for better readability

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    RESET=''
fi

info() {
    echo -e "${BLUE}[INFO]${RESET} $*"
}

success() {
    echo -e "${GREEN}[✓]${RESET} $*"
}

warning() {
    echo -e "${YELLOW}[!]${RESET} $*"
}

error() {
    echo -e "${RED}[✗]${RESET} $*" >&2
}

header() {
    echo -e "\n${BOLD}${CYAN}==> $*${RESET}"
}

# ============================================================================
# CONFIGURATION VARIABLES
# ============================================================================

SKIP_CONFIRM=false
VERBOSE=false
BRIGHTNESS_CONFIGURED=false
THEMES_CONFIGURED=false
SHELL_CONFIGURED=false
SERVICES_CONFIGURED=false
CLAUDE_CONFIGURED=false

# ============================================================================
# HELP FUNCTION
# ============================================================================

show_help() {
    sed -n '/^# Usage:/,/^# Author:/p' "$0" | grep -v '^# Author:' | sed 's/^# //'
    exit 0
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -y|--yes)
            SKIP_CONFIRM=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# CONFIRMATION HELPER
# ============================================================================
# Ask for user confirmation unless --yes flag is used

confirm() {
    local prompt="$1"

    if [[ "$SKIP_CONFIRM" == true ]]; then
        return 0
    fi

    read -p "$prompt (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# ============================================================================
# BRIGHTNESS CONTROL SETUP
# ============================================================================
# Configure passwordless brightness control for ThinkPad laptops
# This allows the brightness keys to work without password prompts

setup_brightness_control() {
    header "Configuring brightness control"

    # Check if this is a laptop with backlight
    if [[ ! -d /sys/class/backlight ]]; then
        info "No backlight detected, skipping brightness setup"
        return 0
    fi

    # Find the backlight device
    local backlight_device=""
    for device in /sys/class/backlight/*; do
        if [[ -d "$device" ]]; then
            backlight_device=$(basename "$device")
            break
        fi
    done

    if [[ -z "$backlight_device" ]]; then
        warning "No backlight device found"
        return 0
    fi

    info "Found backlight device: $backlight_device"

    # Check if brightness control is already configured
    if sudo grep -q "backlight/${backlight_device}/brightness" /etc/sudoers.d/brightness 2>/dev/null; then
        success "Brightness control already configured"
        BRIGHTNESS_CONFIGURED=true
        return 0
    fi

    # Setup passwordless brightness control
    if confirm "Configure passwordless brightness control?"; then
        info "Setting up sudoers rule for brightness control..."

        # Create the sudoers rule
        # This allows the user to write to the brightness file without password
        echo "${USER} ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/backlight/${backlight_device}/brightness" | \
            sudo tee /etc/sudoers.d/brightness > /dev/null

        # Validate the sudoers file
        if sudo visudo -c -f /etc/sudoers.d/brightness &>/dev/null; then
            success "Brightness control configured successfully"
            BRIGHTNESS_CONFIGURED=true

            # Test the configuration
            if [[ -f ~/.local/bin/brightness ]]; then
                info "Testing brightness control..."
                if ~/.local/bin/brightness get &>/dev/null; then
                    success "Brightness control test passed"
                else
                    warning "Brightness script test failed - check ~/.local/bin/brightness"
                fi
            fi
        else
            error "Failed to configure brightness control"
            sudo rm -f /etc/sudoers.d/brightness
            return 1
        fi
    else
        info "Skipping brightness control setup"
    fi
}

# ============================================================================
# GTK THEME SETUP
# ============================================================================
# Configure GTK theme and icons for consistent appearance

setup_themes() {
    header "Configuring themes and icons"

    # Check if required packages are installed
    local missing_deps=()
    command -v gsettings &>/dev/null || missing_deps+=("gsettings")
    command -v papirus-folders &>/dev/null || missing_deps+=("papirus-folders")

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        warning "Missing theme dependencies: ${missing_deps[*]}"
        info "Run bootstrap.sh first to install required packages"
        return 1
    fi

    # Set GTK theme
    if confirm "Configure Gruvbox GTK theme?"; then
        info "Setting GTK theme..."

        # Check if theme is installed
        if [[ -d /usr/share/themes/Gruvbox-Dark ]] || \
           [[ -d ~/.themes/Gruvbox-Dark ]] || \
           [[ -d /usr/share/themes/Gruvbox-Material-Dark ]]; then

            # Set GTK theme using gsettings
            gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Dark" 2>/dev/null || \
            gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Material-Dark" 2>/dev/null || \
            warning "Failed to set GTK theme via gsettings"

            # Also set in GTK config files for non-GNOME applications
            mkdir -p ~/.config/gtk-3.0
            if [[ ! -f ~/.config/gtk-3.0/settings.ini ]]; then
                cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Gruvbox-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-application-prefer-dark-theme=1
EOF
                success "Created GTK 3.0 settings"
            fi

            success "GTK theme configured"
        else
            warning "Gruvbox theme not installed - install with bootstrap.sh"
        fi
    fi

    # Configure icon theme
    if confirm "Configure Papirus icons with teal folders?"; then
        info "Setting icon theme..."

        # Set icon theme
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || \
        warning "Failed to set icon theme via gsettings"

        # Change folder color to teal (matches our cyan accent)
        if command -v papirus-folders &>/dev/null; then
            papirus-folders -C teal
            success "Papirus folders set to teal"
        else
            warning "papirus-folders not found"
        fi

        success "Icon theme configured"
    fi

    THEMES_CONFIGURED=true
}

# ============================================================================
# FONT CACHE UPDATE
# ============================================================================
# Update font cache to ensure newly installed fonts are available

update_font_cache() {
    header "Updating font cache"

    if command -v fc-cache &>/dev/null; then
        info "Rebuilding font cache..."
        fc-cache -fv &>/dev/null
        success "Font cache updated"

        # Verify Nerd Fonts are available
        if fc-list | grep -qi "meslo.*nerd" &>/dev/null; then
            success "Nerd Fonts detected"
        else
            warning "Nerd Fonts not detected - terminal may not display icons correctly"
        fi
    else
        warning "fc-cache not found, skipping font cache update"
    fi
}

# ============================================================================
# SHELL CONFIGURATION
# ============================================================================
# Set Fish as the default shell if it's not already

setup_default_shell() {
    header "Configuring default shell"

    # Check current shell
    local current_shell=$(basename "$SHELL")

    if [[ "$current_shell" == "fish" ]]; then
        success "Fish is already the default shell"
        SHELL_CONFIGURED=true
        return 0
    fi

    # Check if Fish is installed
    if ! command -v fish &>/dev/null; then
        error "Fish shell not installed"
        info "Run bootstrap.sh to install Fish"
        return 1
    fi

    # Get Fish path
    local fish_path=$(command -v fish)

    # Check if Fish is in /etc/shells
    if ! grep -q "^${fish_path}$" /etc/shells; then
        warning "Fish not in /etc/shells, adding it..."
        echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
    fi

    # Change default shell
    if confirm "Change default shell to Fish?"; then
        info "Changing default shell to Fish..."

        if chsh -s "$fish_path"; then
            success "Default shell changed to Fish"
            info "You'll need to log out and back in for the change to take effect"
            SHELL_CONFIGURED=true
        else
            error "Failed to change default shell"
            return 1
        fi
    else
        info "Keeping current shell: $current_shell"
    fi
}

# ============================================================================
# SYSTEMD SERVICES
# ============================================================================
# Enable and start necessary systemd services

setup_services() {
    header "Configuring systemd services"

    # PipeWire audio services (user services)
    local audio_services=(
        "pipewire.service"
        "pipewire-pulse.service"
        "wireplumber.service"
    )

    info "Checking audio services..."

    for service in "${audio_services[@]}"; do
        if systemctl --user is-enabled "$service" &>/dev/null; then
            [[ "$VERBOSE" == true ]] && info "$service is already enabled"
        else
            if confirm "Enable $service?"; then
                systemctl --user enable "$service"
                systemctl --user start "$service"
                success "Enabled and started $service"
            fi
        fi
    done

    SERVICES_CONFIGURED=true
}

# ============================================================================
# CREATE DIRECTORIES
# ============================================================================
# Ensure necessary directories exist

create_directories() {
    header "Creating necessary directories"

    local dirs=(
        "$HOME/.config"
        "$HOME/.local/bin"
        "$HOME/.local/share"
        "$HOME/.cache"
        "$HOME/Documents"
        "$HOME/Downloads"
        "$HOME/Pictures"
        "$HOME/Projects"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            [[ "$VERBOSE" == true ]] && success "Created $dir"
        else
            [[ "$VERBOSE" == true ]] && info "$dir already exists"
        fi
    done

    success "Directory structure ready"
}

# ============================================================================
# DOTFILES PERMISSIONS
# ============================================================================
# Ensure correct permissions on configuration files

fix_permissions() {
    header "Fixing file permissions"

    # Make scripts executable
    local scripts=(
        "$HOME/.local/bin/bootstrap.sh"
        "$HOME/.local/bin/setup-system.sh"
        "$HOME/.local/bin/brightness"
        "$HOME/.config/bspwm/bspwmrc"
        "$HOME/.config/bspwm/polybar-autohide.sh"
        "$HOME/.config/polybar/launch.sh"
    )

    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            chmod +x "$script"
            [[ "$VERBOSE" == true ]] && success "Made executable: $script"
        fi
    done

    # Ensure proper permissions on config directories
    chmod 700 "$HOME/.config" 2>/dev/null || true
    chmod 700 "$HOME/.local" 2>/dev/null || true

    success "File permissions fixed"
}

# ============================================================================
# PRINT SUMMARY
# ============================================================================
# Display what was configured

print_summary() {
    header "Setup Summary"

    echo -e "${BOLD}Configured:${RESET}"
    [[ "$BRIGHTNESS_CONFIGURED" == true ]] && echo "  ✓ Brightness control"
    [[ "$THEMES_CONFIGURED" == true ]] && echo "  ✓ GTK themes and icons"
    [[ "$SHELL_CONFIGURED" == true ]] && echo "  ✓ Default shell (Fish)"
    [[ "$SERVICES_CONFIGURED" == true ]] && echo "  ✓ System services"
    [[ "$CLAUDE_CONFIGURED" == true ]] && echo "  ✓ Claude Code AI assistant"

    echo
    echo -e "${BOLD}Next steps:${RESET}"
    echo "  1. Log out and back in for shell changes to take effect"
    echo "  2. Run 'dots status' to check your dotfiles"
    echo "  3. Restart BSPWM with Super+Alt+R to apply all configurations"

    if [[ ! -f "$HOME/.config/fish/local.fish" ]]; then
        echo
        info "Tip: Create ~/.config/fish/local.fish for machine-specific settings"
    fi
}

# ============================================================================
# SETUP CLAUDE CODE
# ============================================================================
# Verify Claude Code installation (configs are tracked directly in dotfiles)

setup_claude_code() {
    header "Checking Claude Code"

    if command -v claude &> /dev/null; then
        success "Claude Code is installed"
        info "Run 'claude login' if you need to authenticate"
        CLAUDE_CONFIGURED=true
    else
        warning "Claude Code not installed"
        info "Install with: npm install -g @anthropic-ai/claude-code"
        CLAUDE_CONFIGURED=false
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo -e "${BOLD}${CYAN}"
    echo "╔════════════════════════════════════╗"
    echo "║      SYSTEM SETUP SCRIPT           ║"
    echo "╚════════════════════════════════════╝"
    echo -e "${RESET}"

    # Check for sudo access upfront
    if ! sudo -n true 2>/dev/null; then
        warning "This script requires sudo privileges for some operations"
        sudo true || exit 3
    fi

    # Run setup functions
    create_directories
    setup_brightness_control
    setup_themes
    update_font_cache
    setup_default_shell
    setup_services
    setup_claude_code
    fix_permissions

    # Print summary
    print_summary

    echo
    success "System setup completed!"
    exit 0
}

# Run main function
main "$@"