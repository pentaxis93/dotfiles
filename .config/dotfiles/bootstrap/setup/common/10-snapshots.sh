#!/usr/bin/env bash
# ============================================================================
# SNAPPER SNAPSHOT SYSTEM SETUP
# ============================================================================
# Purpose:
#   Configure automatic Btrfs snapshots using snapper with timeline cleanup
#
# How it works:
#   1. Creates snapper configs for root and home subvolumes
#   2. Configures retention policies (hourly/daily/weekly/monthly/yearly)
#   3. Enables systemd timers for automatic snapshots and cleanup
#
# Dependencies:
#   - Btrfs filesystem
#   - snapper package installed
#
# Usage:
#   Automatically run by bootstrap.sh
#   Manual run: ./10-snapshots.sh
#
# Troubleshooting:
#   - Check configs: sudo snapper list-configs
#   - View snapshots: sudo snapper -c root list
#   - Check timers: systemctl status snapper-timeline.timer
#
# Related Files:
#   - /etc/snapper/configs/root (auto-generated)
#   - /etc/snapper/configs/home (auto-generated)
#   - ~/.local/bin/snapshot-* (helper scripts)
# ============================================================================

set -euo pipefail

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warning() { echo -e "${YELLOW}[WARNING]${RESET} $*"; }
error() { echo -e "${RED}[ERROR]${RESET} $*"; }

# Check if running on Btrfs
check_btrfs() {
    if ! df -T / | grep -q btrfs; then
        warning "Root filesystem is not Btrfs. Skipping snapshot setup."
        exit 0
    fi
    info "Btrfs filesystem detected"
}

# Check if snapper is installed
check_snapper() {
    if ! command -v snapper &>/dev/null; then
        error "snapper is not installed. Install it with: sudo pacman -S snapper"
        exit 1
    fi
    info "snapper is installed"
}

# Create snapper configuration for a subvolume
create_snapper_config() {
    local config_name="$1"
    local subvolume="$2"

    # Check if config already exists
    if sudo snapper list-configs | grep -q "^${config_name}"; then
        info "Snapper config '${config_name}' already exists"
    else
        info "Creating snapper config '${config_name}' for ${subvolume}"
        sudo snapper -c "${config_name}" create-config "${subvolume}"
        success "Created snapper config '${config_name}'"
    fi

    # Configure retention policies
    configure_retention "${config_name}"
}

# Configure retention policies for timeline snapshots
configure_retention() {
    local config_name="$1"
    local config_file="/etc/snapper/configs/${config_name}"

    info "Configuring retention policies for '${config_name}'"

    # Enable timeline snapshots
    sudo sed -i 's/^TIMELINE_CREATE=.*/TIMELINE_CREATE="yes"/' "${config_file}"

    # Set retention limits (keep snapshots for different time periods)
    # Hourly: Keep 6 (last 6 hours)
    sudo sed -i 's/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY="6"/' "${config_file}"

    # Daily: Keep 7 (last week)
    sudo sed -i 's/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY="7"/' "${config_file}"

    # Weekly: Keep 4 (last month)
    sudo sed -i 's/^TIMELINE_LIMIT_WEEKLY=.*/TIMELINE_LIMIT_WEEKLY="4"/' "${config_file}"

    # Monthly: Keep 3 (last quarter)
    sudo sed -i 's/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY="3"/' "${config_file}"

    # Yearly: Keep 2
    sudo sed -i 's/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY="2"/' "${config_file}"

    # Set cleanup algorithms
    sudo sed -i 's/^TIMELINE_MIN_AGE=.*/TIMELINE_MIN_AGE="1800"/' "${config_file}"

    # Number cleanup: Don't keep more than 50 manual snapshots
    sudo sed -i 's/^NUMBER_LIMIT=.*/NUMBER_LIMIT="50"/' "${config_file}"
    sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT=.*/NUMBER_LIMIT_IMPORTANT="10"/' "${config_file}"

    # Enable number cleanup
    sudo sed -i 's/^NUMBER_CLEANUP=.*/NUMBER_CLEANUP="yes"/' "${config_file}"

    # Enable timeline cleanup
    sudo sed -i 's/^TIMELINE_CLEANUP=.*/TIMELINE_CLEANUP="yes"/' "${config_file}"

    # Enable empty pre-post cleanup
    sudo sed -i 's/^EMPTY_PRE_POST_CLEANUP=.*/EMPTY_PRE_POST_CLEANUP="yes"/' "${config_file}"

    success "Configured retention policies for '${config_name}'"
}

# Enable systemd timers for automatic snapshots
enable_timers() {
    info "Enabling automatic snapshot timers"

    # Enable and start the snapshot timeline timer
    if ! systemctl is-enabled snapper-timeline.timer &>/dev/null; then
        sudo systemctl enable --now snapper-timeline.timer
        success "Enabled snapper-timeline.timer"
    else
        info "snapper-timeline.timer already enabled"
    fi

    # Enable and start the cleanup timer
    if ! systemctl is-enabled snapper-cleanup.timer &>/dev/null; then
        sudo systemctl enable --now snapper-cleanup.timer
        success "Enabled snapper-cleanup.timer"
    else
        info "snapper-cleanup.timer already enabled"
    fi

    # Enable snapperd service (the daemon)
    if ! systemctl is-enabled snapperd.service &>/dev/null; then
        sudo systemctl enable --now snapperd.service
        success "Enabled snapperd.service"
    else
        info "snapperd.service already enabled"
    fi
}

# Create helper scripts for manual snapshot management
create_helper_scripts() {
    local bin_dir="$HOME/.local/bin"

    # Ensure bin directory exists
    mkdir -p "${bin_dir}"

    # Create snapshot-create script
    cat > "${bin_dir}/snapshot-create" << 'EOF'
#!/usr/bin/env bash
# Create manual snapshots of root and home

set -euo pipefail

DESCRIPTION="${1:-Manual snapshot}"

echo "Creating snapshots with description: ${DESCRIPTION}"

# Create root snapshot
if sudo snapper -c root create --description "${DESCRIPTION}" --type single; then
    echo "✓ Created root snapshot"
else
    echo "✗ Failed to create root snapshot"
fi

# Create home snapshot
if sudo snapper -c home create --description "${DESCRIPTION}" --type single; then
    echo "✓ Created home snapshot"
else
    echo "✗ Failed to create home snapshot"
fi

echo ""
echo "Recent snapshots:"
sudo snapper -c root list | tail -5
EOF
    chmod +x "${bin_dir}/snapshot-create"

    # Create snapshot-list script
    cat > "${bin_dir}/snapshot-list" << 'EOF'
#!/usr/bin/env bash
# List all snapshots

set -euo pipefail

echo "=== Root Snapshots ==="
sudo snapper -c root list

echo ""
echo "=== Home Snapshots ==="
sudo snapper -c home list
EOF
    chmod +x "${bin_dir}/snapshot-list"

    # Create snapshot-diff script
    cat > "${bin_dir}/snapshot-diff" << 'EOF'
#!/usr/bin/env bash
# Show differences between snapshots

set -euo pipefail

CONFIG="${1:-root}"
SNAPSHOT1="${2:-0}"
SNAPSHOT2="${3:-}"

if [ -z "$SNAPSHOT2" ]; then
    echo "Usage: snapshot-diff [config] [snapshot1] [snapshot2]"
    echo "  config: root or home (default: root)"
    echo "  snapshot1: first snapshot number (default: 0 for current)"
    echo "  snapshot2: second snapshot number"
    echo ""
    echo "Example: snapshot-diff root 0 5"
    exit 1
fi

sudo snapper -c "${CONFIG}" status "${SNAPSHOT1}..${SNAPSHOT2}"
EOF
    chmod +x "${bin_dir}/snapshot-diff"

    # Create snapshot-rollback script
    cat > "${bin_dir}/snapshot-rollback" << 'EOF'
#!/usr/bin/env bash
# Rollback to a specific snapshot (USE WITH CAUTION!)

set -euo pipefail

CONFIG="${1:-}"
SNAPSHOT="${2:-}"

if [ -z "$CONFIG" ] || [ -z "$SNAPSHOT" ]; then
    echo "Usage: snapshot-rollback <config> <snapshot-number>"
    echo "  config: root or home"
    echo "  snapshot: snapshot number to rollback to"
    echo ""
    echo "WARNING: This will revert all changes since the snapshot!"
    echo "Example: snapshot-rollback root 5"
    exit 1
fi

echo "WARNING: This will rollback ${CONFIG} to snapshot ${SNAPSHOT}"
echo "All changes since that snapshot will be lost!"
echo ""
read -p "Are you sure? Type 'yes' to continue: " confirm

if [ "$confirm" != "yes" ]; then
    echo "Rollback cancelled"
    exit 1
fi

echo "Creating pre-rollback snapshot for safety..."
sudo snapper -c "${CONFIG}" create --description "Pre-rollback backup" --type single

echo "Rolling back to snapshot ${SNAPSHOT}..."
sudo snapper -c "${CONFIG}" rollback "${SNAPSHOT}"

echo ""
echo "Rollback complete. You may need to reboot for all changes to take effect."
EOF
    chmod +x "${bin_dir}/snapshot-rollback"

    success "Created helper scripts in ${bin_dir}"
    info "Commands available: snapshot-create, snapshot-list, snapshot-diff, snapshot-rollback"
}

# Main setup
main() {
    info "Setting up Btrfs snapshot system with snapper..."

    check_btrfs
    check_snapper

    # Create configurations for root and home
    create_snapper_config "root" "/"
    create_snapper_config "home" "/home"

    # Enable automatic snapshots
    enable_timers

    # Create helper scripts
    create_helper_scripts

    # Show status
    echo ""
    info "Current snapshot configuration:"
    sudo snapper list-configs

    echo ""
    success "Snapshot system configured successfully!"
    info "Automatic snapshots will be taken hourly"
    info "Use 'snapshot-create' for manual snapshots"
    info "Use 'snapshot-list' to view all snapshots"
}

main "$@"