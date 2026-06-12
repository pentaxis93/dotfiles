# Critical Files Reference

## Core Infrastructure
- `.chezmoiroot` - Sets `home/` as the source directory root
- `.chezmoiignore` - Prevent unwanted management
- `home/dot_config/chezmoi/chezmoi.toml.tmpl` - Chezmoi configuration with Bitwarden integration
- `home/dot_gitconfig.tmpl` - Templated Git identity

## Data Files
- `home/.chezmoidata/packages.yaml` - Declarative package definitions
- `home/.chezmoidata/colors.yaml` - Centralized Kanagawa Dragon color palette
- `home/.chezmoidata/keybindings.yaml` - Semantic keybinding definitions

## Template Fragments
Located in `home/.chezmoitemplates/`:
- `color-hex.tmpl` - Convert color to #hex format (CSS/KDL)
- `color-quoted.tmpl` - Convert color to "#hex" format (TOML)
- `color-rgb.tmpl` - Convert hex to rgb() format
- `color-rgba.tmpl` - Convert hex to rgba() with alpha
- `color-index.tmpl` - Map color names to terminal indices
- `newt-colors-dynamic.tmpl` - Dynamic NEWT_COLORS from colors.yaml
- `bitwarden-item.tmpl` - Retrieve complete Bitwarden item
- `bitwarden-password.tmpl` - Extract password field from item
- `bitwarden-username.tmpl` - Extract username field from item
- `bitwarden-note.tmpl` - Extract secure note content

## Shell Configuration
- `home/dot_zshrc.tmpl` - Templated zsh configuration (oh-my-zsh + robbyrussell + universal trio)
- `home/dot_config/zsh/aliases.zsh.tmpl` - Aliases (port of fish abbreviations)
- `home/dot_config/zsh/functions/*` - Autoload functions (ls, ssh on oreb, mp, vpc, tstart, zsnap, ...)
- `home/dot_config/zsh/functions/ssh` - oreb-only Kitty-aware wrapper; routes interactive plain-Kitty SSH through `kitten ssh` so remotes receive Kitty terminfo
- `home/dot_config/zsh/conf.d/*.zsh.tmpl` - Auto-loaded hooks (secrets, VPN killswitch, transmission aliases)
- `home/dot_config/zsh/functions/bw-*` - Bitwarden wrapper functions
- `home/dot_config/zsh/functions/{vpc,vpd,vps,vpn-connect,vpn-disconnect,vpn-status}` - VPN functions
- `home/dot_config/systemd/user/ssh-agent.service.tmpl` - User-level ssh-agent service
- `home/private_dot_ssh/private_config` - SSH client config; routes auth by caller — human → YubiKey, AI agent → software deploy key (`Match exec` on the agent-context probe)
- `home/private_dot_ssh/executable_agent-context` - Probe (exit 0 inside an agent); detects via env markers + `/proc` ancestry so agents never reach the hardware key
- `home/run_once_generate-agent-softkey.sh.tmpl` - Generates the agent software key `~/.ssh/id_ed25519` if absent (per-host secret, not repo-tracked)
- `home/run_once_install-oh-my-zsh.sh.tmpl` - Installs oh-my-zsh + universal trio
- `home/run_once_setup-ssh-agent.sh.tmpl` - Enables ssh-agent.service

## Security, VPN & Anonymity
- `home/dot_config/private_openvpn/` - OpenVPN configuration files
- `home/dot_config/systemd/user/goosevpn.service.tmpl` - VPN systemd service
- `home/dot_config/private_tor/torrc.tmpl` - Tor client-only SOCKS proxy config
- `home/dot_config/systemd/user/tor.service.tmpl` - Tor on-demand user service
- `home/dot_local/state/private_secrets/` - Isolated secrets directory
- `home/dot_local/state/private_secrets/openvpn/goosevpn-auth.tmpl` - VPN credentials from Bitwarden
- `home/dot_config/yubikey-touch-detector/service.conf` - Enables libnotify cue for silent FIDO2 touches
- `home/run_once_setup-yubikey-touch-detector.sh.tmpl` - Enables yubikey-touch-detector.service (GUI machines)

## Application Configs
- `home/dot_config/helix/config.toml.tmpl` - Helix editor settings and keybindings
- `home/dot_config/helix/languages.toml.tmpl` - Helix file-type specific settings
- `home/dot_config/helix/themes/kanagawa-dragon.toml.tmpl` - Helix theme with semantic colors
- `home/dot_config/mpv/mpv.conf.tmpl` - MPV main configuration
- `home/dot_config/mpv/input.conf.tmpl` - MPV Helix-native keybindings
- `home/dot_config/mpv/scripts/auto-save-position.lua.tmpl` - Position auto-save
- `home/dot_config/qutebrowser/config.py.tmpl` - Qutebrowser Python configuration
- `home/dot_config/private_weechat/weechat.conf.tmpl` - WeeChat main configuration
- `home/dot_config/transmission-daemon/settings.json.tmpl` - Transmission daemon config
- `home/dot_config/lazygit/config.yml` - Lazygit TUI with reverse video selections
- `home/dot_config/lf/lfrc.tmpl` - LF file manager configuration
- `home/dot_config/xdg-desktop-portal/niri-portals.conf` - Routes FileChooser/AppChooser/Settings to the gtk backend on Niri (the gnome backend crashes; fixes vanished Firefox file-upload dialogs)

## Scripts & Utilities
- `scripts/generate-spectrum.py` - LAB color interpolation for spectrums
- `home/dot_local/bin/executable_transmission-vpn-bind.tmpl` - VPN binding script
- `home/dot_local/bin/executable_mpv.tmpl` - MPV wrapper for LF pre-selection
- `home/run_once_install-fvm.sh.tmpl` - Flutter Version Manager installation and setup
- `home/run_once_install-mpv-scripts.sh.tmpl` - MPV directory setup
- `home/run_once_install-weechat-scripts.sh.tmpl` - Installs xdccq.py
- `home/run_after_claude-code.sh` - Configure Claude Code and MCP servers (context7, private-journal)

## Documentation
- `CLAUDE.md` - AI assistant instructions (this file!)
- `README.md` - User-facing project documentation
- `home/KEYBINDINGS.md` - Complete semantic keybinding mappings
- `docs/semantic-color-architecture.md` - Color system architecture
