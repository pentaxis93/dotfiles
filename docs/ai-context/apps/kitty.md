# Kitty Terminal Emulator

## Ultra-Zen Philosophy
**"The terminal advertises its true nature; scrollback flows into the editor, and distance dissolves through honest terminfo."**

## Architecture
- **GPU-Accelerated Terminal** — Kitty, replacing Alacritty on oreb
- **Semantic Colors** — Kanagawa Dragon sourced from `colors.yaml` via the
  `color-hex.tmpl` fragment; zero hardcoded hex in the config
- **Reverse-Video Selection** — `selection_*  none` swaps fg/bg per cell
  (the repo's selection philosophy, expressed natively)
- **Scrollback → Helix** — a single binding opens the window's scrollback in
  Helix for selection and copy
- **Honest Remote Terminfo** — `kitten ssh` transmits the `xterm-kitty`
  terminfo to remote hosts; TERM is never forced to a generic value
- **Host-Scoped** — deployed to oreb only, gated on `.chezmoi.hostname`

## Configuration Files
- **Main Config**: `home/dot_config/kitty/kitty.conf.tmpl` → `~/.config/kitty/kitty.conf`
- **Scrollback Helper**: `home/dot_local/bin/executable_kitty-scrollback-helix` → `~/.local/bin/kitty-scrollback-helix`
- **SSH Aliases**: `home/dot_config/zsh/aliases.zsh.tmpl` (`babbie`, `weforge` → `kitten ssh`)
- **Host Gate**: `home/.chezmoiignore` (excludes `.config/kitty` off oreb)
- **Package**: `home/.chezmoidata/packages.yaml` — `kitty` under `cachyos.pacman`

## Semantic Color Integration
The config mirrors the integration pattern used by Zellij and the former
Alacritty config. The header binds the palette and semantic layer:

```go-template
{{- $theme := .themes.kanagawa.dragon -}}
{{- $s := .semantic -}}
```

Each color is then a semantic lookup rendered through `color-hex.tmpl` (Kitty
wants `#rrggbb`, unquoted — exactly what the fragment emits):

```
background  {{ template "color-hex.tmpl" (index $theme $s.surface.primary) }}
```

A theme change made solely in `colors.yaml` propagates to Kitty on the next
`chezmoi apply` with no edit to `kitty.conf.tmpl`. The 16-color palette maps to
the semantic terminal slots (`color0` = background, `color14` = focus, …); tabs
and borders draw from `mode`, `border`, and `state` categories so Kitty's chrome
matches Zellij.

### Selection — Reverse Video
Both `selection_foreground` and `selection_background` are set to `none`,
producing a true per-cell fg/bg swap. This honors *"do not paint the water to
make the fish visible; let the fish and water exchange places"* and needs no
theme data — a palette change still appears correctly because the swapped colors
*are* the themed foreground/background.

### Mouse Selection → Clipboard
`copy_on_select clipboard` carries forward Alacritty's `save_to_clipboard`:
selecting text with the mouse places it on the system clipboard, retrievable
with a normal paste (not only middle-click primary selection). This coexists
with the scrollback→Helix binding — both selection paths remain available.

## Scrollback in Helix
```
map kitty_mod+h launch --type=overlay --stdin-source=@screen_scrollback ~/.local/bin/kitty-scrollback-helix
```

`Ctrl+Shift+H` pipes the window's full scrollback to the helper, which spools it
to a temp file (Helix cannot read stdin as a buffer) and opens it in Helix.
Inside Helix the buffer is navigable with full Helix semantics, selectable, and
yankable to the Wayland clipboard.

**Scrollback division — important.** This binding captures **Kitty's own**
scrollback buffer and is meant for **bare-terminal** use (including outside any
multiplexer). Inside Zellij, the multiplexer owns the scrollback; use
*its* scrollback/copy-mode tool there. Kitty's binding does not replace it, and
inside a multiplexer would only see the mux's redraw region.

### Why a binding, not `keybind-kitty.tmpl`
Kitty has no terminal vi-mode, so the Alacritty vi-mode/search/clear-selection
keybindings do not translate — Helix *becomes* the scrollback interface, and the
whole `keybind-alacritty.tmpl` apparatus collapses into this one mapping.
"Open scrollback in editor" has no semantic category in `keybindings.yaml`, so —
exactly like Zellij's hardcoded copy key — it is an application-specific binding,
hardcoded with this justification rather than templated.

## Remote Terminfo via `kitten ssh`
Kitty advertises `TERM=xterm-kitty`. Remote hosts that lack that terminfo entry
render full-screen TUIs (Zellij, the Codex CLI) with overdrawn or leftover
characters. The fix is to make `xterm-kitty` **resolve** on the remote, not to
mask it by forcing a generic TERM.

`kitten ssh` does this: on connect it transmits the `xterm-kitty` terminfo
(bundled with the kitten — no local terminfo package required) into the remote
user's `~/.terminfo`, then launches the login shell. It is a drop-in for `ssh`
and honors `~/.ssh/config` (HostName, User, IdentityFile, ForwardAgent). The
`babbie` and `weforge` aliases route through it on oreb:

```sh
alias babbie='kitten ssh babbie'
alias weforge='kitten ssh weforge'
```

### Multiplexer caveat
When launched from inside a multiplexer (Zellij), the escape handshake
`kitten ssh` uses to transmit terminfo can be intercepted. Zellij has no
tmux-style passthrough toggle, so the reliable path is to run `kitten ssh`
from a **plain Kitty window** (outside Zellij).

### Manual fallback
If a remote ever still lacks the entry (and provisioning that host is out of
scope — handled in the tesserine/ops repo), a one-time, multiplexer-independent
copy works:
```sh
infocmp -a xterm-kitty | ssh babbie  tic -x -o ~/.terminfo /dev/stdin
infocmp -a xterm-kitty | ssh weforge tic -x -o ~/.terminfo /dev/stdin
```
Restart any existing Zellij session on the remote afterward so it picks up
the new terminfo.

## Bell
`enable_audio_bell yes` uses Kitty's built-in audio bell, which plays through
the audio server and does not depend on an external sound file. If it is silent
on oreb's PipeWire stack, add to `kitty.conf.tmpl`:
```
command_on_bell paplay /usr/share/sounds/freedesktop/stereo/complete.oga
```
(that file is present on oreb). *Audible* is the requirement — confirm by ear
with `printf '\a'` in a Kitty window.

## Machine Scope
- **oreb (laptop)**: full Kitty stack — config, scrollback helper, kitten-ssh
  aliases. This is the repo's first hostname-gated config (`.chezmoiignore`:
  `{{ "{{ if ne .chezmoi.hostname \"oreb\" }}" }}`), honoring the oreb-only scope.
- **mani (desktop)**: the `kitty` package installs (package management is
  per-OS, not per-host), but no Kitty config is deployed — vanilla Kitty.
- **babbie (VPS)**: excluded; no GUI terminal needed.

## Usage
```bash
kitty                       # Launch (from niri: MOD+RETURN)
Ctrl+Shift+H                # Open this window's scrollback in Helix
# mouse-select              # Text copied to system clipboard
kitten ssh babbie           # SSH with xterm-kitty terminfo transmitted
```

## Relationship to the Former Alacritty Config
Only the **color-integration pattern** was carried over from Alacritty. The
Alacritty-specific machinery — the `[env] TERM = "xterm-256color"` workaround
(which masked the terminfo gap), the vi-mode blocks, the `keybind-alacritty.tmpl`
calls — was intentionally not reproduced. The Alacritty config, its dedicated
keybinding fragment, and its `.chezmoiignore` entry were removed in the same
change.

---

*"A terminal that lies about its name forces every distant host to guess. Kitty speaks its true name, and `kitten ssh` teaches the far shore to understand it."*
