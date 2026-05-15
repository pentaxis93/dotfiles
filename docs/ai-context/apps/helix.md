# Helix Modal Editor

## Ultra-Zen Philosophy
**"The editor is the interface; intention becomes action through semantic navigation"**

## Architecture
- **Semantic Color System** - Fully integrated with centralized color palette
- **Kanagawa Dragon Theme** - Complete UI theming from `colors.yaml` via templates
- **Helix-Native Keybindings** - Preserves excellent defaults (ge, gh/gl, etc.)
- **LSP Integration** - Advanced language server support with inlay hints
- **Soft Line Wrapping** - Enhanced readability for long lines with visual indicators
- **Zsh Integration** - `h` alias for quick editor invocation

## Configuration Files
- **Main Config**: `home/dot_config/helix/config.toml.tmpl` - Editor settings and keybindings
- **Languages**: `home/dot_config/helix/languages.toml.tmpl` - File-type specific settings
- **Theme**: `home/dot_config/helix/themes/kanagawa-dragon.toml.tmpl` - Semantic color theme
- **Zsh Integration**: `h` alias in `aliases.zsh.tmpl`
- **Package**: `home/.chezmoidata/packages.yaml` - Declaratively managed

## Key Features

### Semantic Color Integration
- **Single Source of Truth** - All colors from `colors.yaml`
- **Template-Based** - Theme auto-updates with palette changes
- **Semantic Mappings**:
  - UI backgrounds → surface category
  - Diagnostics → state category (error, warning, info)
  - Selections → selection category
  - Mode indicators → mode category (normal=green, insert=blue, visual=yellow)

### Soft Line Wrapping
```toml
[editor.soft-wrap]
enable = true
max-wrap = 25           # Indent wrapped lines for clarity
wrap-indicator = "↪ "   # Visual indicator for wrapped lines
```

### Enhanced LSP
- Display messages and inlay hints
- Snippet support enabled
- Auto-signature help
- Smart case search with wrap-around

### File-Type Specific Settings
- **Markdown**: Soft wrap enabled, 100-char ruler
- **Python**: 4-space indent, rulers at 88 (Black) and 120
- **Rust**: 100-char ruler
- **Go**: Tab indentation, 100-char ruler
- **TOML/YAML/JSON**: 2-space indentation

## Usage
```bash
h                # Launch Helix (semantic: invoke.editor)
helix file.txt   # Edit specific file
```

## Helix-Native Navigation
We preserve Helix's thoughtful default keybindings:
- `ge` - Go to end (semantic clarity over vim's G)
- `gh/gl` - Go to line start/end
- `gg` - Go to file start
- `w/b/e` - Word navigation
- `f/t` - Find/till character
- `m` - Match mode (surround operations)
- `z` - View mode (center, top, bottom)

## Custom Keybindings (Minimal)
Only 3 custom bindings, preserving Helix defaults:
- `space.w` - Write current file (preserve.current)
- `space.q` - Quit current file (dismiss.current)
- `X` - Extend line above

## Benefits
- **Architectural Compliance** - Follows semantic color system
- **Maintainability** - Theme changes require only `colors.yaml` update
- **Helix-Native** - Respects editor's excellent design philosophy
- **Enhanced Readability** - Soft wrap for long lines
- **LSP-Powered** - Modern language features out of the box
- **YAGNI-Focused** - Each setting justified by actual use
