# MPV Media Player with LF File Browser

## Ultra-Zen Philosophy
**"Each viewing journey begins with intention, pauses with memory, resumes with continuity"**

## Architecture
- **MPV Core** - Feature-rich media player with reliable position resuming
- **PipeWire Audio** - Explicitly configured for PipeWire with fallback to PulseAudio/ALSA
- **Auto-Save Script** - Periodic position saving (every 30s) ensures no loss on crashes/reboots
- **LF File Browser** - Integrated lf terminal browser for file selection (press 'b')
- **Kanagawa Theme** - Consistent theming across OSD, subtitles, and lf browser
- **Semantic Keybindings** - Comprehensive semantic keybinding system
  - 23 template-based bindings: navigation (seek, chapters), manipulation (Ctrl modifiers), transform (f/i/v), preserve (s), discover (/?), select (SPACE), dismiss (q/ESC)
  - 80+ bindings with semantic comments categorized by intent
  - Helix-inspired navigation: 0/$ for start/end, HOME/END for file start/end, w/b for chapters
  - All 100+ bindings organized by semantic categories
- **Fish Integration** - Semantic functions for media management (mp, mpb, mps, mpc)

## Configuration Files
- **Main Config**: `home/dot_config/mpv/mpv.conf.tmpl` - Core settings and theming
- **Keybindings**: `home/dot_config/mpv/input.conf.tmpl` - Helix-native navigation
- **Auto-Save Script**: `home/dot_config/mpv/scripts/auto-save-position.lua.tmpl` - Periodic position saving
- **LF Browser Script**: `home/dot_config/mpv/scripts/lf-browser.lua.tmpl` - LF integration script
- **LF Wrapper**: `home/dot_local/bin/executable_mpv.tmpl` - Terminal browser for pre-selection
- **Fish Functions**: `home/dot_config/fish/functions/mp*.fish.tmpl` - Semantic commands
- **Setup Script**: `home/run_once_install-mpv-scripts.sh.tmpl` - Directory setup script

## Usage
```bash
mp                # Launch with LF file browser
mp video.mp4      # Play specific file
mpb               # Force browse mode
mps               # Show watch history and saved positions
mpc               # Clear history and positions
mpsub <cmd>       # Subtitle management (find/organize/rename/check)

# Within MPV:
b                 # Open lf file browser with context-sensitive 'l' key
hjkl              # Navigate (vi-style: h=back 5s, l=forward 5s, j=back 1min, k=forward 1min)
0/$               # Jump to start/end of video (Helix-inspired)
HOME/END          # Jump to beginning/end of file
w/b               # Next/previous chapter
q                 # Quit and save position

# Subtitle controls:
v                 # Toggle subtitle visibility
s/S               # Cycle through available subtitles
z/x               # Adjust subtitle timing (-/+ 0.1s)
Alt+j/k           # Move subtitles up/down
Alt++/-           # Increase/decrease subtitle size
V                 # Toggle secondary subtitles (dual subs)
```

## Features
- **PipeWire Audio Integration** - Configured to use PipeWire directly (ao=pipewire,pulse,alsa) for modern audio stack compatibility
- **Reliable Position Resuming** - Auto-saves every 30s + on quit/seek (survives crashes/reboots)
- **Saved Positions** - Stored in `~/.local/state/mpv/watch_later/` as hash-named files
- **Smart Directories** - Starts in ~/Videos, falls back to ~/Downloads
- **LF Integration** - Press 'b' to browse files with lf, context-sensitive 'l' key
- **Screenshot Organization** - Saves to `~/Pictures/mpv/` with timestamps
- **Advanced Subtitle Support**:
  - Automatic detection in multiple directories (., subs/, .., ../subs)
  - Fuzzy matching (90% threshold) for misnamed subtitles
  - Dual subtitle display capability
  - Kanagawa-themed styling with readable borders
  - Comprehensive timing and positioning controls
  - `mpsub` tool for organizing and renaming subtitle files

## Navigation Philosophy
- **In Player**: Press `b` to launch lf browser in terminal
- **Pre-Selection**: Launch `mp` without args for lf browser
- **Context-Sensitive**: 'l' key enters directories or selects media files
- **Helix-Inspired**: `0/$` for video start/end, `HOME/END` for file jumps - semantic clarity adapted to MPV's single-key constraints
- **Semantic Functions**: `mp` (media-play), `mpb` (media-play-browse)