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
- `home/dot_config/fish/config.fish.tmpl` - Templated Fish shell configuration
- `home/dot_config/fish/functions/bw-*.fish.tmpl` - Bitwarden wrapper functions
- `home/dot_config/fish/functions/vpc.fish.tmpl` - VPN connect wrapper (works in scripts)
- `home/dot_config/fish/functions/vpd.fish.tmpl` - VPN disconnect wrapper
- `home/dot_config/fish/functions/vps.fish.tmpl` - VPN status wrapper

## Security & VPN
- `home/dot_config/private_openvpn/` - OpenVPN configuration files
- `home/dot_config/systemd/user/goosevpn.service.tmpl` - VPN systemd service
- `home/dot_local/state/private_secrets/` - Isolated secrets directory
- `home/dot_local/state/private_secrets/openvpn/goosevpn-auth.tmpl` - VPN credentials from Bitwarden

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

## Scripts & Utilities
- `scripts/generate-spectrum.py` - LAB color interpolation for spectrums
- `home/dot_local/bin/executable_transmission-vpn-bind.tmpl` - VPN binding script
- `home/dot_local/bin/executable_mpv.tmpl` - MPV wrapper for LF pre-selection
- `home/run_once_install-fvm.sh.tmpl` - Flutter Version Manager installation and setup
- `home/run_once_install-mpv-scripts.sh.tmpl` - MPV directory setup
- `home/run_once_install-weechat-scripts.sh.tmpl` - Installs xdccq.py
- `home/run_after_claude-code.sh` - Configure Claude Code and MCP servers (context7, playwright)

## Documentation
- `CLAUDE.md` - AI assistant instructions (this file!)
- `README.md` - User-facing project documentation
- `home/KEYBINDINGS.md` - Complete semantic keybinding mappings
- `docs/semantic-color-architecture.md` - Color system architecture