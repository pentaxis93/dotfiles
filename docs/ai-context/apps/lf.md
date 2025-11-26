# LF Terminal File Manager

## Architecture
- **Kanagawa Theme** - Consistent colors in borders and prompt from centralized palette
- **Semantic Keybindings** - Core bindings use semantic templates from keybindings.yaml
  - 13 template-based bindings: navigation (h/j/k/l, gg/ge, gh/gl), selection (x/V/A), search (/?)
  - Helix-native: ge for end, gh/gl for line start/end
  - All bindings categorized by semantic intent (navigate, select, discover, transform)
- **Required Dependencies** - fzf (Ctrl+f fuzzy directory jump), ripgrep (Ctrl+g content search), pandoc-cli (office document previews)
- **Handlr Integration** - Modern file handler replacing xdg-open with wofi selector

## Configuration Files
- `home/dot_config/lf/lfrc.tmpl` - Main configuration with keybindings
- `home/dot_config/lf/executable_preview.tmpl` - File preview script
- `home/dot_config/lf/executable_cleaner.tmpl` - Preview cleanup script
- `home/dot_config/lf/icons.tmpl` - File type icons mapping
- `home/dot_config/fish/functions/lfcd.fish.tmpl` - Directory change function
- `home/dot_config/handlr/handlr.toml.tmpl` - Handlr config with wofi selector
- `home/run_once_setup-handlr-defaults.sh.tmpl` - Handlr default associations setup

## Simplified File Actions
Two-key system for maximum simplicity:
- `l` - Open with default app (instant)
- `L` - Choose app from available handlers (wofi menu)
- `ee` - Quick edit in Helix
- Preview pane handles viewing automatically

## Rich File Previews
- Text files with syntax highlighting (bat)
- Images as ASCII art or sixels (chafa)
- Videos with thumbnails and metadata (mediainfo/ffmpeg)
- Archives showing contents (atool)
- PDFs as text or images (poppler)
- JSON pretty-printed (jq)
- **Office documents** - DOCX, EPUB, ODT converted to plain text (pandoc)
- Directories as tree structure

## Advanced Commands
- **FZF integration** - Ctrl+f for fuzzy directory finding
- **Bulk rename** - B key with $EDITOR
- **Archive operations** - Create/extract archives
- **Trash integration** - T key with trash-cli
- **Clipboard operations** - W for Wayland clipboard
- **Ripgrep file search** - Ctrl+g for content search

## Fish Integration
- `lfcd` function for directory changing on exit
- Ctrl+O keybinding for quick access
- `lc` abbreviation for lfcd

## Features
- **Icons** - Comprehensive Nerd Font icons for all file types
- **Quick Jumps** - Bookmarks to common directories (gc for ~/.config, gv for ~/Videos, etc.)
- **MPV Integration** - Used as video file selector when 'b' is pressed
- **Git Operations** - Branch switching, log viewing, status checking