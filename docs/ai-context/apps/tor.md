# Tor Anonymity Proxy & .onion Browsing

## Ultra-Zen Philosophy
**"The onion peels in layers; each circuit hides the last, each hop forgets the origin"**

## Architecture
- **Tor Daemon** - SOCKS5 proxy on `127.0.0.1:9050` via systemd user service
- **Tor Browser** - Dedicated anti-fingerprint browser for .onion services (AUR)
- **torsocks** - Transparent CLI wrapper for routing commands through Tor
- **nyx** - Tor circuit monitor TUI (like tremc for transmission)
- **Composable with VPN** - Tor over VPN recommended but not enforced
- **On-demand** - Started when needed, stopped when done (not always-on like VPN)
- **Waybar Integration** - `⧫` indicator visible only when Tor is active

## Configuration Files
- **Tor Config**: `home/dot_config/private_tor/torrc.tmpl` - Client-only SOCKS proxy with control port
- **Systemd Service**: `home/dot_config/systemd/user/tor.service.tmpl` - On-demand user service
- **Setup Script**: `home/run_once_setup-tor.sh.tmpl` - Creates data directory, daemon-reload
- **Fish Functions**: `home/dot_config/fish/functions/tor-*.fish.tmpl` - Connection management
- **Waybar Script**: `home/dot_local/bin/executable_waybar-tor-check.tmpl` - Status indicator
- **Package**: `home/.chezmoidata/packages.yaml` - tor, torsocks, nyx (pacman) + tor-browser (AUR)

## Usage

### Browse .onion Services
```bash
vpc                    # Optional: start VPN first (recommended)
torc                   # Start Tor daemon
tor-browser            # Launch Tor Browser → navigate to .onion sites
tord                   # Stop Tor when done
```

### CLI Anonymity
```bash
torc                   # Start Tor daemon
torsocks curl https://check.torproject.org/api/ip  # Verify exit IP
torsocks ssh user@host                              # Anonymous SSH
torsocks wget https://example.onion/file            # Anonymous download
tord                   # Stop when done
```

### Monitor Circuits
```bash
nyx                    # TUI circuit monitor (connects to control port 9051)
```

### Management Commands
```bash
torc    # Start Tor (tor-connect)
tord    # Stop Tor (tor-disconnect)
tors    # Check status, topology, exit IP (tor-status)
```

## Network Topology

### Tor over VPN (Recommended)
```
You → VPN → Tor → .onion
```
- ISP sees VPN traffic only (cannot tell you use Tor)
- VPN provider sees Tor connections (not what you access)
- Tor entry node sees VPN IP, not your real IP
- **Setup**: `vpc` then `torc`

### Tor Standalone
```
You → Tor → .onion
```
- ISP can see you connect to Tor entry nodes
- Tor entry node sees your real IP
- **Setup**: `torc` only

### How to Choose
- **Tor over VPN**: When you want to hide Tor usage from ISP. Requires trusting VPN not to log.
- **Tor standalone**: Simpler, fewer trust points. Acceptable when ISP seeing Tor is not a concern.

## Security Features
- **Client-only** - No relay, no exit node, no hidden services (torrc has no ORPort/ExitPolicy)
- **Private config** - `private_tor/` prefix gives 600 permissions on torrc
- **User-space daemon** - No root privileges needed (systemd user service)
- **Security hardening** - NoNewPrivileges, ProtectSystem=strict, ProtectHome=read-only
- **Cookie auth** - nyx connects via CookieAuthentication (no password in config)
- **Per-command routing** - Only torsocks-wrapped commands use Tor (no system-wide routing)
- **DNS through Tor** - torsocks routes DNS through Tor circuits (no DNS leaks)

## Why Tor Browser (Not Existing Browsers)
- Zen Browser and qutebrowser have unique fingerprints (extensions, settings, canvas, fonts)
- Even with SOCKS proxy, .onion services could correlate sessions via fingerprint
- Tor Browser has anti-fingerprinting built in — all users look identical
- Tor Browser bundles its own Tor instance for complete isolation

## Waybar Integration
- `⧫` symbol appears in magenta when Tor is active
- Invisible when Tor is stopped
- Positioned next to VPN indicator for clear topology awareness

## Machine Scope
- **Desktop/laptop**: Full Tor stack (daemon + torsocks + nyx + Tor Browser + Waybar)
- **VPS**: Excluded via .chezmoiignore (no anonymity browsing need on server)

## Data Directories
```
~/.config/tor/torrc           # Configuration (chezmoi-managed)
~/.local/share/tor/           # Runtime state (NOT chezmoi-managed)
├── tor.log                   # Daemon log
├── control_auth_cookie       # nyx authentication
├── cached-certs              # Cached directory certificates
├── cached-microdesc*         # Cached relay descriptors
└── state                     # Guard and circuit state
```

## Troubleshooting

### Tor fails to bootstrap
```bash
# Check the log
cat ~/.local/share/tor/tor.log | tail -20

# Check service status
systemctl --user status tor

# Verify network connectivity
curl -s https://check.torproject.org/
```

### nyx can't connect
```bash
# Verify control port is enabled in torrc
grep ControlPort ~/.config/tor/torrc

# Check cookie file exists
ls -la ~/.local/share/tor/control_auth_cookie
```

### torsocks not routing correctly
```bash
# Verify Tor is running
tors

# Test with explicit SOCKS
torsocks curl -s https://check.torproject.org/api/ip
# Should return a Tor exit IP, not your real IP
```

### Port conflict on 9050
```bash
# Check what's using the port
ss -tlnp | grep 9050

# If system tor is running, stop it first
sudo systemctl stop tor
```

---

*"The path that cannot be traced was never walked — it was routed through three strangers who forgot your name."*
