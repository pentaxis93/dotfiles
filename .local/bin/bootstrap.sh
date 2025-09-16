#!/usr/bin/env bash

# ============================================================================
# DOTFILES BOOTSTRAP SCRIPT
# ============================================================================
# Purpose:
#   Automated installation of all packages required for the dotfiles to work
#   properly. Handles both official repository and AUR packages intelligently.
#
# How it works:
#   1. Reads package lists from ~/.config/dotfiles/bootstrap/
#   2. Checks which packages are already installed
#   3. Installs missing packages in batches
#   4. Runs post-installation setup if requested
#
# Dependencies:
#   - pacman (system package manager)
#   - yay (AUR helper) - will be installed if missing
#   - git (for yay installation if needed)
#
# Usage:
#   bootstrap.sh [OPTIONS]
#
# Options:
#   -h, --help      Show this help message
#   -m, --minimal   Install core packages only
#   -d, --dry-run   Show what would be installed without installing
#   -s, --setup     Run system setup after package installation
#   -v, --verbose   Show detailed output
#   -f, --force     Reinstall even if packages exist
#
# Examples:
#   bootstrap.sh              # Full installation
#   bootstrap.sh --minimal    # Core packages only
#   bootstrap.sh --dry-run    # Preview what would be installed
#   bootstrap.sh -ms          # Minimal install + system setup
#
# Exit codes:
#   0 - Success
#   1 - General failure
#   2 - Missing dependencies
#   3 - User cancelled
#
# Related files:
#   ~/.config/dotfiles/bootstrap/packages-core.txt    - Essential packages
#   ~/.config/dotfiles/bootstrap/packages-tools.txt   - CLI tools
#   ~/.config/dotfiles/bootstrap/packages-aur.txt     - AUR packages
#   ~/.local/bin/setup-system.sh            - Post-install setup
#
# Author: pentaxis93's dotfiles
# ============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# COLOR OUTPUT FUNCTIONS
# ============================================================================
# These functions provide consistent, colored output for better readability.
# Colors are disabled automatically when output is not to a terminal.

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# Print functions with semantic meaning
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
# These variables define the behavior of the script. They can be modified
# by command-line arguments or environment variables.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/dotfiles/bootstrap"
DRY_RUN=false
MINIMAL=false
RUN_SETUP=false
VERBOSE=false
FORCE_INSTALL=false

# Package list files - each serves a specific purpose
PACKAGES_CORE="${CONFIG_DIR}/packages-core.txt"      # Window manager, terminal, shell
PACKAGES_TOOLS="${CONFIG_DIR}/packages-tools.txt"    # CLI utilities
PACKAGES_AUR="${CONFIG_DIR}/packages-aur.txt"        # AUR packages (fonts, themes)

# Track installation results for summary
INSTALLED_COUNT=0
FAILED_PACKAGES=()
SKIPPED_COUNT=0

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
# Process command-line arguments to modify script behavior

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -m|--minimal)
            MINIMAL=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -s|--setup)
            RUN_SETUP=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--force)
            FORCE_INSTALL=true
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
# PREREQUISITE CHECKS
# ============================================================================
# Ensure the system has the basic requirements to run this script

check_prerequisites() {
    header "Checking prerequisites"

    # Check if running on Arch-based system
    if [[ ! -f /etc/arch-release ]]; then
        error "This script is designed for Arch-based systems only"
        exit 2
    fi

    # Check for pacman
    if ! command -v pacman &> /dev/null; then
        error "pacman not found. This script requires an Arch-based system"
        exit 2
    fi

    # Check for sudo privileges (needed for pacman)
    if ! sudo -n true 2>/dev/null; then
        warning "This script requires sudo privileges for package installation"
        sudo true || exit 3
    fi

    # Check if bootstrap config directory exists
    if [[ ! -d "$CONFIG_DIR" ]]; then
        warning "Bootstrap config directory not found. Creating it..."
        mkdir -p "$CONFIG_DIR"
    fi

    success "Prerequisites check passed"
}

# ============================================================================
# YAY INSTALLATION
# ============================================================================
# Install yay if it's not already present. Yay is needed for AUR packages.

install_yay() {
    if command -v yay &> /dev/null; then
        success "yay is already installed"
        return 0
    fi

    header "Installing yay (AUR helper)"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would install yay from AUR"
        return 0
    fi

    # Install build dependencies
    info "Installing build dependencies..."
    sudo pacman -S --needed --noconfirm git base-devel

    # Clone and build yay
    info "Building yay from source..."
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$HOME"
    rm -rf "$temp_dir"

    if command -v yay &> /dev/null; then
        success "yay installed successfully"
    else
        error "Failed to install yay"
        exit 2
    fi
}

# ============================================================================
# PACKAGE LIST READING
# ============================================================================
# Read package names from a file, ignoring comments and empty lines

read_package_list() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        warning "Package list not found: $file"
        return 1
    fi

    # Read file, remove comments, empty lines, and whitespace
    grep -v '^#' "$file" 2>/dev/null | grep -v '^[[:space:]]*$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || true
}

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================
# Check if packages are installed and install missing ones

is_package_installed() {
    local package="$1"
    pacman -Qq "$package" &>/dev/null
}

install_packages() {
    local package_file="$1"
    local installer="$2"  # Either "pacman" or "yay"
    local description="$3"

    if [[ ! -f "$package_file" ]]; then
        [[ "$VERBOSE" == true ]] && warning "Skipping $description: file not found"
        return 0
    fi

    header "Processing $description"

    local packages=()
    local missing_packages=()

    # Read packages from file
    while IFS= read -r package; do
        [[ -z "$package" ]] && continue
        packages+=("$package")

        if [[ "$FORCE_INSTALL" == true ]] || ! is_package_installed "$package"; then
            missing_packages+=("$package")
            [[ "$VERBOSE" == true ]] && info "Will install: $package"
        else
            [[ "$VERBOSE" == true ]] && info "Already installed: $package"
            ((SKIPPED_COUNT++))
        fi
    done < <(read_package_list "$package_file")

    # Install missing packages
    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        success "All $description are already installed"
        return 0
    fi

    info "Installing ${#missing_packages[@]} packages..."

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would install with $installer:"
        printf '%s\n' "${missing_packages[@]}" | sed 's/^/  - /'
        ((INSTALLED_COUNT+=${#missing_packages[@]}))
        return 0
    fi

    # Perform actual installation
    local install_cmd
    if [[ "$installer" == "pacman" ]]; then
        install_cmd="sudo pacman -S --needed --noconfirm"
    else
        install_cmd="yay -S --needed --noconfirm"
    fi

    # Try to install all packages at once for efficiency
    if $install_cmd "${missing_packages[@]}"; then
        success "Installed ${#missing_packages[@]} packages"
        ((INSTALLED_COUNT+=${#missing_packages[@]}))
    else
        warning "Batch installation failed, trying individually..."

        # Install packages one by one to identify failures
        for package in "${missing_packages[@]}"; do
            if $install_cmd "$package"; then
                success "Installed: $package"
                ((INSTALLED_COUNT++))
            else
                error "Failed to install: $package"
                FAILED_PACKAGES+=("$package")
            fi
        done
    fi
}

# ============================================================================
# CREATE DEFAULT PACKAGE LISTS
# ============================================================================
# Create default package lists if they don't exist. This ensures the script
# can run even on a fresh system.

create_default_package_lists() {
    header "Checking package lists"

    # Create packages-core.txt
    if [[ ! -f "$PACKAGES_CORE" ]]; then
        info "Creating default core packages list..."
        cat > "$PACKAGES_CORE" << 'EOF'
# ============================================================================
# CORE PACKAGES - Essential for basic system functionality
# ============================================================================
# These packages are absolutely required for the dotfiles to work.
# They provide the window manager, terminal, shell, and basic utilities.

# Window Management
bspwm           # Binary space partitioning window manager
sxhkd           # Simple X hotkey daemon for keybindings
polybar         # Status bar with system information
picom           # Compositor for transparency and effects

# Terminal & Shell
alacritty       # GPU-accelerated terminal emulator
fish            # Friendly interactive shell

# Essential Utilities
git             # Version control (required for dotfiles management)
helix           # Modern modal text editor (the only editor we need)
dmenu           # Dynamic menu for launching programs
xclip           # X11 clipboard utility (copy/paste support)
curl            # URL retrieval utility
wget            # Network downloader

# Audio System
pipewire        # Modern audio server
pipewire-pulse  # PulseAudio compatibility
pipewire-alsa   # ALSA compatibility
wireplumber     # PipeWire session manager
pavucontrol     # PulseAudio volume control GUI

# System Utilities
htop            # Interactive process viewer
neofetch        # System information display
man-db          # Manual page utilities
base-devel      # Development tools (for building AUR packages)
EOF
        success "Created $PACKAGES_CORE"
    fi

    # Create packages-tools.txt
    if [[ ! -f "$PACKAGES_TOOLS" ]]; then
        info "Creating default tools packages list..."
        cat > "$PACKAGES_TOOLS" << 'EOF'
# ============================================================================
# CLI TOOLS - Enhanced command-line experience
# ============================================================================
# These packages provide modern alternatives to traditional Unix tools
# and additional utilities that improve productivity.

# Modern CLI Tools (Rust rewrites of classic tools)
ripgrep         # Fast grep alternative (rg command)
fd              # Fast find alternative
bat             # Cat alternative with syntax highlighting
eza             # Modern ls replacement with git integration
bottom          # System monitor (btm command)
du-dust         # Disk usage analyzer (dust command)
procs           # Modern ps replacement
sd              # Intuitive find & replace (sed alternative)
hyperfine       # Command-line benchmarking tool

# File Management
fzf             # Fuzzy finder for files and commands
ranger          # Terminal file manager with vi keybindings
trash-cli       # Trash management from command line
ncdu            # NCurses disk usage analyzer

# Development Tools
tmux            # Terminal multiplexer
lazygit         # Terminal UI for git
jq              # JSON processor
yq              # YAML processor
httpie          # User-friendly HTTP client

# System Tools
tldr            # Simplified man pages
thefuck         # Command correction tool
zoxide          # Smarter cd command
atuin           # Shell history sync and search

# Archive Tools
unzip           # ZIP archive extraction
unrar           # RAR archive extraction
p7zip           # 7-Zip support

# Network Tools
mtr             # Network diagnostic tool
speedtest-cli   # Internet speed testing
bandwhich       # Bandwidth utilization monitor
EOF
        success "Created $PACKAGES_TOOLS"
    fi

    # Create packages-aur.txt
    if [[ ! -f "$PACKAGES_AUR" ]]; then
        info "Creating default AUR packages list..."
        cat > "$PACKAGES_AUR" << 'EOF'
# ============================================================================
# AUR PACKAGES - Community packages not in official repos
# ============================================================================
# These packages come from the Arch User Repository and provide
# fonts, themes, and tools not available in the official repositories.

# Fonts
nerd-fonts-meslo            # Meslo font with nerd font patches
ttf-font-awesome           # Icon font for polybar
noto-fonts-emoji           # Emoji support

# Themes
gruvbox-material-gtk-theme-git  # GTK theme matching our color scheme
papirus-folders            # Tool to change Papirus folder colors

# Additional Tools
visual-studio-code-bin     # Visual Studio Code (if needed)
spotify                    # Music streaming (optional)
discord                    # Communication (optional)
EOF
        success "Created $PACKAGES_AUR"
    fi

    # Note: packages-dev.txt has been removed - this is a minimalist setup
}

# ============================================================================
# RUN SYSTEM SETUP
# ============================================================================
# Execute post-installation system configuration

run_system_setup() {
    local setup_script="${SCRIPT_DIR}/setup-system.sh"

    if [[ ! -f "$setup_script" ]]; then
        warning "System setup script not found: $setup_script"
        return 1
    fi

    header "Running system setup"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would run system setup script"
        return 0
    fi

    if bash "$setup_script"; then
        success "System setup completed"
    else
        error "System setup failed"
        return 1
    fi
}

# ============================================================================
# PRINT SUMMARY
# ============================================================================
# Display installation results

print_summary() {
    header "Installation Summary"

    echo -e "${GREEN}Installed:${RESET} $INSTALLED_COUNT packages"
    echo -e "${YELLOW}Skipped:${RESET} $SKIPPED_COUNT packages (already installed)"

    if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
        echo -e "${RED}Failed:${RESET} ${#FAILED_PACKAGES[@]} packages"
        echo "Failed packages:"
        printf '%s\n' "${FAILED_PACKAGES[@]}" | sed 's/^/  - /'
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo
        warning "This was a dry run. No packages were actually installed."
        echo "Run without --dry-run to perform actual installation."
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
# Orchestrate the entire bootstrap process

main() {
    echo -e "${BOLD}${CYAN}"
    echo "╔════════════════════════════════════╗"
    echo "║   DOTFILES BOOTSTRAP INSTALLER    ║"
    echo "╚════════════════════════════════════╝"
    echo -e "${RESET}"

    # Run prerequisite checks
    check_prerequisites

    # Create default package lists if needed
    create_default_package_lists

    # Install yay if needed (for AUR packages)
    if [[ -f "$PACKAGES_AUR" ]] && [[ "$MINIMAL" != true ]]; then
        install_yay
    fi

    # Install packages based on mode
    install_packages "$PACKAGES_CORE" "pacman" "core packages"

    if [[ "$MINIMAL" != true ]]; then
        install_packages "$PACKAGES_TOOLS" "pacman" "CLI tools"

        if command -v yay &> /dev/null; then
            install_packages "$PACKAGES_AUR" "yay" "AUR packages"
        fi
    fi

    # Run system setup if requested
    if [[ "$RUN_SETUP" == true ]]; then
        run_system_setup
    fi

    # Print summary
    print_summary

    # Exit with appropriate code
    if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
        exit 1
    else
        echo
        success "Bootstrap completed successfully!"

        if [[ "$RUN_SETUP" != true ]] && [[ "$DRY_RUN" != true ]]; then
            echo
            info "Run 'bootstrap.sh --setup' to configure system settings"
        fi

        exit 0
    fi
}

# Run main function
main "$@"