# Dotfiles Developer Reference

## Essential Context
- **Working Directory**: `~/.config/dotfiles/`
- **Repository**: Bare git repo at `~/.dotfiles/` with work-tree in `$HOME`
- **Critical**: `dots` is a Fish function. Claude Code MUST use full git commands:

| Context | Command |
|---------|----------|
| Fish shell | `dots status` |
| Claude Code | `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME status` |

**Remember**: Always use absolute paths (`~/path/to/file`), never relative.

## System Stack
- **OS**: CachyOS Linux (Arch-based)
- **Window Manager**: BSPWM + SXHKD
- **Shell**: Fish (with vi mode)
- **Terminal**: Alacritty
- **Editor**: Helix
- **Bar**: Polybar

## Bootstrap System

### Adding Dependencies
```bash
# Add package to list
echo "package-name" >> ~/.config/dotfiles/bootstrap/packages-tools.txt
# Test installation
~/.local/bin/bootstrap.sh --dry-run
```

### Key Scripts
| Script | Purpose |
|--------|----------|
| `~/.local/bin/bootstrap.sh` | Package installer |
| `~/.local/bin/setup-system.sh` | System configuration |
| `~/.config/dotfiles/bootstrap/packages-*.txt` | Package lists |



## API Key Management (Pass)

**Critical**: MCP servers need API keys. Pass handles this via GPG encryption.

### Setup
```bash
# Initialize pass with GPG key
pass init <gpg-id>
# Add API key
pass insert api/openrouter
```

### MCP Wrapper Pattern
```bash
#!/usr/bin/env bash
OPENROUTER_API_KEY=$(pass show api/openrouter 2>/dev/null | head -n1)
export OPENROUTER_API_KEY
exec uvx --from git+...zen-mcp-server.git zen-mcp-server "$@"
```

### Organization
```
~/.password-store/
├── api/          # API keys (openrouter, github, anthropic)
├── tokens/       # Auth tokens
└── services/     # Service credentials
```

**GPG Cache**: 8-24 hours (configured in `~/.gnupg/gpg-agent.conf`)


## Git Commands Reference

**Critical**: Bare repo at `~/.dotfiles/`, work tree at `$HOME`, `showUntrackedFiles = no`

| Operation | Claude Code Command |
|-----------|--------------------|
| Status | `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME status` |
| Add | `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME add ~/path/file` |
| Commit | `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME commit -m "msg"` |
| Push | `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME push` |
| Diff | `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME diff` |

**Gotchas**:
- Always use absolute paths (`~/...` not `./...`)
- `dots` command doesn't work in Claude Code (Fish function)
- Untracked files hidden by default (use `-u` to see them)


## Key Files

| Category | Path |
|----------|------|
| WM Config | `~/.config/bspwm/bspwmrc` |
| Hotkeys | `~/.config/sxhkd/sxhkdrc` |
| Shell | `~/.config/fish/config.fish` |
| Terminal | `~/.config/alacritty/alacritty.toml` |
| Bar | `~/.config/polybar/config.ini` |
| Editor | `~/.config/helix/config.toml` |
| Media Player | `~/.config/mpv/mpv.conf` |
| MPV Hotkeys | `~/.config/mpv/input.conf` |
| Claude | `~/.claude/settings.json` |


## MPV Configuration

**Key Features**: Series watching optimized with file browser script
- Resume playback from any position
- Watch history tracking (`.local/state/mpv/watch_history.jsonl`)
- Built-in file browser starting in `~/Videos` folder

### File Browser Script
| Key | Action |
|-----|--------|
| `MENU` or `b` | Open file browser interface |
| `h/j/k/l` | Navigate (vim-style: left/down/up/right) |
| Arrow keys | Navigate directories (alternative) |
| `g` / `G` | Go to top / bottom of list |
| `u` | Go up directory (vim-style) |
| `r` | Reload current directory |
| `Enter` | Select file/enter directory |
| `ESC` | Close browser |

**Features**:
- Gruvbox color scheme matching system theme
- Tri-modal navigation (vim/arrows/numpad consistency)
- Mnemonic `b` key for "browse" (no conflicts)

**Installation**: Handled by bootstrap setup script (`02-mpv-scripts.sh`)
**Source**: [mpv-file-browser](https://github.com/CogentRedTester/mpv-file-browser)

## Polybar Window Titles

**Key**: `window-title-daemon.sh` monitors via `bspc subscribe` + `xprop -spy`
- Filters redundant app names ("tmux - tmux" → "project")
- Requires tmux: `set -g set-titles on`



## Gruvbox Colors

| Role | Color | Hex |
|------|-------|-----|
| Background | dark | `#1d2021` |
| Foreground | cream | `#ebdbb2` |
| Primary Accent | bright aqua | `#8ec07c` |
| Secondary | regular aqua | `#689d6a` |
| Error | red | `#fb4934` |
| Warning | yellow | `#fabd2f` |
| Success | green | `#b8bb26` |



## Development Workflow

### Test-and-Commit Pattern
1. Make atomic change
2. Test immediately
3. Commit if working
4. Document in-file (not external docs)

### Bootstrap Over Manual
- New system tools → Add to bootstrap scripts
- Don't document manual steps → Automate them
- Critical for: systemd, sudoers, polkit

### Commit Messages
- Focus on what/why, not who
- Skip attribution footers (git tracks authorship)
- Clean, descriptive messages

## System Notes

| Component | Value |
|-----------|---------|
| Package Manager | `pacman` + `yay` (AUR) |
| Init | systemd |
| Graphics | Intel Tiger Lake-LP |
| Backlight | `/sys/class/backlight/intel_backlight/` |

## Claude Code Configuration

### Setup
- Installed via bootstrap (NPM)
- Binary: `~/.local/bin/claude`
- Config: `~/.claude/settings.json` (tracked)

### Security Zones
| Zone | Permissions |
|------|-------------|
| Green | Read-only (ls, cat, git status) |
| Yellow | User modifications (git commit, npm, pkill) |
| Red | System changes (always prompts) |

### Key Environment Variables
```json
{
  "EDITOR": "helix",
  "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1",
  "USE_BUILTIN_RIPGREP": "1"
}
```

### Philosophy
"Configs just work" - track files where apps expect them, no templates/copying.

## MCP Servers

### Context7 (Library Documentation)
**Use**: Get up-to-date docs/examples for any library
```bash
# Workflow: resolve library ID → get docs
mcp__context7__resolve-library-id <library-name>
mcp__context7__get-library-docs <context7-id>
```

### Zen (Advanced Analysis)
**Use**: Complex analysis, planning, debugging, reviews

| Tool | When to Use |
|------|-------------|
| `chat` | Brainstorming, collaboration, second opinions |
| `thinkdeep` | Complex bugs, architecture decisions |
| `planner` | Breaking down complex tasks |
| `consensus` | Multi-model decision making |
| `codereview` | Systematic code quality analysis |
| `precommit` | Git change validation |
| `debug` | Root cause analysis |
| `secaudit` | Security vulnerability assessment |
| `analyze` | Architecture/performance analysis |
| `refactor` | Code improvement opportunities |
| `tracer` | Execution flow/dependency mapping |
| `testgen` | Comprehensive test suite creation |

**Pattern**: Use zen tools for deep analysis, context7 for quick library reference.

## Quick Fixes

| Problem | Solution |
|---------|----------|
| `dots` not found | Use full git command (Fish function) |
| SXHKD keybindings | `pkill -USR1 -x sxhkd` to reload |
| Brightness keys | Run sudoers setup in bootstrap |
| Polybar not hiding | Check `polybar-autohide.sh` daemon |
| Colors wrong | Verify `$TERM` and font installation |

**Note**: This file should be updated when adding new tools or changing workflows.