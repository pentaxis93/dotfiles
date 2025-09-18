#!/usr/bin/env bash
# Configure GTK theme and icons

set -euo pipefail

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warning() { echo -e "${YELLOW}[!]${RESET} $*"; }

info "Configuring themes and icons..."

# Check dependencies
if ! command -v gsettings &>/dev/null; then
    warning "gsettings not found, skipping GTK configuration"
    exit 0
fi

# Set GTK theme if available
if [[ -d /usr/share/themes/Gruvbox-Dark ]] || \
   [[ -d ~/.themes/Gruvbox-Dark ]] || \
   [[ -d /usr/share/themes/Gruvbox-Material-Dark ]]; then

    gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Dark" 2>/dev/null || \
    gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Material-Dark" 2>/dev/null || \
    warning "Failed to set GTK theme via gsettings"

    # Create GTK 3.0 settings if not exists
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
    warning "Gruvbox theme not installed"
fi

# Configure icon theme
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || \
warning "Failed to set icon theme"

# Change Papirus folder color to teal if available
if command -v papirus-folders &>/dev/null; then
    papirus-folders -C teal
    success "Papirus folders set to teal"
else
    info "papirus-folders not found, skipping folder color change"
fi

success "Theme configuration complete"