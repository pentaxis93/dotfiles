# Color Template System

## Ultra-Zen Philosophy: Semantic Terminal Colors & Reverse Video

**"Do not define colors; define intentions. Let the intention manifest as color."**

## Architecture
- **Single Source of Truth**: All Kanagawa Dragon colors defined in `home/.chezmoidata/colors.yaml`
- **Format Converters**: Template fragments handle format conversions for different config syntaxes
- **Templated Configs**: Waybar CSS, Alacritty TOML, and Niri KDL use centralized colors
- **Ultra-Zen Terminal Colors**: Terminal colors (0-15) map to actual theme colors, not traditional ANSI

## Usage Pattern
```go-template
{{- $c := .kanagawa.dragon -}}
color: {{ template "color-hex.tmpl" $c.green }}     # CSS: #8a9a7b
color = {{ template "color-quoted.tmpl" $c.red }}   # TOML: "#c4746e"
```

## Semantic Terminal Colors

Terminal colors are semantic purposes, not hues:
- `color0` (background) = `#181616` - Our actual background, not darkest black
- `color7` (foreground) = `#c5c9c5` - Our actual foreground, not brightest white
- `color8` (inactive) = `#625e5a` - Comments/disabled, not just "bright black"
- `color14` (focus) = `#8a9a7b` - Focus/active indicator (our green), NOT selection bg
- `color11` (warning_bright) = `#c4b28a` - Actual yellow for warnings/emphasis

## The Master's Wisdom on Selection

*"Do not paint the water to make the fish visible. Let the fish and water exchange places."*

Selections use **reverse video**, not colored backgrounds. This ensures:
- Perfect contrast always (fg/bg swap)
- No configuration complexity
- Universal solution for all TUI apps

## Terminal Color Purpose Mapping

Each terminal color slot has a PURPOSE:
- **0-7**: Primary semantic roles (background, error, success, warning, etc.)
- **8-15**: Enhanced semantic roles (inactive, urgent, focus, emphasis, etc.)
- Apps express themselves through intentions, not raw colors

## Benefits
- **Perfect Unity**: nmtui background = Waybar background = Alacritty background (#181616)
- **Perfect Contrast**: Lazygit selections use reverse video - always readable
- **Semantic Consistency**: color14 is focus/active (green), not selection background
- **Maintainability**: Change theme by updating single file
- **Extensibility**: Easy to add new apps with consistent theming
- **Semantic Truth**: Colors represent intentions, not traditional ANSI meanings

## Template Fragments
Located in `home/.chezmoitemplates/`:
- `color-hex.tmpl` - Convert color to #hex format (CSS/KDL)
- `color-quoted.tmpl` - Convert color to "#hex" format (TOML)
- `color-rgb.tmpl` - Convert hex to rgb() format
- `color-rgba.tmpl` - Convert hex to rgba() with alpha
- `color-index.tmpl` - Map color names to terminal indices
- `newt-colors-dynamic.tmpl` - Dynamic NEWT_COLORS from colors.yaml

## Color-Templated Applications
- **Waybar** (`style.css.tmpl`) - Full spectrum color usage for module theming
- **Alacritty** (`alacritty.toml.tmpl`) - Terminal base colors (0-15 + extended)
- **Niri** (`config.kdl.tmpl`) - Focus ring and selection colors
- **nmtui** (via `dot_zshrc.tmpl`) - NEWT UI components with semantic mappings