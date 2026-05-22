# Semantic Keybinding System

## Ultra-Zen Philosophy: Semantic Actions

**"Do not define keybindings; define intentions. Let the intention manifest as the appropriate key."**

Just as colors became semantic purposes, keybindings are semantic **intentions** that manifest contextually:

```yaml
# Instead of: MOD+H = move left
# We define: navigate.prev = context-appropriate leftward movement
```

## Architecture
- **Single Source of Truth**: All semantic actions defined in `home/.chezmoidata/keybindings.yaml`
- **Template System**: Format-specific templates in `home/.chezmoitemplates/keybind-*.tmpl` transform semantic definitions to app-specific syntax
- **Helix-Native**: Follow Helix's thoughtful semantic improvements as our foundation
- **Context Manifestation**: Same intention manifests appropriately per application
- **Vi Mode Selectively**: Helix editor, LF, and MPV use vi-style navigation. The terminal (Kitty) has no in-terminal vi-mode; its scrollback opens in Helix (Ctrl+Shift+H) instead. Zsh shell uses stock robbyrussell with emacs-mode bindings (no vi mode by design).

## Core Semantic Categories
- **Navigate**: Move focus without changing state (hjkl universally)
- **Manipulate**: Move/modify objects (MOD+CTRL+hjkl for windows)
- **Invoke**: Create/summon/launch (MOD+key for apps)
- **Transform**: Toggle states/modes (f for fullscreen, i/v/ESC for modes)
- **Preserve**: Save state (SPACE+W for write)
- **Dismiss**: Close/quit (q/Q universally)
- **Discover**: Search/help (/ for search, ? for help)

## Helix-Native Navigation
- `ge` instead of `G`: "Go end" is semantically clearer
- `gh/gl` for line start/end: "Go home/line" is intuitive
- `x` for extend: Direct selection without mode change
- `g` prefix groups all "go to" operations

## Benefits
- **Muscle Memory Unity**: Same semantic action = same key pattern everywhere
- **No Conflicts**: Semantic layer prevents accidental overlaps
- **Self-Documenting**: Intentions explain themselves
- **Extensibility**: New apps inherit semantic patterns automatically

## Template System

Format-specific templates in `home/.chezmoitemplates/` transform semantic keybinding definitions into application-specific syntax:

- **`keybind-lf.tmpl`**: Generates `map` commands for LF file manager
- **`keybind-qutebrowser.tmpl`**: Generates Python `config.bind()` statements
- **`keybind-mpv.tmpl`**: Generates aligned input.conf bindings with comment formatting
- **`keybind-preserve.tmpl`**: Save/write operations (w, Space+w)
- **`keybind-discover.tmpl`**: Search/help actions (/, ?, help)
- **`keybind-select.tmpl`**: Selection actions (toggle, extend, all)

Each template:
1. Accepts semantic parameters: `category`, `action`, `command`, optional `comment`
2. Looks up the appropriate key from `keybindings.yaml`
3. Outputs format-specific syntax with semantic comments

## Migrated Applications

The following applications now use semantic keybinding templates:

- **LF File Manager** (`lf/lfrc.tmpl`) - Semantic navigation and selection
  - 13 core bindings migrated (navigate, select, discover, transform)
  - Helix-native: h/j/k/l, gg/ge, gh/gl for directories
  - Search and selection with semantic templates
- **Qutebrowser** (`qutebrowser/config.py.tmpl`) - Browser with semantic navigation
  - 12 core bindings migrated (navigate, discover, dismiss)
  - Scroll navigation: h/j/k/l, gg/ge, gh/gl
  - Search: /, ?, dismiss: q/Q
- **MPV Media Player** (`mpv/input.conf.tmpl`) - Comprehensive semantic migration
  - 23 template-based bindings + 80 with semantic comments
  - Navigation (seek): h/l/j/k, gg/ge, gh/gl, w/b (chapters)
  - Manipulation (Ctrl): speed and volume with modifiers
  - Transform: f/i/v, Preserve: s, Discover: /?, Select: SPACE, Dismiss: q/ESC
  - All 100+ bindings categorized by semantic intent

## Vi-Mode Enabled Applications
- **Helix Editor** (`config.toml`) - Native modal editing
  - SPACE leader for commands
  - Full Helix semantic navigation
- **Kitty Terminal** (`kitty.conf.tmpl`, oreb) - No in-terminal vi-mode; scrollback opens in Helix (Ctrl+Shift+H) for full Helix-native navigation. The single binding is application-specific (like Zellij's copy key), not template-migrated.

## Zsh Shell (no vi mode)
The shell uses **robbyrussell** with stock emacs-mode bindings, by deliberate design.
Mode indicators (`[N]`/`[I]`/`[V]`) and Helix-native vi bindings are not preserved —
the universal trio of zsh extensions (autosuggestions, syntax-highlighting, completions)
provides the editing affordances. See `docs/ai-context/apps/zsh.md`.

## Documentation
- **User Reference**: See `docs/user-reference/KEYBINDINGS.md` for complete semantic mappings and quick reference cards
- **Definition**: `home/.chezmoidata/keybindings.yaml` contains all semantic action definitions
- **Audit**: See `keybinding-usage-audit.md` for comprehensive migration analysis