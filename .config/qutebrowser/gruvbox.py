# ============================================================================
# GRUVBOX DARK HARD THEME FOR QUTEBROWSER
# ============================================================================
# Purpose:
#   Comprehensive Gruvbox Dark Hard color scheme for qutebrowser
#   matching the system-wide theme with aqua accent hierarchy
#
# Color Philosophy:
#   - Background: #1d2021 (hard dark) for primary surfaces
#   - Accent: #8ec07c (bright aqua) for active/focused elements
#   - Secondary: #689d6a (regular aqua) for inactive/info elements
#   - Semantic colors for errors, warnings, success states
#
# Related Files:
#   ~/.config/alacritty/alacritty.toml - Terminal colors
#   ~/.config/polybar/config.ini - Status bar colors
#   ~/.config/bspwm/bspwmrc - Window border colors
#
# Testing:
#   Run: qutebrowser --temp-basedir
#   Check all UI elements match the system theme
# ============================================================================

# Base16 qutebrowser template by theova
# Gruvbox dark, hard scheme by Dawid Kurek (morhetz)
# Modified for consistency with system-wide configuration

# ============================================================================
# COLOR PALETTE
# ============================================================================
# Background colors
bg0_h = '#1d2021'  # Hard dark background (primary)
bg0 = '#282828'    # Normal dark background
bg1 = '#3c3836'    # Dark gray (secondary backgrounds)
bg2 = '#504945'    # Medium gray
bg3 = '#665c54'    # Light gray
bg4 = '#7c6f64'    # Lighter gray

# Foreground colors
fg0 = '#fbf1c7'    # Light cream (brightest)
fg1 = '#ebdbb2'    # Normal cream (primary text)
fg2 = '#d5c4a1'    # Darker cream
fg3 = '#bdae93'    # Dark cream
fg4 = '#a89984'    # Gray (muted text)

# Accent colors (our aqua hierarchy)
bright_aqua = '#8ec07c'   # Primary accent (active/focused)
normal_aqua = '#689d6a'   # Secondary accent (inactive/info)

# Semantic colors
bright_red = '#fb4934'    # Errors, alerts
normal_red = '#cc241d'    # Less urgent errors
bright_green = '#b8bb26'  # Success states
normal_green = '#98971a'  # Less prominent success
bright_yellow = '#fabd2f' # Warnings, hints
normal_yellow = '#d79921' # Less urgent warnings
bright_blue = '#83a598'   # Information
normal_blue = '#458588'   # Less prominent info
bright_purple = '#d3869b' # Special elements
normal_purple = '#b16286' # Less prominent special
bright_orange = '#fe8019' # Highlights
normal_orange = '#d65d0e' # Less prominent highlights

# ============================================================================
# COMPLETION WIDGET
# ============================================================================
# Popup showing suggestions when typing commands/URLs

c.colors.completion.fg = [fg1, fg2, fg1]
c.colors.completion.odd.bg = bg1
c.colors.completion.even.bg = bg0_h
c.colors.completion.category.fg = bright_yellow
c.colors.completion.category.bg = bg0_h
c.colors.completion.category.border.top = bg0_h
c.colors.completion.category.border.bottom = bg0_h
c.colors.completion.item.selected.fg = bg0_h
c.colors.completion.item.selected.bg = bright_aqua          # Active selection
c.colors.completion.item.selected.border.top = bright_aqua
c.colors.completion.item.selected.border.bottom = bright_aqua
c.colors.completion.item.selected.match.fg = bg0_h
c.colors.completion.match.fg = bright_green                  # Matching text
c.colors.completion.scrollbar.fg = fg4
c.colors.completion.scrollbar.bg = bg0_h

# ============================================================================
# CONTEXT MENU
# ============================================================================
# Right-click menus

c.colors.contextmenu.disabled.bg = bg1
c.colors.contextmenu.disabled.fg = fg4
c.colors.contextmenu.menu.bg = bg0_h
c.colors.contextmenu.menu.fg = fg1
c.colors.contextmenu.selected.bg = bright_aqua
c.colors.contextmenu.selected.fg = bg0_h

# ============================================================================
# DOWNLOADS
# ============================================================================
# Download bar at the bottom

c.colors.downloads.bar.bg = bg0_h
c.colors.downloads.start.fg = bg0_h
c.colors.downloads.start.bg = normal_blue
c.colors.downloads.stop.fg = bg0_h
c.colors.downloads.stop.bg = bright_green
c.colors.downloads.error.fg = bright_red
c.colors.downloads.system.fg = 'rgb'
c.colors.downloads.system.bg = 'rgb'

# ============================================================================
# HINTS
# ============================================================================
# Labels shown when pressing 'f' to follow links

c.colors.hints.fg = bg0_h
c.colors.hints.bg = bright_yellow                    # High visibility yellow
c.colors.hints.match.fg = fg1
c.hints.border = f'1px solid {bg0_h}'

# ============================================================================
# KEYHINT WIDGET
# ============================================================================
# Shows available key bindings

c.colors.keyhint.fg = fg1
c.colors.keyhint.suffix.fg = bright_yellow
c.colors.keyhint.bg = bg0_h

# ============================================================================
# MESSAGES
# ============================================================================
# Info/warning/error messages

c.colors.messages.error.fg = bg0_h
c.colors.messages.error.bg = bright_red
c.colors.messages.error.border = bright_red
c.colors.messages.warning.fg = bg0_h
c.colors.messages.warning.bg = bright_yellow
c.colors.messages.warning.border = bright_yellow
c.colors.messages.info.fg = fg1
c.colors.messages.info.bg = bg0_h
c.colors.messages.info.border = bg0_h

# ============================================================================
# PROMPTS
# ============================================================================
# Input prompts and questions

c.colors.prompts.fg = fg1
c.colors.prompts.border = bg0_h
c.colors.prompts.bg = bg0_h
c.colors.prompts.selected.bg = bg2
c.colors.prompts.selected.fg = fg1

# ============================================================================
# STATUS BAR
# ============================================================================
# Bar at the bottom showing mode/URL/progress

# Normal mode
c.colors.statusbar.normal.fg = fg1
c.colors.statusbar.normal.bg = bg0_h

# Insert mode (entering text)
c.colors.statusbar.insert.fg = bg0_h
c.colors.statusbar.insert.bg = normal_green

# Passthrough mode (passing all keys to page)
c.colors.statusbar.passthrough.fg = bg0_h
c.colors.statusbar.passthrough.bg = normal_blue

# Private browsing mode
c.colors.statusbar.private.fg = bg0_h
c.colors.statusbar.private.bg = normal_purple

# Command mode
c.colors.statusbar.command.fg = fg1
c.colors.statusbar.command.bg = bg0_h
c.colors.statusbar.command.private.fg = fg1
c.colors.statusbar.command.private.bg = bg0_h

# Caret mode (text selection)
c.colors.statusbar.caret.fg = bg0_h
c.colors.statusbar.caret.bg = bright_purple
c.colors.statusbar.caret.selection.fg = bg0_h
c.colors.statusbar.caret.selection.bg = bright_aqua

# Progress bar
c.colors.statusbar.progress.bg = bright_aqua

# URL colors in status bar
c.colors.statusbar.url.fg = fg1
c.colors.statusbar.url.error.fg = bright_red
c.colors.statusbar.url.hover.fg = bright_blue
c.colors.statusbar.url.success.http.fg = normal_green
c.colors.statusbar.url.success.https.fg = bright_green
c.colors.statusbar.url.warn.fg = bright_yellow

# ============================================================================
# TABS
# ============================================================================
# Tab bar at the top

# Tab bar background
c.colors.tabs.bar.bg = bg0_h

# Individual tabs
c.colors.tabs.odd.fg = fg1
c.colors.tabs.odd.bg = bg1
c.colors.tabs.even.fg = fg1
c.colors.tabs.even.bg = bg1

# Selected tab (active)
c.colors.tabs.selected.odd.fg = bg0_h
c.colors.tabs.selected.odd.bg = bright_aqua         # Bright aqua for active tab
c.colors.tabs.selected.even.fg = bg0_h
c.colors.tabs.selected.even.bg = bright_aqua

# Pinned tabs
c.colors.tabs.pinned.odd.fg = fg1
c.colors.tabs.pinned.odd.bg = normal_aqua           # Regular aqua for pinned
c.colors.tabs.pinned.even.fg = fg1
c.colors.tabs.pinned.even.bg = normal_aqua
c.colors.tabs.pinned.selected.odd.fg = bg0_h
c.colors.tabs.pinned.selected.odd.bg = bright_aqua
c.colors.tabs.pinned.selected.even.fg = bg0_h
c.colors.tabs.pinned.selected.even.bg = bright_aqua

# Tab indicators (audio, muted, etc)
c.colors.tabs.indicator.start = bright_aqua
c.colors.tabs.indicator.stop = normal_aqua
c.colors.tabs.indicator.error = bright_red
c.colors.tabs.indicator.system = 'rgb'

# ============================================================================
# WEBPAGE COLORS
# ============================================================================
# How to render webpages

# Dark mode settings
c.colors.webpage.bg = bg0_h                         # Force dark background
c.colors.webpage.preferred_color_scheme = 'dark'    # Request dark mode from sites
c.colors.webpage.darkmode.enabled = False           # Don't force dark mode (can break sites)

print("Gruvbox Dark Hard theme loaded!")