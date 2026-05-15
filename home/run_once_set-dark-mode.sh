#!/usr/bin/env bash
# Set system-wide dark mode preferences
# Ensures consistent dark theme across all applications

set -euo pipefail

echo "Setting system-wide dark mode preferences..."

# GNOME/GTK Dark Mode (if gsettings is available)
if command -v gsettings &> /dev/null; then
    echo "  Configuring GNOME/GTK dark mode..."
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
    echo "  ✓ GNOME/GTK dark mode configured"
else
    echo "  gsettings not available, skipping GNOME configuration"
fi

# Set GTK environment variables (will be sourced by zsh config)
# These are also set in zsh config but we ensure they're exported
export GTK_THEME=Adwaita:dark
export QT_STYLE_OVERRIDE=adwaita-dark

echo "✓ Dark mode preferences set successfully"
echo ""
echo "Note: Some applications may require a restart to apply dark mode."