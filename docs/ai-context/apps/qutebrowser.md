# Qutebrowser Web Browser

## Ultra-Zen Philosophy
**"The keyboard becomes the interface; intention becomes action"**

## Architecture
- **Python Configuration** - Flexible config.py with full programmatic control
- **Kanagawa Theme** - Complete UI theming from centralized color palette
- **Semantic Keybindings** - Core bindings use semantic templates from keybindings.yaml
  - 12 template-based bindings: navigation (h/j/k/l, gg/ge, gh/gl), search (/?), dismiss (q/Q)
  - Helix-native: ge for end, gh/gl for line start/end, d/u for half-page
  - All core bindings generated from semantic definitions
- **Privacy-Focused** - Ad blocking, tracking protection, dark mode preference
- **Zsh Integration** - Semantic functions for browser management (qb, qbp, qbs)
- **MPV Integration** - Seamless video playback with external player

## Configuration Files
- **Main Config**: `home/dot_config/qutebrowser/config.py.tmpl` - Complete browser configuration
- **Zsh Functions**: `home/dot_config/zsh/functions/qb*` - Management commands (qb, qbp, qbs)
- **Niri Integration**: Browser launch via semantic keybinding (Mod+B from keybindings.yaml)

## Key Features
- **Full Kanagawa Theme** - Every UI element themed from centralized palette
  - Mode-aware status bar (normal/insert/command/private)
  - Themed tabs with pinned tab support
  - Completion widget with category headers
  - Hints with high-contrast colors
  - Download progress indicators
- **Helix-Native Navigation** - Consistent with editor and other tools
  - `ge` for end (not G)
  - `gh/gl` for line start/end
  - `d/u` for half-page scrolling
  - Semantic keybinding philosophy throughout
- **Privacy & Security** - Thoughtful defaults
  - Ad blocking via EasyList and EasyPrivacy
  - No 3rd-party cookies
  - Do Not Track header
  - Dark mode preference for websites
  - HTTPS-only when possible
- **Search Engines** - Quick access with keywords
  - DuckDuckGo (default) - Privacy-focused
  - `ddg` - DuckDuckGo explicit
  - `g` - Google
  - `gh` - GitHub search
  - `aw` - Arch Wiki
  - `aur` - AUR packages
  - `yt` - YouTube
  - `wi` - Wikipedia
- **MPV Integration** - Video playback with external player
  - `,m` on any page to play current URL
  - `,M` on hinted link to play specific video
  - Seamless handoff to MPV with all features
- **Session Management** - Auto-save sessions
  - Automatic session saving on quit
  - Resume tabs on restart
  - `qbs` command shows session info

## Usage
```bash
qb                   # Launch qutebrowser (qutebrowser-launch)
qbp                  # Launch private browsing window (qutebrowser-private)
qbs                  # Show browser status and session info (qutebrowser-status)
Mod+B                # Launch from Niri (semantic browser invoke)
```

## Keybindings Reference

### Navigation (Helix-native)
- `ge` - Go to end (scroll to bottom - NOT G)
- `gg` - Go to start (scroll to top)
- `gh` - Go home (scroll to 0%)
- `gl` - Go line end (scroll to 100%)
- `j/k` - Scroll down/up smoothly
- `h/l` - Scroll left/right
- `d/u` - Half-page down/up (Helix-style)

### Tabs
- `J/K` - Previous/next tab
- `gT/gt` - Alternative tab navigation
- `gc` - Close tab
- `q` - Close current tab
- `Q` - Quit browser

### History
- `H` - Back in history
- `L` - Forward in history

### Hints (link following)
- `f` - Follow link in current tab
- `F` - Follow link in background tab
- `;y` - Yank (copy) link URL
- `;Y` - Yank link to primary selection

### Search
- `/` - Search forward
- `?` - Search backward
- `n` - Next search result
- `N` - Previous search result

### Zoom
- `+` - Zoom in
- `-` - Zoom out
- `=` - Reset zoom

### Yank operations
- `yy` - Yank current URL
- `yt` - Yank page title
- `yd` - Yank domain
- `yp` - Yank pretty URL

### Custom integrations (comma prefix)
- `,m` - Play current URL with MPV
- `,M` - Play hinted link with MPV
- `,r` - Reload page
- `,R` - Force reload (bypass cache)
- `,p` - Open private window
- `,a` - Reader mode (readability)

### Command mode
- `:` - Enter command mode
- `:w` - Save session
- `:wq` - Save and quit
- `:q` - Close tab
- `:qa` - Quit all
- `:h` - Help

## Key Philosophy
- **Keyboard-First** - Mouse optional for all operations
- **Vi-Like Navigation** - Familiar patterns for vim users
- **Helix Improvements** - Semantic enhancements where they improve clarity
- **Comma Prefix** - Custom commands use comma to avoid conflicts
- **Mode Awareness** - Status bar colors indicate current mode