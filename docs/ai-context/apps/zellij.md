# Zellij Terminal Multiplexer

## Ultra-Zen Philosophy
**"Sessions persist by name; panes tile by intention; copied text flows to the clipboard."**

## Architecture
- **Session-per-project** — the `dev` zsh function runs `zellij attach --create <name>`, idempotently attaching to a session or creating it. Every session is named for its project.
- **Kanagawa Dragon theme** — defined inline in `config.kdl` from semantic colors in `colors.yaml`; no hardcoded hex. A palette change propagates on the next `chezmoi apply`.
- **Wayland clipboard** — `copy_command "wl-copy"` on machines with a GUI; OSC 52 fallback on headless/VPS, carrying copied text to the attached terminal's clipboard.
- **Scrollback → Helix** — Zellij's edit-scrollback opens `$EDITOR` (Helix), the same intent as Kitty's `Ctrl+Shift+H`, at no config cost.
- **Replaces tmux** — full migration; the tmux config, package entry, and docs were removed in the same change.

## Configuration Files
- **Main Config**: `home/dot_config/zellij/config.kdl.tmpl` → `~/.config/zellij/config.kdl`
- **Session launcher**: `home/dot_config/zsh/functions/dev` → `dev [name]` (autoloaded zsh function)
- **Package**: `home/.chezmoidata/packages.yaml` — `zellij` under `cachyos.pacman`; on Debian via cargo (`home/run_once_install-cli-tools-debian.sh.tmpl`)

## Usage
```bash
dev            # attach/create the "main" session
dev myproject  # attach/create a session named "myproject"
zellij ls      # list sessions
zellij         # bare launch
```

### Inside Zellij (default keybindings)
- **Modes**: `Ctrl-p` pane · `Ctrl-t` tab · `Ctrl-n` resize · `Ctrl-s` scroll/search · `Ctrl-o` session · `Ctrl-g` lock
- **Scroll mode** (`Ctrl-s`): `j/k`, `Ctrl-f/Ctrl-b`, `/` search, `e` edit scrollback in Helix
- **Copy**: selection copies on mouse release; in scroll mode, select and copy → clipboard
- **Detach**: `Ctrl-o d` — the session stays alive; reattach with `dev <name>`

## Clipboard Flow
### Desktop / laptop (`.has_gui`)
```
zellij copy → copy_command "wl-copy" → system clipboard
wl-paste                              → text appears
```

### Headless / VPS, or over SSH
No `copy_command` is set; Zellij emits OSC 52, which the attached terminal (Kitty on oreb) writes to the local clipboard. This mirrors tmux's former `set-clipboard on`.

## Theme — Kanagawa Dragon via semantic colors
The `themes { kanagawa-dragon { … } }` block maps Zellij's simple palette to semantic colors resolved through `color-quoted.tmpl` (Zellij wants quoted `"#rrggbb"`):

| Zellij slot | Source |
|---|---|
| `fg` | `text.primary` |
| `bg` | `surface.primary` |
| `black`…`white`, `orange` | the Dragon base palette |

`theme "kanagawa-dragon"` selects it. The simple (legacy) theme spec is used deliberately: it is version-portable, and Zellij derives the status bar, tab bar, and pane frames from the palette. The newer per-component theme spec is available if finer control is ever wanted.

## Multi-Machine Notes
- **Desktop / laptop** (CachyOS): `zellij` via pacman; full wl-copy clipboard.
- **VPS** (Debian): `zellij` via cargo (`run_once_install-cli-tools-debian.sh.tmpl`), since it is not reliably in apt; OSC 52 clipboard. **Note:** the cargo build is heavier than tmux's apt install.

## Design Decisions

### Why Zellij over tmux
Batteries-included: discoverable modal keybindings, built-in session management, layouts, and a status bar — no plugin manager. The `dev` launcher leans on `attach --create` for a friction-free session-per-project workflow.

### `dev` is a session launcher, not a keybinding
It is an autoloaded shell function, not a Zellij keybinding — it operates from the shell to *enter* the multiplexer. Sessions are named per project so `zellij ls` reads like a project list.

### Default keybindings kept
Zellij's modal keybindings are comprehensive and self-documenting (like Helix). Per the keybinding philosophy, only genuinely semantic core actions are templated; Zellij's modal model is left intact — the same call made for tmux's prefix.

### Simple theme spec
Chosen over the per-component spec for version portability and brevity. The palette is fully semantic-colored and the dark Kanagawa look is distinct (explicitly not gruvbox).

## Verification
```bash
# After `chezmoi apply` installs zellij:
zellij --version
dev test           # creates + attaches the "test" session
# press Ctrl-o d to detach
zellij ls          # shows "test"

# Clipboard: enter scroll mode (Ctrl-s), select a region, copy, then:
wl-paste           # → the copied text
```

---

*"The multiplexer holds the work between visits; name the session for the project, and return to find it as you left it."*
