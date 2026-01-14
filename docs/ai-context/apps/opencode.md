# OpenCode Client/Server Setup

## Ultra-Zen Philosophy
**"The coding agent flows across machines; mani commands, babbie executes, intention manifests remotely"**

## Architecture
- **OpenCode Server** - Runs on babbie VPS via systemd user service
- **OpenCode Client** - Connects from mani via Tailscale network
- **Remote Directory Control** - `--dir` flag specifies working directory on babbie
- **Fish Functions** - Semantic wrappers for server control and client attachment
- **Auto-Start** - Systemd service with user lingering for persistent availability

## Configuration Files
- **Fish Functions (mani)**: `home/dot_config/fish/functions/oc*.fish.tmpl` - Client attachment and remote control
- **Package**: `home/.chezmoidata/packages.yaml` - OpenCode declaratively managed

## Server Setup (Babbie VPS)

### Systemd Service
Located at `~/.config/systemd/user/opencode-server.service` on babbie:
- **Auto-start**: Enabled on boot via user lingering
- **Auto-restart**: Restarts after 5 seconds on failure
- **Default directory**: `/home/pentaxis93/src`
- **Listening**: `0.0.0.0:4096` (accessible via Tailscale)

### Management Scripts (on Babbie)
Located in `~/.local/bin/` on babbie:
- `ocstart [directory]` - Start server with optional working directory
- `ocstop` - Stop server
- `ocrestart [directory]` - Restart server, optionally changing directory
- `ocstatus` - Show detailed server status and working directory

### Configuration
- `~/.config/opencode/server.conf` - Default working directory configuration

## Client Usage (Mani)

### Fish Functions

**`occ [directory]`** - Quick connect (recommended)
```bash
occ                       # Connect to server (uses server's current directory)
occ /home/pentaxis93/docs # Connect and work in ~/docs on babbie
occ ~/src                 # Connect and work in ~/src on babbie
```

**`oca [directory]`** - Attach to OpenCode server
```bash
oca                       # Attach to babbie server
oca /home/pentaxis93/go   # Attach with specific working directory
```

**`ocr {command} [args]`** - Remote server control
```bash
ocr status                # Check server status and working directory
ocr restart ~/docs        # Restart server in different directory
ocr stop                  # Stop server
ocr start ~/go            # Start server in specific directory
```

## Network Architecture

**Tailscale Network**:
- **babbie IP**: `100.125.136.73`
- **Server port**: `4096`
- **mani → babbie**: Secure Tailscale mesh network connection

## Key Features

### Remote Directory Specification
The `--dir` flag works correctly in OpenCode v1.1.18+ (client) and v1.1.19+ (server):
```bash
# Each client can work in a different directory
occ /home/pentaxis93/src
occ /home/pentaxis93/docs
```

### Persistent Server
- Auto-starts on babbie boot (systemd + user lingering)
- Survives babbie reboots
- Auto-restarts on crashes
- No manual intervention needed

### Remote Control
All server management can be done from mani:
```bash
ocr status           # Check if server is running
ocr restart ~/docs   # Change server directory remotely
```

## Version Requirements

- **Client (mani)**: OpenCode v1.1.18+
- **Server (babbie)**: OpenCode v1.1.19+
- **Known issue**: Earlier versions had bug where `--dir` referenced local paths ([Issue #5380](https://github.com/sst/opencode/issues/5380))

## Installation Flow

### Initial Setup (One-Time)

**On babbie** (manual setup, not in dotfiles):
1. Install OpenCode via official installer (creates `~/.opencode/bin/opencode`)
2. Create systemd service at `~/.config/systemd/user/opencode-server.service`
3. Create management scripts in `~/.local/bin/` (ocstart, ocstop, ocstatus, ocrestart)
4. Enable user lingering: `loginctl enable-linger pentaxis93`
5. Enable and start service: `systemctl --user enable --now opencode-server`

**On mani** (managed by chezmoi):
1. `chezmoi apply` installs opencode package from CachyOS repos
2. Fish functions deployed: `oca`, `occ`, `ocr`
3. Ready to connect via `occ`

### Upgrade Path

**Mani (local client)**:
```bash
chezmoi apply    # Updates opencode package via packages.yaml
```

**Babbie (server)**:
```bash
ssh babbie "~/.opencode/bin/opencode upgrade"
ocr restart      # Restart server with new version
```

## Troubleshooting

### Server Not Running
```bash
ocr status       # Check server status
ocr start        # Start if stopped
```

### Version Mismatch
```bash
# On mani:
opencode --version

# On babbie:
ssh babbie "~/.opencode/bin/opencode --version"

# Upgrade if needed
```

### Connection Issues
```bash
# Verify Tailscale connectivity
tailscale status
curl http://100.125.136.73:4096/global/health

# Check server is listening
ocr status
```

### Wrong Working Directory
```bash
# Check current server directory
ocr status | grep "Working Directory"

# Restart in correct directory
ocr restart /home/pentaxis93/src
```

## Security Considerations

**Current state**: Server is unauthenticated (no password)

**To add authentication** (on babbie):
```bash
# Edit systemd service
nano ~/.config/systemd/user/opencode-server.service

# Add under [Service]:
Environment="OPENCODE_SERVER_PASSWORD=your_password"
Environment="OPENCODE_SERVER_USERNAME=opencode"

# Reload and restart
systemctl --user daemon-reload
systemctl --user restart opencode-server
```

**Network security**: Server only accessible via Tailscale mesh network (not exposed to public internet)

## Benefits

- **Persistent Availability** - Server always running, no manual startup
- **Remote Control** - Full server management from mani
- **Directory Flexibility** - Work in different babbie directories without server restart
- **Auto-Recovery** - Systemd handles crashes and reboots
- **Secure Network** - Tailscale mesh encryption
- **Semantic Commands** - `occ`, `oca`, `ocr` follow dotfiles naming patterns

## Future Enhancements

**Potential additions**:
- Multiple server profiles (different babbie directories as named profiles)
- Session management (save/restore OpenCode sessions)
- Automatic server version sync with client
- Integration with chezmoi for babbie server setup (currently manual)

**Not planned (YAGNI)**:
- ❌ Password authentication (Tailscale network is already secure)
- ❌ Multi-server support (only have one VPS)
- ❌ Web interface (TUI is sufficient)

---

*"The code flows where intention directs; distance dissolves, machines unite, development knows no boundary."*
