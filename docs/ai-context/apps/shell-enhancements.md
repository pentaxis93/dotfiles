# Shell Enhancements

## lsd - Modern ls Replacement

### Architecture
- **Transparent Integration**: `ls` command transparently replaced with lsd
- **Enhanced Features**: Icons, colors, tree view support
- **Zero Learning Curve**: All standard ls options pass through unchanged
- **Implementation**: Zsh autoload function at `home/dot_config/zsh/functions/ls`

### Benefits
- Nerd Font icons for file types
- Automatic directory grouping
- Tree view (`--tree`) for hierarchical display
- Better color coding and formatting

## zoxide - Smart Directory Navigation

### Architecture
- **Frecency-Based Jumping**: Learn frequently and recently used directories
- **Commands**:
  - `z <keyword>` - Jump to best match for keyword
  - `zi <keyword>` - Interactive selection with fzf
- **Integration**: Initialized in zsh config, works alongside lfcd
- **Configuration**: Auto-initialized in `home/dot_zshrc.tmpl`

### Philosophy
Complements visual navigation (lfcd/Ctrl+O) with quick frecency-based jumps

### Use Cases
- **Quick jumps**: `z dots` → `~/.local/share/chezmoi`
- **Partial matches**: `z conf` → `~/.config` (learns your patterns)
- **Recent directories**: Just visited ~/Videos/movies? `z mov` gets you back
