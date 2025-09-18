# ============================================================================
# QUTEBROWSER CONFIGURATION - DUAL-MODAL NAVIGATION & GRUVBOX DARK HARD
# ============================================================================
# Purpose:
#   Configure qutebrowser with consistent dual-modal navigation (vim/arrows)
#   matching the system-wide navigation philosophy while maintaining
#   qutebrowser's powerful vim-style workflow
#
# NOTE: Numpad support is limited - Qt/qutebrowser cannot distinguish
#       numpad keys from regular number keys when NumLock is on
#
# Navigation Philosophy:
#   - Maintain muscle memory across all applications
#   - Support vim keys and arrow keys consistently
#   - Use appropriate modifiers to avoid conflicts
#   - Keep defaults where they make sense
#
# Related Files:
#   ~/.config/qutebrowser/gruvbox.py - Color scheme definition
#   ~/.config/sxhkd/sxhkdrc - Super+b launches qutebrowser
#   ~/.config/polybar/scripts/window-title-daemon.sh - Shows browser tabs in polybar
#
# Testing:
#   After changes, run: qutebrowser --temp-basedir
#   This starts a clean instance for testing without affecting your session
# ============================================================================

import os
import sys
from pathlib import Path

# Load the base configuration (includes Gruvbox theme)
config.load_autoconfig(False)

# Import Gruvbox theme if it exists
gruvbox_path = Path(__file__).parent / 'gruvbox.py'
if gruvbox_path.exists():
    config.source(str(gruvbox_path))

# ============================================================================
# GENERAL SETTINGS
# ============================================================================

# Downloads
c.downloads.location.directory = '~/Downloads'
c.downloads.location.prompt = True                  # Ask where to save for each download
c.downloads.remove_finished = 10000                 # Remove after 10 seconds

# Tabs
c.tabs.position = 'top'
c.tabs.width = '15%'                               # Reasonable width for titles
c.tabs.show = 'multiple'                           # Hide tab bar with single tab
c.tabs.last_close = 'close'                        # Close window when last tab closes
c.tabs.new_position.unrelated = 'next'             # Open new tabs next to current
c.tabs.favicons.show = 'always'                    # Show favicons in tabs
c.tabs.title.format = '{audio}{index}: {current_title}'  # Simple tab titles

# Content & Fonts
c.content.default_encoding = 'utf-8'
c.fonts.default_size = '11pt'
c.fonts.default_family = ['MesloLGS Nerd Font', 'DejaVu Sans']
c.fonts.completion.entry = '11pt MesloLGS Nerd Font'
c.fonts.tabs.selected = 'bold 11pt MesloLGS Nerd Font'
c.fonts.tabs.unselected = '11pt MesloLGS Nerd Font'
c.fonts.statusbar = '10pt MesloLGS Nerd Font'
c.fonts.hints = 'bold 12pt MesloLGS Nerd Font'

# Session Management
c.auto_save.session = True                         # Save session on quit
c.session.lazy_restore = True                      # Don't load tabs until selected

# Hints
c.hints.chars = 'asdfghjkl'                       # Home row keys for hints
c.hints.uppercase = True                          # Use uppercase hints for clarity

# Status Bar
c.statusbar.show = 'in-mode'                      # Only show in command/insert mode
c.statusbar.padding = {'top': 2, 'bottom': 2, 'left': 5, 'right': 5}

# Completion
c.completion.height = '40%'                       # Reasonable completion window size
c.completion.scrollbar.width = 10

# Search Engines
c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    'g': 'https://google.com/search?q={}',
    'gh': 'https://github.com/search?q={}',
    'w': 'https://en.wikipedia.org/wiki/{}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    'r': 'https://www.reddit.com/search?q={}',
}

# Start page
c.url.start_pages = ['about:blank']
c.url.default_page = 'about:blank'

# Privacy
c.content.cookies.accept = 'all'
c.content.javascript.enabled = True
c.content.webgl = True
c.content.notifications.enabled = False            # Block notification requests

# ============================================================================
# DUAL-MODAL KEYBINDINGS (VIM + ARROWS)
# ============================================================================
# Strategy:
#   - Keep qutebrowser defaults where they make sense
#   - Add arrow key alternatives for consistency
#   - Use Ctrl for tab operations (avoiding Alt+Shift/tmux conflicts)
#   - Maintain vim-style single-key operations in normal mode
#   - Numpad keys work as regular numbers (1-9) for tab selection

# ----------------------------------------------------------------------------
# TAB NAVIGATION - Enhanced with dual-modal support
# ----------------------------------------------------------------------------
# Default J/K for tab navigation (standard qutebrowser)
# Adding Ctrl+arrows for consistency
# NOTE: Numpad support is limited in qutebrowser - Qt cannot distinguish
#       numpad keys from regular number keys when NumLock is on

# Tab switching with arrows (Ctrl to avoid conflicts with scrolling)
config.bind('<Ctrl-Left>', 'tab-prev', mode='normal')
config.bind('<Ctrl-Right>', 'tab-next', mode='normal')

# Tab movement (reordering)
config.bind('<Ctrl-Shift-Left>', 'tab-move -', mode='normal')
config.bind('<Ctrl-Shift-Right>', 'tab-move +', mode='normal')

# ----------------------------------------------------------------------------
# PAGE NAVIGATION - Vim and arrow keys
# ----------------------------------------------------------------------------
# Defaults work: h/j/k/l and arrows for scrolling
# NOTE: Numpad keys (with NumLock on) will work as regular number keys
#       for direct tab access (1-9) but cannot be bound separately for scrolling

# ----------------------------------------------------------------------------
# HISTORY NAVIGATION - Browser-style alternatives
# ----------------------------------------------------------------------------
# Keep H/L defaults, add browser-standard Alt+arrows

config.bind('<Alt-Left>', 'back', mode='normal')
config.bind('<Alt-Right>', 'forward', mode='normal')

# ----------------------------------------------------------------------------
# TAB MANAGEMENT - Additional bindings
# ----------------------------------------------------------------------------
# Close tab - multiple options for muscle memory
config.bind('<Ctrl-w>', 'tab-close', mode='normal')        # Match super+w pattern
config.bind('x', 'tab-close', mode='normal')                # Quick single-key close

# Reopen closed tab
config.bind('u', 'undo', mode='normal')                     # Default
config.bind('<Ctrl-Shift-t>', 'undo', mode='normal')        # Browser standard

# Duplicate tab
config.bind('gC', 'tab-clone', mode='normal')               # Default

# Pin/unpin tab
config.bind('<Ctrl-p>', 'tab-pin', mode='normal')

# ----------------------------------------------------------------------------
# QUICK ACCESS - Bookmarks and quickmarks
# ----------------------------------------------------------------------------
# Keep defaults: m for quickmark, M for bookmark
# b/B to show them

# ----------------------------------------------------------------------------
# COMMAND MODE - Make it more discoverable
# ----------------------------------------------------------------------------
# : for command mode (default)
# Adding Ctrl+Shift+P for command palette style
config.bind('<Ctrl-Shift-p>', 'cmd-set-text :', mode='normal')

# ----------------------------------------------------------------------------
# INSERT MODE - Better escape options
# ----------------------------------------------------------------------------
# Multiple ways to exit insert mode
config.bind('<Ctrl-[>', 'mode-leave', mode='insert')       # Vim-style
config.bind('jk', 'mode-leave', mode='insert')              # Quick escape

# ----------------------------------------------------------------------------
# DOWNLOADS - Quick access
# ----------------------------------------------------------------------------
config.bind('gd', 'download', mode='normal')                # Go to downloads
config.bind('<Ctrl-Shift-j>', 'download', mode='normal')    # Browser standard

# ----------------------------------------------------------------------------
# PASSWORD MANAGER - Bitwarden integration
# ----------------------------------------------------------------------------
config.bind('<Alt-p>', 'spawn --userscript qute-bitwarden', mode='normal')
config.bind('<Alt-Shift-p>', 'spawn --userscript qute-bitwarden --totp', mode='normal')

# ----------------------------------------------------------------------------
# DEVELOPER TOOLS
# ----------------------------------------------------------------------------
config.bind('<F12>', 'devtools', mode='normal')             # Standard devtools key

# ----------------------------------------------------------------------------
# ZOOM CONTROLS - Multiple options
# ----------------------------------------------------------------------------
config.bind('<Ctrl-0>', 'zoom-reset', mode='normal')        # Reset zoom
config.bind('<Ctrl-=>', 'zoom-in', mode='normal')       # Zoom in
config.bind('<Ctrl-->', 'zoom-out', mode='normal')      # Zoom out
# NOTE: Numpad +/- work automatically as Ctrl-plus/Ctrl-minus when NumLock is on

# ============================================================================
# VISUAL FEEDBACK
# ============================================================================

# Messages
c.messages.timeout = 3000                           # Show messages for 3 seconds

# Scrollbar
c.scrolling.bar = 'when-searching'                  # Show scrollbar when searching

# ============================================================================
# ADVANCED FEATURES
# ============================================================================

# Smooth scrolling
c.scrolling.smooth = True

# Spell checking
c.spellcheck.languages = ['en-US']

# Editor (for text fields)
c.editor.command = ['alacritty', '-e', 'helix', '{file}', '+{line}']

print("Config loaded successfully!")