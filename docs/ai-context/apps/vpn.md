# VPN Configuration with OpenVPN

## Ultra-Zen Philosophy
**"The path to the network flows through the vault, authenticated and encrypted"**

## Architecture
- **OpenVPN Client** - Secure tunneling daemon for VPN connections
- **Bitwarden Integration** - Credentials retrieved from vault via templates
- **Fish Functions** - Semantic wrappers for connection management (`vpc`, `vpd`, `vps`)
  - Work both as abbreviations (interactive) and functions (scripts)
  - Abbreviations expand: `vpc` → `vpn-connect`
  - Functions call: `vpc` → `vpn-connect` directly
- **Systemd System Service** - System-level service for reliability and auto-start on boot

## Configuration Files
- **VPN Config**: `home/dot_config/private_openvpn/goosevpn.conf.tmpl` - Main OpenVPN configuration
- **Auth File**: `home/dot_local/state/private_secrets/openvpn/goosevpn-auth.tmpl` - Credentials from Bitwarden
- **Service Installer**: `home/run_once_install-goosevpn-system-service.sh.tmpl` - Creates /etc/systemd/system/goosevpn.service
- **Auto-loading**: `home/dot_config/fish/conf.d/00-secrets.fish.tmpl` - Loads secrets into environment

## Usage
```bash
vpc  # Connect to VPN (vpn-connect) - uses systemd service
vpd  # Disconnect from VPN (vpn-disconnect) - stops systemd service
vps  # Check VPN status (vpn-status) - shows systemd service state

# Manual systemd control (requires sudo)
sudo systemctl start goosevpn      # Start VPN
sudo systemctl stop goosevpn       # Stop VPN
sudo systemctl enable goosevpn     # Auto-start on boot
sudo systemctl status goosevpn     # Check detailed status
```

## Security Features
- All config files use `private_` prefix (600 permissions)
- `auth-nocache` prevents password caching in memory
- Credentials only exist when Bitwarden is unlocked
- Secrets stored in `~/.local/state/secrets/` outside project directories
- Environment variables auto-loaded by Fish for script access