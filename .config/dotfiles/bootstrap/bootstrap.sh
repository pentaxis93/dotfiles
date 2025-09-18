#!/usr/bin/env bash
# ============================================================================
# SIMPLIFIED DOTFILES BOOTSTRAP
# ============================================================================
# A clean, maintainable bootstrap system for Arch/CachyOS
#
# Philosophy:
#   - Simple package lists (just names, no parsing)
#   - Modular setup scripts (one concern each)
#   - Clear phases (packages, then setup)
#   - Let tools do their job (pacman handles --needed)
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

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warning() { echo -e "${YELLOW}[!]${RESET} $*"; }
error() { echo -e "${RED}[✗]${RESET} $*" >&2; }
header() { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }

# Configuration
BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$BOOTSTRAP_DIR/packages"
SETUP_DIR="$BOOTSTRAP_DIR/setup"

# Flags
DRY_RUN=false
MINIMAL=false
SKIP_SETUP=false
VERBOSE=false

# ============================================================================
# HELP
# ============================================================================
show_help() {
    cat << EOF
Usage: bootstrap.sh [OPTIONS]

Options:
    -h, --help      Show this help message
    -d, --dry-run   Show what would be done without doing it
    -m, --minimal   Install only core packages
    -s, --skip-setup Skip running setup scripts
    -v, --verbose   Show detailed output

Examples:
    bootstrap.sh              # Full installation with setup
    bootstrap.sh --minimal    # Core packages only
    bootstrap.sh --dry-run    # Preview what would happen

EOF
    exit 0
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) show_help ;;
        -d|--dry-run) DRY_RUN=true; shift ;;
        -m|--minimal) MINIMAL=true; shift ;;
        -s|--skip-setup) SKIP_SETUP=true; shift ;;
        -v|--verbose) VERBOSE=true; shift ;;
        *) error "Unknown option: $1"; show_help ;;
    esac
done

# ============================================================================
# PREREQUISITES
# ============================================================================
check_prerequisites() {
    header "Checking prerequisites"

    # Check if Arch-based
    if [[ ! -f /etc/arch-release ]]; then
        error "This bootstrap is designed for Arch/CachyOS only"
        exit 1
    fi

    # Check for pacman
    if ! command -v pacman &>/dev/null; then
        error "pacman not found"
        exit 1
    fi

    # Check for sudo
    if ! sudo -n true 2>/dev/null; then
        warning "This script requires sudo privileges"
        sudo true || exit 1
    fi

    success "Prerequisites met"
}

# ============================================================================
# INSTALL YAY
# ============================================================================
install_yay() {
    if command -v yay &>/dev/null; then
        [[ "$VERBOSE" == true ]] && info "yay is already installed"
        return 0
    fi

    header "Installing yay (AUR helper)"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would install yay"
        return 0
    fi

    # Install dependencies
    sudo pacman -S --needed --noconfirm git base-devel

    # Build and install yay
    local temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
    cd "$temp_dir/yay"
    makepkg -si --noconfirm
    cd - >/dev/null
    rm -rf "$temp_dir"

    success "yay installed"
}

# ============================================================================
# INSTALL PACKAGES
# ============================================================================
install_package_list() {
    local list_file="$1"
    local installer="$2"  # pacman or yay
    local description="$3"

    if [[ ! -f "$list_file" ]]; then
        [[ "$VERBOSE" == true ]] && warning "Package list not found: $list_file"
        return 0
    fi

    # Count packages
    local count=$(grep -v '^[[:space:]]*$' "$list_file" | wc -l)
    if [[ $count -eq 0 ]]; then
        return 0
    fi

    header "Installing $description ($count packages)"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would install with $installer:"
        cat "$list_file" | sed 's/^/  - /'
        return 0
    fi

    # Install packages
    if [[ "$installer" == "pacman" ]]; then
        cat "$list_file" | xargs sudo pacman -S --needed --noconfirm || true
    else
        cat "$list_file" | xargs yay -S --needed --noconfirm || true
    fi

    success "$description installed"
}

# NPM package management removed - using AUR packages instead

# ============================================================================
# RUN SETUP SCRIPTS
# ============================================================================
run_setup_scripts() {
    if [[ "$SKIP_SETUP" == true ]]; then
        info "Skipping setup scripts (--skip-setup)"
        return 0
    fi

    if [[ ! -d "$SETUP_DIR" ]]; then
        warning "Setup directory not found"
        return 0
    fi

    header "Running setup scripts"

    # Get all setup scripts, sorted by name
    local scripts=()
    while IFS= read -r script; do
        scripts+=("$script")
    done < <(find "$SETUP_DIR" -name "*.sh" -type f | sort)

    if [[ ${#scripts[@]} -eq 0 ]]; then
        info "No setup scripts found"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would run these setup scripts:"
        for script in "${scripts[@]}"; do
            echo "  - $(basename "$script")"
        done
        return 0
    fi

    # Run each script
    for script in "${scripts[@]}"; do
        local name=$(basename "$script")
        info "Running $name..."
        if bash "$script"; then
            success "$name completed"
        else
            warning "$name failed (continuing...)"
        fi
    done
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    echo -e "${BOLD}${CYAN}"
    echo "╔════════════════════════════════════╗"
    echo "║   SIMPLIFIED DOTFILES BOOTSTRAP   ║"
    echo "╚════════════════════════════════════╝"
    echo -e "${RESET}"

    # Check prerequisites
    check_prerequisites

    # Phase 1: Package Installation
    info "Phase 1: Package Installation"

    # Core packages (always install)
    install_package_list "$PACKAGES_DIR/core.txt" "pacman" "core packages"

    if [[ "$MINIMAL" != true ]]; then
        # Additional packages
        install_package_list "$PACKAGES_DIR/tools.txt" "pacman" "CLI tools"

        # AUR packages (requires yay)
        if [[ -f "$PACKAGES_DIR/aur.txt" ]] && [[ -s "$PACKAGES_DIR/aur.txt" ]]; then
            install_yay
            install_package_list "$PACKAGES_DIR/aur.txt" "yay" "AUR packages"
        fi
    fi

    # Phase 2: System Setup
    info "Phase 2: System Setup"
    run_setup_scripts

    # Done!
    echo
    success "Bootstrap complete!"

    if [[ "$DRY_RUN" == true ]]; then
        warning "This was a dry run. No changes were made."
        info "Run without --dry-run to apply changes."
    else
        info "Next steps:"
        echo "  1. Log out and back in for shell changes"
        echo "  2. Run 'dots status' to check your dotfiles"
        echo "  3. Restart BSPWM with Super+Alt+R"
    fi
}

# Run main
main "$@"