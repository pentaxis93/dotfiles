# X11/BSPWM to Wayland/Sway Migration Roadmap

## Executive Summary

This document outlines a modular, phased migration from the current X11/BSPWM window management stack to Wayland/Sway. The migration is designed to maintain system usability throughout the transition, with rollback capabilities at each phase.

**Target State**: Full Wayland/Sway environment with feature parity to current BSPWM setup
**Risk Level**: Low (with snapshot rollback capabilities)
**Estimated Duration**: 3-4 weeks for full migration
**Parallel Operation Period**: 2-3 weeks minimum

---

## Prerequisites

### System Requirements
- [x] Btrfs filesystem with snapshot capability
- [x] Intel graphics (Iris Xe confirmed compatible)
- [x] CachyOS with access to Wayland packages
- [ ] 2GB additional disk space for parallel installation
- [ ] Backup of critical data (independent of snapshots)

### Knowledge Requirements
- Understanding of window manager concepts
- Basic Lua/JSON configuration syntax
- Systemd service management
- Git version control

---

## Migration Phases Overview

```
Phase 0: Foundation (Day 1)
  ├── M001: Environment Analysis
  ├── M002: Snapshot Checkpoint
  └── M003: Package Installation

Phase 1: Core Functionality (Days 2-5)
  ├── M101: Base Sway Configuration
  ├── M102: Display & Output Setup
  ├── M103: Input Configuration
  └── M104: Basic Keybindings

Phase 2: Feature Parity (Days 6-12)
  ├── M201: Tri-Modal Navigation
  ├── M202: Workspace Management
  ├── M203: Window Rules
  ├── M204: Status Bar (Waybar)
  └── M205: Notification System

Phase 3: Tool Migration (Days 13-18)
  ├── M301: Application Launcher
  ├── M302: Screenshot Tools
  ├── M303: Clipboard Manager
  ├── M304: Screen Lock
  └── M305: Custom Scripts

Phase 4: Polish & Optimization (Days 19-24)
  ├── M401: Theme Integration
  ├── M402: Performance Tuning
  ├── M403: Autostart Services
  └── M404: Bootstrap Integration

Phase 5: Cleanup & Finalization (Days 25-28)
  ├── M501: Validation Testing
  ├── M502: Documentation Update
  ├── M503: X11 Removal
  └── M504: Final Snapshot
```

---

## Phase 0: Foundation

### M001: Environment Analysis
**Owner**: System Administrator
**Duration**: 2 hours
**Dependencies**: None

#### Tasks
1. Document current X11 package list
   ```bash
   pacman -Q | grep -E 'xorg|x11|bspwm|sxhkd|polybar|picom' > ~/migration/x11-packages.txt
   ```

2. Identify custom scripts using X11 tools
   ```bash
   grep -r "xprop\|xdotool\|xrandr\|xset" ~/.local/bin ~/.config
   ```

3. Catalog current keybindings
   ```bash
   awk '/^super|^alt|^ctrl/ {print}' ~/.config/sxhkd/sxhkdrc > ~/migration/keybindings.txt
   ```

4. Screenshot current desktop setup for reference

#### Validation
- [ ] Complete package list generated
- [ ] All X11 dependencies identified
- [ ] Keybinding documentation complete

#### Rollback
- No changes made; documentation only

---

### M002: Snapshot Checkpoint
**Owner**: System Administrator
**Duration**: 15 minutes
**Dependencies**: M001

#### Tasks
1. Create pre-migration snapshot
   ```bash
   snapshot-create "Pre-Wayland migration baseline"
   ```

2. Verify snapshot integrity
   ```bash
   sudo snapper -c root list | tail -5
   sudo snapper -c home list | tail -5
   ```

3. Document snapshot numbers for emergency rollback

#### Validation
- [ ] Root snapshot created successfully
- [ ] Home snapshot created successfully
- [ ] Snapshot numbers recorded

#### Rollback
- Use documented snapshot numbers:
  ```bash
  snapshot-rollback root [NUMBER]
  snapshot-rollback home [NUMBER]
  ```

---

### M003: Package Installation
**Owner**: System Administrator
**Duration**: 30 minutes
**Dependencies**: M002

#### Tasks
1. Install core Wayland packages
   ```bash
   sudo pacman -S --needed \
     sway \
     swaylock \
     swayidle \
     swaybg \
     xorg-xwayland
   ```

2. Install Wayland utilities
   ```bash
   sudo pacman -S --needed \
     waybar \
     mako \
     fuzzel \
     grim \
     slurp \
     wl-clipboard \
     wlr-randr \
     brightnessctl
   ```

3. Install compatibility layer
   ```bash
   sudo pacman -S --needed \
     qt5-wayland \
     qt6-wayland \
     xdg-desktop-portal-wlr
   ```

#### Validation
- [ ] All packages installed without errors
- [ ] `sway --version` returns version info
- [ ] No package conflicts reported

#### Rollback
```bash
sudo pacman -R sway waybar mako fuzzel grim slurp wl-clipboard
```

---

## Phase 1: Core Functionality

### M101: Base Sway Configuration
**Owner**: Configuration Engineer
**Duration**: 2 hours
**Dependencies**: M003

#### Tasks
1. Create initial Sway configuration structure
   ```bash
   mkdir -p ~/.config/sway
   mkdir -p ~/.config/sway/config.d
   ```

2. Generate base configuration
   ```lua
   # ~/.config/sway/config
   # Base Sway configuration

   # Mod key (Super key)
   set $mod Mod4

   # Terminal
   set $term alacritty

   # Include modular configs
   include ~/.config/sway/config.d/*.conf
   ```

3. Create display configuration module
   ```lua
   # ~/.config/sway/config.d/01-output.conf
   # Display configuration
   output * bg #1d2021 solid_color
   ```

4. Set up logging for debugging
   ```bash
   echo 'exec systemd-cat --identifier=sway sway' > ~/.local/bin/sway-logged
   chmod +x ~/.local/bin/sway-logged
   ```

#### Validation
- [ ] Configuration syntax valid: `sway -C`
- [ ] Can launch Sway session from TTY
- [ ] Logs available: `journalctl --identifier=sway`

#### Rollback
```bash
rm -rf ~/.config/sway
```

---

### M102: Display & Output Setup
**Owner**: Configuration Engineer
**Duration**: 1 hour
**Dependencies**: M101

#### Tasks
1. Detect current display configuration
   ```bash
   swaymsg -t get_outputs
   ```

2. Configure display settings
   ```lua
   # ~/.config/sway/config.d/01-output.conf
   output eDP-1 {
       mode 1920x1080@60Hz
       position 0 0
       scale 1.0
       bg #1d2021 solid_color
   }
   ```

3. Set up display auto-configuration
   ```bash
   # Create kanshi config for dynamic display management
   mkdir -p ~/.config/kanshi
   cat > ~/.config/kanshi/config << 'EOF'
   profile laptop {
       output eDP-1 mode 1920x1080 position 0,0
   }
   EOF
   ```

#### Validation
- [ ] Display resolution correct
- [ ] Refresh rate appropriate
- [ ] Scaling comfortable for HiDPI

#### Rollback
- Remove output configuration from `01-output.conf`

---

### M103: Input Configuration
**Owner**: Configuration Engineer
**Duration**: 1 hour
**Dependencies**: M101

#### Tasks
1. Configure keyboard layout
   ```lua
   # ~/.config/sway/config.d/02-input.conf
   input type:keyboard {
       xkb_layout us
       repeat_rate 40
       repeat_delay 300
   }
   ```

2. Configure touchpad (ThinkPad specific)
   ```lua
   input type:touchpad {
       tap enabled
       natural_scroll enabled
       middle_emulation enabled
       scroll_method two_finger
   }
   ```

3. Configure TrackPoint (if present)
   ```lua
   input type:pointer {
       accel_profile flat
       pointer_accel 0.5
   }
   ```

#### Validation
- [ ] Keyboard layout correct
- [ ] Repeat rate comfortable
- [ ] Touchpad gestures working
- [ ] Mouse/TrackPoint responsive

#### Rollback
- Remove `02-input.conf`

---

### M104: Basic Keybindings
**Owner**: Configuration Engineer
**Duration**: 2 hours
**Dependencies**: M101, M103

#### Tasks
1. Port essential keybindings
   ```lua
   # ~/.config/sway/config.d/03-keybindings.conf

   # Terminal
   bindsym $mod+Return exec $term

   # Kill focused window
   bindsym $mod+Shift+q kill

   # Reload configuration
   bindsym $mod+Shift+r reload

   # Exit sway
   bindsym $mod+Shift+e exec swaynag -t warning \
     -m 'Exit Sway?' -B 'Yes' 'swaymsg exit'
   ```

2. Implement window focus movement
   ```lua
   # Vim-style focus movement
   bindsym $mod+h focus left
   bindsym $mod+j focus down
   bindsym $mod+k focus up
   bindsym $mod+l focus right

   # Arrow key support
   bindsym $mod+Left focus left
   bindsym $mod+Down focus down
   bindsym $mod+Up focus up
   bindsym $mod+Right focus right
   ```

3. Add workspace navigation
   ```lua
   # Workspace switching
   bindsym $mod+1 workspace number 1
   bindsym $mod+2 workspace number 2
   # ... continue for all workspaces
   ```

#### Validation
- [ ] Terminal launches with $mod+Return
- [ ] Window focus changes with vim keys
- [ ] Workspace switching functional
- [ ] Configuration reload works

#### Rollback
- Remove `03-keybindings.conf`

---

## Phase 2: Feature Parity

### M201: Tri-Modal Navigation Implementation
**Owner**: Configuration Engineer
**Duration**: 3 hours
**Dependencies**: M104

#### Tasks
1. Extend keybindings for full tri-modal support
   ```lua
   # ~/.config/sway/config.d/04-trimodal.conf

   # Window focus (vim, arrows, numpad)
   bindsym $mod+h focus left
   bindsym $mod+Left focus left
   bindsym $mod+KP_4 focus left

   bindsym $mod+j focus down
   bindsym $mod+Down focus down
   bindsym $mod+KP_2 focus down

   bindsym $mod+k focus up
   bindsym $mod+Up focus up
   bindsym $mod+KP_8 focus up

   bindsym $mod+l focus right
   bindsym $mod+Right focus right
   bindsym $mod+KP_6 focus right
   ```

2. Implement window movement
   ```lua
   # Window movement (vim, arrows, numpad)
   bindsym $mod+Shift+h move left
   bindsym $mod+Shift+Left move left
   bindsym $mod+Shift+KP_4 move left
   # ... repeat for all directions
   ```

3. Configure resize mode with tri-modal support
   ```lua
   mode "resize" {
       bindsym h resize shrink width 10px
       bindsym Left resize shrink width 10px
       bindsym KP_4 resize shrink width 10px
       # ... complete for all operations

       bindsym Escape mode "default"
   }
   bindsym $mod+r mode "resize"
   ```

#### Validation
- [ ] All three input methods work for focus
- [ ] All three input methods work for movement
- [ ] Resize mode accessible and functional
- [ ] No keybinding conflicts

#### Rollback
- Remove `04-trimodal.conf`

---

### M202: Workspace Management
**Owner**: Configuration Engineer
**Duration**: 2 hours
**Dependencies**: M104

#### Tasks
1. Configure workspace behavior
   ```lua
   # ~/.config/sway/config.d/05-workspaces.conf

   # Workspace names
   set $ws1 "1"
   set $ws2 "2"
   set $ws3 "3"
   set $ws4 "4"
   set $ws5 "5"
   set $ws6 "6"
   set $ws7 "7"
   set $ws8 "8"
   set $ws9 "9"
   set $ws10 "10"
   ```

2. Implement workspace assignment rules
   ```lua
   # Application workspace assignments
   assign [app_id="firefox"] $ws2
   assign [app_id="code"] $ws3
   assign [app_id="discord"] $ws9
   ```

3. Configure multi-monitor workspace behavior
   ```lua
   # Bind workspaces to outputs
   workspace $ws1 output eDP-1
   workspace $ws2 output eDP-1
   # External monitor workspaces (when connected)
   workspace $ws8 output HDMI-A-1
   workspace $ws9 output HDMI-A-1
   ```

#### Validation
- [ ] All 10 workspaces accessible
- [ ] Applications open on assigned workspaces
- [ ] Workspace persistence across reloads
- [ ] Multi-monitor behavior correct (if applicable)

#### Rollback
- Remove `05-workspaces.conf`

---

### M203: Window Rules and Behavior
**Owner**: Configuration Engineer
**Duration**: 2 hours
**Dependencies**: M201, M202

#### Tasks
1. Configure floating window rules
   ```lua
   # ~/.config/sway/config.d/06-window-rules.conf

   # Floating windows
   for_window [window_role="pop-up"] floating enable
   for_window [window_role="task_dialog"] floating enable
   for_window [app_id="pavucontrol"] floating enable
   for_window [app_id="nm-connection-editor"] floating enable
   ```

2. Set window border and gap configuration
   ```lua
   # Borders and gaps
   default_border pixel 2
   default_floating_border pixel 2
   gaps inner 10
   gaps outer 5
   smart_gaps on

   # Border colors (Gruvbox theme)
   client.focused          #8ec07c #8ec07c #1d2021 #b8bb26
   client.focused_inactive #3c3836 #3c3836 #ebdbb2 #3c3836
   client.unfocused        #3c3836 #1d2021 #928374 #3c3836
   ```

3. Configure window behavior patterns
   ```lua
   # Focus behavior
   focus_follows_mouse yes
   focus_wrapping no

   # Layout behavior
   workspace_layout default
   ```

#### Validation
- [ ] Floating windows appear correctly
- [ ] Border colors match Gruvbox theme
- [ ] Gaps render properly
- [ ] Focus behavior intuitive

#### Rollback
- Remove `06-window-rules.conf`

---

### M204: Status Bar (Waybar)
**Owner**: UI Engineer
**Duration**: 4 hours
**Dependencies**: M201

#### Tasks
1. Create Waybar configuration structure
   ```bash
   mkdir -p ~/.config/waybar
   ```

2. Port Polybar configuration to Waybar
   ```json
   # ~/.config/waybar/config
   {
     "layer": "top",
     "position": "top",
     "height": 30,
     "modules-left": ["sway/workspaces", "sway/mode", "custom/media"],
     "modules-center": ["sway/window"],
     "modules-right": ["network", "cpu", "memory", "battery", "clock"],

     "sway/workspaces": {
       "disable-scroll": true,
       "all-outputs": true
     },

     "clock": {
       "format": "{:%Y-%m-%d %H:%M}",
       "tooltip-format": "<big>{:%Y %B}</big>\n<tt>{calendar}</tt>"
     },

     "battery": {
       "states": {
         "warning": 30,
         "critical": 15
       },
       "format": "{capacity}% {icon}",
       "format-icons": ["", "", "", "", ""]
     }
   }
   ```

3. Create Waybar styling (Gruvbox theme)
   ```css
   /* ~/.config/waybar/style.css */
   * {
     font-family: "MesloLGS Nerd Font", FontAwesome, sans-serif;
     font-size: 13px;
   }

   window#waybar {
     background-color: #1d2021;
     color: #ebdbb2;
     border-bottom: 2px solid #8ec07c;
   }

   #workspaces button {
     padding: 0 10px;
     color: #928374;
     background-color: transparent;
   }

   #workspaces button.focused {
     color: #1d2021;
     background-color: #8ec07c;
   }

   #clock, #battery, #cpu, #memory, #network {
     padding: 0 10px;
     margin: 0 5px;
   }

   #battery.warning {
     color: #fabd2f;
   }

   #battery.critical {
     color: #fb4934;
   }
   ```

4. Create window title script replacement
   ```bash
   #!/usr/bin/env bash
   # ~/.config/waybar/scripts/window-title.sh
   # Wayland replacement for window title daemon

   swaymsg -t subscribe -m '["window"]' | \
   jq -r '.container.name // empty' | \
   while read -r title; do
     # Apply same filtering logic as X11 version
     if [[ "$title" =~ tmux ]]; then
       title=$(echo "$title" | sed 's/.*: //')
     fi
     echo "$title"
   done
   ```

#### Validation
- [ ] Waybar appears on Sway start
- [ ] All modules display data
- [ ] Gruvbox theme applied correctly
- [ ] Window title updates dynamically

#### Rollback
```bash
rm -rf ~/.config/waybar
```

---

### M205: Notification System
**Owner**: UI Engineer
**Duration**: 1 hour
**Dependencies**: M204

#### Tasks
1. Configure Mako notification daemon
   ```ini
   # ~/.config/mako/config

   # Gruvbox theme colors
   background-color=#3c3836
   text-color=#ebdbb2
   border-color=#8ec07c

   # Behavior
   border-size=2
   border-radius=5
   padding=10
   margin=10
   default-timeout=5000

   # Position
   anchor=top-right

   # Font
   font=MesloLGS Nerd Font 11

   # Urgency styling
   [urgency=high]
   background-color=#fb4934
   text-color=#1d2021
   border-color=#fb4934
   default-timeout=0
   ```

2. Create notification test script
   ```bash
   #!/usr/bin/env bash
   # ~/.local/bin/test-notifications

   notify-send "Test" "Normal notification"
   notify-send -u critical "Critical" "High priority notification"
   notify-send -u low "Low" "Low priority notification"
   ```

3. Configure autostart
   ```lua
   # Add to ~/.config/sway/config
   exec mako
   ```

#### Validation
- [ ] Notifications appear correctly
- [ ] Urgency levels distinguished visually
- [ ] Timeout behavior correct
- [ ] Click to dismiss works

#### Rollback
```bash
pkill mako
rm -rf ~/.config/mako
```

---

## Phase 3: Tool Migration

### M301: Application Launcher
**Owner**: UI Engineer
**Duration**: 1 hour
**Dependencies**: M204

#### Tasks
1. Configure Fuzzel launcher (Rofi replacement)
   ```ini
   # ~/.config/fuzzel/fuzzel.ini

   [main]
   font=MesloLGS Nerd Font:size=11
   dpi-aware=yes
   width=35
   lines=10

   [colors]
   background=1d2021ff
   text=ebdbb2ff
   selection=8ec07cff
   selection-text=1d2021ff
   border=8ec07cff
   ```

2. Create launcher keybinding
   ```lua
   # Add to keybindings
   bindsym $mod+d exec fuzzel
   bindsym $mod+Shift+d exec fuzzel --dmenu
   ```

3. Create custom launcher scripts
   ```bash
   #!/usr/bin/env bash
   # ~/.local/bin/launcher-power

   OPTIONS="Lock\nLogout\nReboot\nShutdown"
   CHOICE=$(echo -e "$OPTIONS" | fuzzel --dmenu)

   case "$CHOICE" in
     Lock) swaylock ;;
     Logout) swaymsg exit ;;
     Reboot) systemctl reboot ;;
     Shutdown) systemctl poweroff ;;
   esac
   ```

#### Validation
- [ ] Launcher opens with keybinding
- [ ] Applications launch correctly
- [ ] Dmenu mode works for scripts
- [ ] Theme matches system

#### Rollback
```bash
rm -rf ~/.config/fuzzel
```

---

### M302: Screenshot Tools
**Owner**: Tool Engineer
**Duration**: 2 hours
**Dependencies**: M301

#### Tasks
1. Create screenshot scripts using Wayland tools
   ```bash
   #!/usr/bin/env bash
   # ~/.local/bin/screenshot

   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   SAVE_DIR="$HOME/Pictures/Screenshots"
   mkdir -p "$SAVE_DIR"

   case "$1" in
     full)
       grim "$SAVE_DIR/screenshot_${TIMESTAMP}.png"
       notify-send "Screenshot" "Full screen captured"
       ;;
     region)
       grim -g "$(slurp)" "$SAVE_DIR/screenshot_${TIMESTAMP}.png"
       notify-send "Screenshot" "Region captured"
       ;;
     window)
       grim -g "$(swaymsg -t get_tree | \
         jq -r '.. | select(.focused? == true).rect |
         "\(.x),\(.y) \(.width)x\(.height)"')" \
         "$SAVE_DIR/screenshot_${TIMESTAMP}.png"
       notify-send "Screenshot" "Window captured"
       ;;
   esac
   ```

2. Bind screenshot keys
   ```lua
   # Screenshot bindings
   bindsym Print exec screenshot full
   bindsym Shift+Print exec screenshot region
   bindsym $mod+Print exec screenshot window
   ```

3. Configure clipboard integration
   ```bash
   # Modify screenshot script to copy to clipboard
   grim - | wl-copy
   ```

#### Validation
- [ ] Full screenshot works
- [ ] Region selection works
- [ ] Window capture works
- [ ] Clipboard integration functional

#### Rollback
- Remove screenshot scripts and keybindings

---

### M303: Clipboard Manager
**Owner**: Tool Engineer
**Duration**: 1 hour
**Dependencies**: M302

#### Tasks
1. Install and configure Clipman
   ```bash
   yay -S clipman
   ```

2. Configure clipboard persistence
   ```lua
   # Add to Sway config
   exec wl-paste -t text --watch clipman store
   exec wl-paste -p -t text --watch clipman store -P
   ```

3. Create clipboard selection binding
   ```lua
   bindsym $mod+v exec clipman pick -t fuzzel
   ```

#### Validation
- [ ] Clipboard history preserved
- [ ] Selection interface works
- [ ] Both clipboards tracked
- [ ] Persistence across sessions

#### Rollback
```bash
pkill clipman
rm ~/.local/share/clipman.json
```

---

### M304: Screen Lock Configuration
**Owner**: Security Engineer
**Duration**: 2 hours
**Dependencies**: M205

#### Tasks
1. Configure Swaylock appearance
   ```ini
   # ~/.config/swaylock/config

   # Gruvbox colors
   color=1d2021
   inside-color=1d2021
   ring-color=8ec07c
   text-color=ebdbb2

   inside-clear-color=fabd2f
   ring-clear-color=fabd2f

   inside-ver-color=83a598
   ring-ver-color=83a598

   inside-wrong-color=fb4934
   ring-wrong-color=fb4934

   # Behavior
   show-failed-attempts
   daemonize
   indicator-radius=100
   indicator-thickness=10
   ```

2. Configure automatic locking with Swayidle
   ```lua
   # ~/.config/sway/config
   exec swayidle -w \
     timeout 300 'swaylock -f' \
     timeout 600 'swaymsg "output * dpms off"' \
     resume 'swaymsg "output * dpms on"' \
     before-sleep 'swaylock -f'
   ```

3. Create manual lock binding
   ```lua
   bindsym $mod+Alt+l exec swaylock
   ```

#### Validation
- [ ] Manual lock works
- [ ] Auto-lock after timeout
- [ ] Display turns off after extended idle
- [ ] Lock before sleep

#### Rollback
```bash
pkill swayidle
rm ~/.config/swaylock/config
```

---

### M305: Custom Script Migration
**Owner**: Script Engineer
**Duration**: 3 hours
**Dependencies**: M301, M302, M303

#### Tasks
1. Identify X11-dependent scripts
   ```bash
   grep -l "xprop\|xdotool\|xrandr" ~/.local/bin/* > ~/migration/x11-scripts.txt
   ```

2. Port brightness control script
   ```bash
   #!/usr/bin/env bash
   # ~/.local/bin/brightness-wayland

   case "$1" in
     up)
       brightnessctl set +10%
       ;;
     down)
       brightnessctl set 10%-
       ;;
     *)
       brightnessctl get
       ;;
   esac
   ```

3. Port window information script
   ```bash
   #!/usr/bin/env bash
   # ~/.local/bin/window-info-wayland

   swaymsg -t get_tree | jq '.. | select(.focused? == true)'
   ```

4. Create display configuration script
   ```bash
   #!/usr/bin/env bash
   # ~/.local/bin/display-config-wayland

   # List outputs
   swaymsg -t get_outputs

   # Configure external display
   swaymsg output HDMI-A-1 enable mode 1920x1080@60Hz position 1920 0
   ```

#### Validation
- [ ] All critical scripts ported
- [ ] Scripts test successfully
- [ ] No X11 dependencies remain
- [ ] Performance acceptable

#### Rollback
- Restore original scripts from backup

---

## Phase 4: Polish & Optimization

### M401: Theme Integration
**Owner**: UI Engineer
**Duration**: 2 hours
**Dependencies**: All Phase 2 & 3 modules

#### Tasks
1. Configure GTK theme for Wayland
   ```bash
   # ~/.config/sway/config
   exec_always {
     gsettings set org.gnome.desktop.interface gtk-theme 'Gruvbox-Dark-Hard'
     gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
     gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
   }
   ```

2. Set environment variables
   ```bash
   # ~/.config/sway/env
   export MOZ_ENABLE_WAYLAND=1
   export QT_QPA_PLATFORM=wayland
   export XDG_CURRENT_DESKTOP=sway
   export XDG_SESSION_TYPE=wayland
   ```

3. Configure application theming
   ```lua
   # Ensure consistent theming
   exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
   ```

#### Validation
- [ ] GTK applications use Gruvbox theme
- [ ] Qt applications themed correctly
- [ ] Cursor theme consistent
- [ ] Firefox runs in Wayland mode

#### Rollback
- Remove theme configuration lines

---

### M402: Performance Tuning
**Owner**: System Engineer
**Duration**: 2 hours
**Dependencies**: M401

#### Tasks
1. Configure GPU acceleration
   ```lua
   # ~/.config/sway/config
   # Enable hardware acceleration
   exec systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
   exec hash dbus-update-activation-environment 2>/dev/null && \
        dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
   ```

2. Optimize rendering settings
   ```bash
   # /etc/environment or ~/.profile
   export WLR_RENDERER_ALLOW_SOFTWARE=0
   export WLR_DRM_DEVICES=/dev/dri/card0
   ```

3. Configure adaptive sync (if supported)
   ```lua
   output eDP-1 adaptive_sync on
   ```

#### Validation
- [ ] GPU acceleration active
- [ ] No screen tearing
- [ ] Smooth window animations
- [ ] Power consumption acceptable

#### Rollback
- Remove performance tweaks

---

### M403: Autostart Services
**Owner**: System Engineer
**Duration**: 1 hour
**Dependencies**: M402

#### Tasks
1. Create systemd user target for Sway
   ```ini
   # ~/.config/systemd/user/sway-session.target
   [Unit]
   Description=Sway compositor session
   Documentation=man:systemd.special(7)
   BindsTo=graphical-session.target
   Wants=graphical-session-pre.target
   After=graphical-session-pre.target
   ```

2. Configure autostart applications
   ```lua
   # ~/.config/sway/config

   # Core services
   exec systemctl --user start sway-session.target

   # Applications
   exec nm-applet --indicator
   exec blueman-applet

   # Background services
   exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
   ```

3. Create session management script
   ```bash
   #!/usr/bin/env bash
   # ~/.local/bin/sway-session

   # Start systemd user services
   systemctl --user import-environment
   systemctl --user start sway-session.target

   # Launch Sway
   exec sway
   ```

#### Validation
- [ ] All services start automatically
- [ ] No duplicate service instances
- [ ] Clean shutdown process
- [ ] Session restoration works

#### Rollback
```bash
systemctl --user stop sway-session.target
```

---

### M404: Bootstrap Integration
**Owner**: DevOps Engineer
**Duration**: 3 hours
**Dependencies**: All previous modules

#### Tasks
1. Create Wayland bootstrap script
   ```bash
   #!/usr/bin/env bash
   # ~/.config/dotfiles/bootstrap/setup/common/20-wayland.sh

   set -euo pipefail

   info "Setting up Wayland/Sway environment..."

   # Check if already configured
   if [[ -f ~/.config/sway/config ]]; then
     info "Sway already configured"
     return 0
   fi

   # Install packages
   install_wayland_packages() {
     local packages=(
       sway swaylock swayidle swaybg
       waybar mako fuzzel
       grim slurp wl-clipboard
       brightnessctl wlr-randr
       xorg-xwayland
     )

     sudo pacman -S --needed "${packages[@]}"
   }

   # Deploy configurations
   deploy_configs() {
     # Configs are tracked in dotfiles
     info "Configurations deployed via dotfiles"
   }

   install_wayland_packages
   deploy_configs

   success "Wayland environment configured"
   ```

2. Update package lists
   ```bash
   # ~/.config/dotfiles/bootstrap/packages-wayland.txt
   sway
   swaylock
   swayidle
   waybar
   mako
   fuzzel
   grim
   slurp
   wl-clipboard
   brightnessctl
   wlr-randr
   xorg-xwayland
   qt5-wayland
   qt6-wayland
   xdg-desktop-portal-wlr
   ```

3. Create migration state file
   ```bash
   # Track migration progress
   echo "wayland_ready=true" > ~/.config/dotfiles/.migration-state
   ```

#### Validation
- [ ] Bootstrap script runs without errors
- [ ] Fresh system setup works
- [ ] All configs properly tracked
- [ ] Documentation updated

#### Rollback
```bash
rm ~/.config/dotfiles/bootstrap/setup/common/20-wayland.sh
```

---

## Phase 5: Cleanup & Finalization

### M501: Validation Testing
**Owner**: QA Engineer
**Duration**: 4 hours
**Dependencies**: All Phase 4 modules

#### Tasks
1. Create comprehensive test checklist
   ```markdown
   # Wayland Migration Test Checklist

   ## Core Functionality
   - [ ] System boots to Sway
   - [ ] All keybindings work
   - [ ] Window management correct
   - [ ] Workspace switching smooth

   ## Applications
   - [ ] Terminal emulator works
   - [ ] Web browser hardware accelerated
   - [ ] File manager functions
   - [ ] Text editor operational

   ## Multimedia
   - [ ] Audio playback works
   - [ ] Video playback smooth
   - [ ] Screen recording functional
   - [ ] Screenshots work

   ## System Integration
   - [ ] Notifications appear
   - [ ] System tray functional
   - [ ] Power management works
   - [ ] Network management works
   ```

2. Perform stress testing
   ```bash
   # Open multiple applications
   for i in {1..10}; do
     alacritty &
   done

   # Test window management under load
   # Monitor resource usage
   ```

3. Document any issues found
   ```bash
   echo "## Known Issues" >> ~/migration/issues.md
   ```

#### Validation
- [ ] All checklist items pass
- [ ] Performance acceptable
- [ ] No critical bugs
- [ ] User experience smooth

#### Rollback
- Full system rollback to snapshot if critical issues

---

### M502: Documentation Update
**Owner**: Documentation Engineer
**Duration**: 2 hours
**Dependencies**: M501

#### Tasks
1. Update CLAUDE.md
   ```markdown
   ## Window Management
   - **Display Server**: Wayland
   - **Compositor**: Sway (i3-compatible)
   - **Status Bar**: Waybar
   - **Launcher**: Fuzzel
   - **Notifications**: Mako
   ```

2. Update bootstrap documentation
   ```bash
   # Update README with Wayland instructions
   ```

3. Create migration guide
   ```markdown
   # ~/.config/dotfiles/docs/migration-x11-to-wayland.md

   ## Migration Complete
   - Date: [DATE]
   - Duration: [DAYS]
   - Issues Encountered: [LIST]
   - Solutions Applied: [LIST]
   ```

#### Validation
- [ ] Documentation accurate
- [ ] All changes documented
- [ ] Future reference clear
- [ ] Rollback procedures documented

#### Rollback
- Revert documentation changes

---

### M503: X11 Removal (Optional)
**Owner**: System Administrator
**Duration**: 1 hour
**Dependencies**: M502, 2-week stability period

#### Tasks
1. Create final backup snapshot
   ```bash
   snapshot-create "Pre-X11 removal - Wayland stable"
   ```

2. Remove X11 packages
   ```bash
   # Review carefully before execution
   sudo pacman -R bspwm sxhkd polybar picom rofi dunst \
     xorg-server xorg-xinit xorg-apps
   ```

3. Clean up X11 configurations
   ```bash
   # Archive old configs
   mkdir ~/migration/x11-archive
   mv ~/.config/bspwm ~/migration/x11-archive/
   mv ~/.config/sxhkd ~/migration/x11-archive/
   mv ~/.config/polybar ~/migration/x11-archive/
   ```

#### Validation
- [ ] System still boots
- [ ] No broken dependencies
- [ ] Disk space recovered
- [ ] No X11 processes running

#### Rollback
```bash
snapshot-rollback root [snapshot-number]
```

---

### M504: Final Snapshot and Sign-off
**Owner**: System Administrator
**Duration**: 30 minutes
**Dependencies**: M503 or 30-day stability

#### Tasks
1. Create completion snapshot
   ```bash
   snapshot-create "Wayland migration complete"
   ```

2. Update migration tracking
   ```bash
   echo "migration_complete=$(date +%Y-%m-%d)" >> ~/.config/dotfiles/.migration-state
   echo "x11_removed=${X11_REMOVED:-false}" >> ~/.config/dotfiles/.migration-state
   ```

3. Generate migration report
   ```bash
   cat > ~/migration/report.md << EOF
   # Migration Report

   ## Summary
   - Start Date: [START]
   - End Date: $(date +%Y-%m-%d)
   - Total Duration: [DAYS]
   - Downtime: 0 (parallel migration)

   ## Outcomes
   - Feature Parity: Achieved
   - Performance: Improved
   - Stability: Confirmed

   ## Recommendations
   - Monitor for 30 days
   - Keep X11 packages archived
   - Update documentation quarterly
   EOF
   ```

#### Validation
- [ ] Migration complete
- [ ] All documentation finalized
- [ ] Snapshots secured
- [ ] Sign-off obtained

#### Rollback
- Not applicable - migration complete

---

## Risk Mitigation

### Rollback Strategy
1. **Phase 0-1**: Simple package removal
2. **Phase 2-3**: Remove Sway configs, continue using BSPWM
3. **Phase 4**: Snapshot rollback to pre-migration state
4. **Phase 5**: Full restoration from initial snapshot

### Parallel Operation Guidelines
- Keep BSPWM as default for 2 weeks minimum
- Test Sway in separate TTY (Ctrl+Alt+F2)
- Maintain both configurations until stability proven
- Document all issues for resolution

### Critical Failure Points
1. **Graphics driver incompatibility**: Low risk (Intel graphics)
2. **Application incompatibility**: Use XWayland fallback
3. **Performance regression**: Rollback and investigate
4. **Configuration corruption**: Restore from dotfiles git

---

## Timeline Summary

### Week 1 (Days 1-7)
- Phase 0: Foundation (Day 1)
- Phase 1: Core Functionality (Days 2-5)
- Initial testing and stabilization (Days 6-7)

### Week 2 (Days 8-14)
- Phase 2: Feature Parity (Days 8-12)
- Continued parallel operation
- Daily driver testing begins (Day 14)

### Week 3 (Days 15-21)
- Phase 3: Tool Migration (Days 15-18)
- Phase 4: Polish & Optimization (Days 19-21)

### Week 4 (Days 22-28)
- Phase 5: Cleanup & Finalization (Days 22-24)
- Stability monitoring (Days 25-28)
- Optional X11 removal decision

### Post-Migration
- 30-day stability period
- Quarterly documentation review
- Performance optimization ongoing

---

## Success Criteria

1. **Functional**: All BSPWM features replicated in Sway
2. **Performance**: Equal or better than X11 baseline
3. **Stability**: No crashes in 7-day period
4. **Usability**: Muscle memory adapted, workflow maintained
5. **Maintainability**: Bootstrap system updated and tested

---

## Appendices

### A. Package Mapping Reference
[Detailed package equivalency table]

### B. Configuration Translation Guide
[Line-by-line conversion examples]

### C. Troubleshooting Handbook
[Common issues and solutions]

### D. Performance Benchmarks
[Metrics to track before/after]

---

*Document Version: 1.0*
*Last Updated: 2025-09-18*
*Status: Ready for Implementation*