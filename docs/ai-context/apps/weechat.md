# WeeChat IRC Client

## Ultra-Zen Philosophy
**"The river of communication flows through a more mindful channel; downloads arrive with greater wisdom"**

## Architecture
- **WeeChat Client** - Modern, extensible IRC client with superior vi-mode support
- **IRC Highway** - Pre-configured server connection with auto-join #ebooks
- **DCC Auto-Accept** - Enhanced file acceptance (10MB limit) to ~/Downloads
- **Kanagawa Theme** - Full Kanagawa Dragon colors from centralized palette
- **Vi-Mode Navigation** - Comprehensive vi and Helix-native keybindings
- **Zsh Integration** - Semantic functions for WeeChat management (wcc, wcs, wcd)

## Configuration Files
- **Main Config**: `home/dot_config/private_weechat/weechat.conf.tmpl` - Core settings and DCC configuration
- **IRC Config**: `home/dot_config/private_weechat/irc.conf.tmpl` - Server settings and channels
- **Xfer Config**: `home/dot_config/private_weechat/xfer.conf.tmpl` - File transfer and auto-accept settings
- **Alias Config**: `home/dot_config/private_weechat/alias.conf.tmpl` - Trust management aliases (/t, /tlist, etc.)
- **Keybindings**: `home/dot_config/private_weechat/keys.conf.tmpl` - Vi-style and Helix-native keys
- **Zsh Functions**: `home/dot_config/zsh/functions/wc*` - Management commands (wcc, wcs, wcd)
- **Script Installer**: `home/run_once_install-weechat-scripts.sh.tmpl` - Auto-installs xdccq.py

## Usage
```bash
wcc                  # Launch WeeChat (weechat-connect)
wcs                  # Show WeeChat and download status (weechat-status)
wcd                  # Download management (weechat-downloads)
wcd list             # List recent downloads
wcd clean            # Clean old downloads (>30 days)
wcd open             # Open downloads directory

# Within WeeChat:
/msg bot xdcc send #123     # Request file from XDCC bot

# xdccq.py script commands (auto-installed):
/xdccq add <bot> <packs>    # Queue downloads (e.g., /xdccq add SearchOok 1-5,10,15)
/xdccq list                 # Show all queued packs
/xdccq list <bot>           # Show queued packs for specific bot
/xdccq clear <bot>          # Clear specific bot's queue
/xdccq clearall             # Clear all queues

/dcc                        # Open DCC buffer (Alt+d)
/help                       # Show help (?)
/quit                       # Exit WeeChat
Alt+1-9                     # Switch to buffer 1-9
Alt+h/l                     # Previous/next buffer
Alt+j/k                     # Window down/up
ge                          # Go to end (Helix-native)
/                           # Search
```

## Key Improvements over irssi
- **Better Vi-Mode** - Native vi-mode with comprehensive bindings
- **Modern UI** - Split panes, better colors, more customizable
- **Script Support** - Python/Perl/Ruby plugin ecosystem
- **Better DCC** - Enhanced file transfer display and management
- **Unicode Support** - Superior emoji and special character handling
- **Extensibility** - Large ecosystem of scripts and plugins
- **xdccq.py Script** - Automatically manages auto_accept_nicks for XDCC bots

## Security Features
- **Auto-Accept Management** - xdccq.py dynamically adds bot names to auto_accept_nicks
- **Download Directory** - All files go to ~/Downloads with .part suffix
- **Auto-Resume** - Intelligent partial download continuation
- **Auto-Rename** - Prevents overwriting existing files
- **CRC Checking** - Optional CRC32 verification for transfers

## XDCC Auto-Accept System

### Managing Bot Trust List

**1. Identify Bot Names:**
- When a transfer is waiting, check the xfer buffer (Alt+x or `/buffer xfer.list`)
- Bot name appears after `***` (e.g., `*** Search`)
- Or look in #ebooks for bots responding to `@search` or `!list` commands

**2. Add Bots Using Simple Aliases:**
```bash
/t Search           # Trust "Search" bot (super quick!)
/trust Search       # Same as /t but more explicit
/tlist              # Show current trust list
/untrust Search     # Remove a bot from trust list
/tclear             # Clear entire trust list (use carefully!)
```
- Only need to add each bot once - setting persists across restarts
- Future transfers from trusted bots auto-accept immediately

**3. xdccq.py Script (for queuing):**
```bash
/xdccq add <bot> <packs>     # Queue downloads AND auto-add bot to trust list
/xdccq list                  # Show queued downloads
/xdccq clear <bot>           # Clear bot's queue
```
- When you use `/xdccq add`, it automatically adds the bot to auto_accept_nicks
- Great for queuing multiple packs: `/xdccq add SearchOok 1-5,10,15`

**Mnemonic: "X-Duck Queue"** 🦆
- Think of XDCC downloads like ducks in a row
- **X**tra **D**ownloads? **C**leverly **C**ueue **Q**uickly!

## IRC Highway Configuration
- Server: irc.irchighway.net:6667
- Auto-connects on startup
- Auto-joins #ebooks channel
- Nick from system username ({{ .chezmoi.username }})