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
        echo "                           # Alternative: 'b' for mnemonic \"browse\"" >> "$input_conf"
        echo "b script-binding browse-files    # Mnemonic file browser binding" >> "$input_conf"
        echo "                           # WHY: 'b' for \"browse\" - easy to remember" >> "$input_conf"
        echo "                           # No conflicts with system or mpv defaults" >> "$input_conf"

        success "File browser keybinding added to input.conf"
    else
        warning "input.conf not found, skipping keybinding configuration"
    fi
}

# ============================================================================
# CREATE GRUVBOX THEME CONFIG
# ============================================================================
create_gruvbox_config() {
    local script_opts_dir="$MPV_CONFIG_DIR/script-opts"
    local config_file="$script_opts_dir/file_browser.conf"

    info "Creating Gruvbox theme configuration..."

    # Create script-opts directory
    mkdir -p "$script_opts_dir"

    # Create Gruvbox config file
    cat > "$config_file" << 'EOF'
# ============================================================================
# MPV FILE BROWSER - GRUVBOX THEME CONFIGURATION
# ============================================================================
# Customizes the file browser appearance to match the Gruvbox color scheme
# used throughout the system (BSPWM, Polybar, Alacritty, etc.)
# ============================================================================

# Display settings optimized for file browsing
num_entries=25
wrap=true
default_to_working_directory=true
cursor_follows_playing_item=true
home_label=true

# Gruvbox color scheme (hex values without #)
font_colour_header=8ec07c          # bright aqua
font_colour_body=ebdbb2            # cream
font_colour_wrappers=8ec07c        # bright aqua
font_colour_cursor=8ec07c          # bright aqua
font_colour_escape_chars=928374    # muted gray
font_colour_multiselect=fe8019     # orange
font_colour_selected=fabd2f        # yellow
font_colour_playing=b8bb26         # green
font_colour_playing_multiselected=8ec07c  # bright aqua

# Typography
font_name_header=Monospace
font_name_body=Monospace
scaling_factor_header=1.2
font_bold_header=true

# Behavior
custom_keybinds=true
save_last_opened_directory=true
default_to_last_opened_directory=true
filter_files=true
filter_dot_files=yes
filter_dot_dirs=yes
ls_parser=true
history_size=50
cache=true
EOF

    success "Gruvbox theme configuration created"
}

# ============================================================================
# CREATE VIM NAVIGATION KEYBINDS
# ============================================================================
create_vim_keybinds() {
    local script_opts_dir="$MPV_CONFIG_DIR/script-opts"
    local keybinds_file="$script_opts_dir/file-browser-keybinds.json"

    info "Creating vim navigation keybinds..."

    # Create vim keybinds file
    cat > "$keybinds_file" << 'EOF'
[
    {
        "key": "h",
        "command": ["script-binding", "file_browser/dynamic/up_dir"],
        "name": "vim_up_dir"
    },
    {
        "key": "j",
        "command": ["script-binding", "file_browser/dynamic/scroll_down"],
        "name": "vim_scroll_down"
    },
    {
        "key": "k",
        "command": ["script-binding", "file_browser/dynamic/scroll_up"],
        "name": "vim_scroll_up"
    },
    {
        "key": "l",
        "command": ["script-binding", "file_browser/dynamic/down_dir"],
        "name": "vim_down_dir"
    },
    {
        "key": "Shift+j",
        "command": ["script-binding", "file_browser/dynamic/page_down"],
        "name": "vim_page_down"
    },
    {
        "key": "Shift+k",
        "command": ["script-binding", "file_browser/dynamic/page_up"],
        "name": "vim_page_up"
    },
    {
        "key": "Ctrl+j",
        "command": ["script-binding", "file_browser/dynamic/list_bottom"],
        "name": "vim_list_bottom"
    },
    {
        "key": "Ctrl+k",
        "command": ["script-binding", "file_browser/dynamic/list_top"],
        "name": "vim_list_top"
    },
    {
        "key": "g",
        "command": ["script-binding", "file_browser/dynamic/list_top"],
        "name": "vim_goto_top"
    },
    {
        "key": "Shift+g",
        "command": ["script-binding", "file_browser/dynamic/list_bottom"],
        "name": "vim_goto_bottom"
    },
    {
        "key": "u",
        "command": ["script-binding", "file_browser/dynamic/up_dir"],
        "name": "vim_up_shortcut"
    },
    {
        "key": "r",
        "command": ["script-binding", "file_browser/dynamic/reload"],
        "name": "vim_reload"
    }
]
EOF

    success "Vim navigation keybinds created"
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

    # Install file browser script and configurations
    if install_file_browser; then
        configure_keybinding
        create_gruvbox_config
        create_vim_keybinds
        success "mpv scripts setup complete"
    else
        error "mpv scripts setup failed"
        return 1
    fi

    info "File browser accessible with MENU or 'b' key in mpv"
    info "Navigation: hjkl (vim), arrows, g/G (top/bottom), r (reload)"
}

# Run main function
main "$@"