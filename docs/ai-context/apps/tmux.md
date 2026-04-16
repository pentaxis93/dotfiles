# Tmux Terminal Multiplexer

## Ultra-Zen Philosophy
**"Text in a pane flows to the clipboard through vi selection and OSC 52"**

## Architecture
- **Vi Copy-Mode** — `setw -g mode-keys vi` with Helix-native `ge`/`gh`/`gl`/`gg` via a custom `copy-mode-vi-g` key-table
- **Wayland Clipboard** — `y`, `Enter`, and mouse drag-release all pipe to `wl-copy` via `copy-pipe-and-cancel`
- **OSC 52 Passthrough** — `set-clipboard on` lets tmux running inside SSH (e.g. on `babbie`) write to the local terminal's clipboard
- **Capability-Aware** — `.has_gui` gates the wl-copy pipeline; headless machines fall back to OSC 52 + tmux buffer only
- **Kanagawa Dragon Theme** — status bar, window list, borders, copy-mode indicator, and message line all resolved through semantic colors in `colors.yaml`

## Configuration Files
- **Main Config**: `home/dot_config/tmux/tmux.conf.tmpl` → `~/.config/tmux/tmux.conf`
- **Package**: `home/.chezmoidata/packages.yaml` under `cachyos.pacman` and `debian.apt`

## Usage
```bash
tmux new -s work       # New named session
tmux attach -t work    # Re-attach
tmux ls                # List sessions
```

### Inside tmux
- **Prefix**: `Ctrl-b` (unchanged)
- **Copy-mode**: `prefix + [`
- **Selection**: `v` (char), `V` (line), `Ctrl-v` (rectangle)
- **Copy + exit**: `y` or `Enter` → goes to Wayland clipboard, copy-mode closes
- **Mouse**: drag to select, release to copy (no keys needed)
- **Dismiss**: `q` or `Escape`

### Copy-mode navigation (Helix-native)
| Key | Action |
|---|---|
| `h/j/k/l` | character movement |
| `w/b/e` | word movement |
| `gg` | top of scrollback |
| `ge` | bottom of scrollback (Helix-native, replaces `G`) |
| `gh` | line start |
| `gl` | line end |
| `G` | top-of-scrollback (vim fallback, kept for muscle memory) |
| `/` `?` `n` `N` | search |

## Clipboard Flow

### On `oreb` / `mani` (Wayland desktop/laptop)
```
tmux copy-mode → y → copy-pipe-and-cancel "wl-copy" → system clipboard
wl-paste                                             → text appears
```

### Inside tmux inside SSH to `babbie`
```
tmux on babbie → OSC 52 escape → SSH tunnel → Alacritty on oreb → wl-copy
```
No config on babbie beyond `set-clipboard on` — Alacritty honors OSC 52 writes natively.

## Multi-Machine Notes
- **Desktop / laptop**: full wl-copy pipeline (`.has_gui = true`)
- **VPS (babbie)**: `y` and drag-release fall back to `copy-pipe-and-cancel` with no external command. OSC 52 carries the text back to the attached terminal's clipboard when possible
- tmux is declared under both `cachyos.pacman` and `debian.apt` in `packages.yaml`

## Semantic Color Mapping
| Element | Semantic Token |
|---|---|
| Status bar background | `surface.primary` |
| Status bar text | `text.primary` |
| Session-name badge | `mode.normal` (green) on `text.inverted` |
| Active window | `mode.normal` (green) on `text.inverted` |
| Inactive window | `text.secondary` on `surface.primary` |
| Pane border (idle) | `border.subtle` |
| Pane border (active) | `border.focus` |
| Copy-mode / selection | `mode.visual` (yellow) on `text.inverted` |
| Message line | `state.info` on `surface.elevated` |

All resolved at template-time through `home/.chezmoitemplates/color-hex.tmpl`. No hex codes appear in the config file itself.

## Design Decisions

### No plugin manager
Tmux's native features cover every clipboard and selection need that `tmux-yank` or TPM would provide — at the cost of ~8 lines total. A plugin manager introduces a lifecycle this repo doesn't want.

### `y` is hardcoded
`keybindings.yaml` has no `copy`/`yank` semantic category. `y` is a universal vim/Helix convention; per CLAUDE.md this qualifies as an application-specific non-semantic binding. If a `yank` category is added later, this binding migrates then.

### Prefix stays `Ctrl-b`
Reassigning the prefix is a personal-habit decision and out of scope for clipboard integration.

### XDG path, not `~/.tmux.conf`
Tmux 3.x auto-loads `~/.config/tmux/tmux.conf`. Matches every other config in this repo.

## Verification
```bash
# Reload without leaving the session
tmux source ~/.config/tmux/tmux.conf

# Local clipboard
tmux new -s test
echo "hello from tmux"
# prefix [ , navigate to the line, v, select, y
wl-paste   # → "hello from tmux"

# Confirm bindings
tmux list-keys -T copy-mode-vi | grep -E '(^bind.*y |MouseDragEnd)'
tmux show -g set-clipboard
```
