# Transmission BitTorrent with VPN Killswitch

## Ultra-Zen Philosophy
**"The river flows only through the secure tunnel; when the tunnel closes, the river stops"**

## Architecture
- **Transmission Daemon** - BitTorrent client bound to VPN interface IP
- **VPN Killswitch** - Transmission stops automatically if VPN disconnects
- **Magnet Link Handler** - Browser clicks on magnet links auto-add to Transmission
- **Minimal Seeding** - Ultra-low upload limits (10KB/s, 0.1 ratio, 5min idle)
- **Security Hardened** - Required encryption, DHT/PEX enabled for public trackers, LPD disabled, blocklist enabled
- **Tremc TUI** - Kanagawa-themed terminal interface with vi keybindings

## Configuration Files
- **Daemon Config**: `home/dot_config/transmission-daemon/settings.json.tmpl` - Security-focused settings
- **VPN Binding**: `home/dot_local/bin/executable_transmission-vpn-bind.tmpl` - Dynamic IP updater
- **Magnet Handler**: `home/dot_local/bin/executable_transmission-magnet-handler.tmpl` - Browser magnet link handler
- **Desktop Entry**: `home/dot_local/share/applications/transmission-magnet.desktop.tmpl` - System handler registration
- **Systemd Service**: `home/dot_config/systemd/user/transmission-daemon.service.tmpl` - VPN-dependent service
- **Fish Functions**: `home/dot_config/fish/functions/t*.fish.tmpl` - Semantic management commands
- **Tremc Config**: `home/dot_config/tremc/settings.cfg.tmpl` - Kanagawa theme and vi navigation

## Usage
```bash
tstart   # Start transmission (checks VPN, updates binding)
tstop    # Stop transmission daemon
tstatus  # Show daemon and VPN binding status
tadd     # Add torrent file or magnet link
tlist    # List active torrents
tremove  # Remove torrent by ID
tui      # Launch tremc interface
```

## Security Features
- **Bind to VPN IP** - Only works when VPN is connected (bind-address-ipv4)
- **Auto-stop on VPN disconnect** - Killswitch via systemd BindsTo
- **Minimal upload** - 10KB/s limit, 0.1 ratio, 5-minute idle timeout
- **Full encryption** - Peer connections require encryption
- **Balanced discovery** - DHT and PEX enabled for public tracker performance, LPD disabled
- **Random ports** - New peer port on each start
- **Download to ~/Videos** - Organized media storage

## VPN Integration
- Transmission service depends on goosevpn.service
- VPN IP dynamically detected and bound on startup
- Fish conf.d hook monitors VPN status
- Manual `tstart` includes automatic VPN check

## Browser Magnet Link Integration
- **Click-to-Add** - Clicking magnet links in browser automatically adds to Transmission
- **Handler Flow** - Browser → x-scheme-handler/magnet → Desktop Entry → Fish Script → tadd
- **Handlr Registration** - Magnet links registered with handlr in setup script
- **Automatic Daemon Start** - Handler auto-starts daemon if not running (via tadd)
- **VPN Checking** - All magnet additions check VPN status before adding
- **Desktop Notifications** - Visual feedback on successful/failed additions

## Tremc TUI Features
- **Kanagawa Theme**: Full color customization from centralized palette
- **Vi Keybindings**: Helix-native navigation (hjkl, ge for end)
- **Launch Command**: `tui` function auto-starts daemon if needed
- **Profile Support**: Pre-configured filters for active/downloading/seeding
- **Confirmation Dialogs**: Protects against accidental removal/deletion