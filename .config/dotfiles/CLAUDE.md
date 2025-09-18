# Dotfiles Management Context

**Working Directory**: `~/.config/dotfiles/`
**Launch Command**: Use `dotclaude` to start a dotfiles management session
**Repository Type**: Bare git repo with work-tree in `$HOME`

## Important Notes
- Always use absolute paths when adding files: `dots add ~/path/to/file`
- This CLAUDE.md only loads when working from the dotfiles workspace
- Use `dotclaude` instead of `claude code` for dotfiles work

---

# System Configuration Context

When Claude Code is invoked in this directory (`~/.config/dotfiles`), we are working on **system configuration and dotfiles management**.

## 🔧 Automated Bootstrap System

### Quick Setup for New Systems
The dotfiles now include a comprehensive bootstrap system that automates all installation and configuration:

```bash
# After cloning dotfiles, run:
~/.local/bin/bootstrap.sh --setup    # Full installation
~/.local/bin/bootstrap.sh --minimal  # Core packages only
~/.local/bin/bootstrap.sh --dry-run  # Preview what would be installed
```

### Bootstrap System Components

1. **`~/.local/bin/bootstrap.sh`** - Main installer script
   - Installs packages from official repos and AUR
   - Creates default package lists if missing
   - Handles batch installation with fallback to individual packages
   - Provides dry-run mode for previewing changes

2. **`~/.local/bin/setup-system.sh`** - Post-installation configuration
   - Configures brightness control (ThinkPad)
   - Sets up GTK themes and icons
   - Configures Fish as default shell
   - Enables systemd services
   - Fixes file permissions

3. **`~/.config/dotfiles/bootstrap/`** - Package list directory (minimalist)
   - `packages-core.txt` - Essential packages (WM, terminal, shell, polybar utilities)
   - `packages-tools.txt` - CLI enhancements (only tools we actually use)
   - `packages-aur.txt` - AUR packages (fonts for terminal/polybar, themes)
   - `DEPENDENCIES.md` - Comprehensive documentation of all packages

**Note**: This is a minimalist setup. No development packages, no wishlist items, only what's actually used in the dotfiles.

### Managing Dependencies

#### Adding New Dependencies
When you install a new tool that should be part of the dotfiles:

```bash
# Add to appropriate package list
echo "package-name" >> ~/.config/dotfiles/bootstrap/packages-tools.txt

# Document why it's needed
vi ~/.config/dotfiles/bootstrap/DEPENDENCIES.md

# Test that it installs correctly
~/.local/bin/bootstrap.sh --dry-run
```

#### Checking Current Dependencies
```bash
# View all package lists
ls ~/.config/dotfiles/bootstrap/packages-*.txt

# Check which packages are installed
for pkg in $(cat ~/.config/dotfiles/bootstrap/packages-core.txt | grep -v '^#'); do
    pacman -Q $pkg 2>/dev/null && echo "✓ $pkg" || echo "✗ $pkg"
done
```

### Manual Setup Steps (If Not Using Bootstrap)

#### Enable Brightness Control (Required for ThinkPad Function Keys)
Run this command to enable passwordless brightness control:
```bash
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/backlight/intel_backlight/brightness" | sudo tee /etc/sudoers.d/brightness
```

This creates a secure sudoers rule that allows brightness control without password prompts. Without this, the brightness keys (Fn+F7/F8) will not work or will prompt for passwords.

## System Overview

- **OS**: CachyOS Linux (Arch-based distribution)
- **Kernel**: Linux 6.16.7-2-cachyos
- **Window Manager**: BSPWM (Binary Space Partitioning Window Manager)
- **Hotkey Daemon**: SXHKD
- **Audio Server**: PipeWire 1.4.8 (with PulseAudio compatibility)
- **Hardware**: ThinkPad (Model: 20W4002HUS)
- **Shell**: Fish (default)
- **Terminal**: Alacritty
- **Editor**: Helix

## Tri-Modal Navigation Philosophy

### Standardized Directional Controls
All applications in this system support **three forms of directional input** wherever possible:
1. **Vim keys** (h/j/k/l) - For keyboard enthusiasts
2. **Arrow keys** - Universal standard
3. **Numpad keys** (2/4/6/8) - For numpad users

This consistency reduces cognitive load when switching between applications.

### Implementation Status

#### ✅ Full Tri-Modal Support
- **BSPWM/SXHKD**: Window navigation with Super modifier
  - `Super + {h,j,k,l}` / `Super + arrows` / `Super + numpad`
- **Tmux**: Tab navigation with Alt+Shift modifier (tab-only mode, no panes)
  - `Alt+Shift + {h,l}` / `Alt+Shift + arrows` / `Alt+Shift + numpad`
  - Alternative vim keys: `Alt+Shift + {j,k}` for previous/next
- **MPV**: Video seeking (5 sec, 60 sec, 5 min intervals)
  - Basic: `{h,l,j,k}` / `arrows` / `numpad`
  - Modified: `Shift/Ctrl + keys` for larger jumps
- **Btop**: Process navigation with vim_keys enabled

#### ⚡ Native Support (Partial)
- **Helix**: Native vim + arrow support (external app, no numpad possible)
- **Fish Shell**: Vi mode with hjkl + native arrow support

### Key Design Decisions

1. **Modifier Choice**: Each app uses appropriate modifiers to avoid conflicts:
   - BSPWM: Super (system-wide window management)
   - Tmux: Alt+Shift (avoids Fish shell Alt+l conflict)
   - MPV: No modifier for basic navigation

2. **Tab-Only Tmux**: We disabled tmux panes entirely to avoid the "nested panes problem"
   where tmux panes inside BSPWM tiles create navigation confusion. BSPWM handles tiling,
   tmux handles only terminal tabs.

3. **Terminal Encoding**: Alt+Shift+letter sends Alt+UPPERCASE in terminals,
   so tmux uses `M-H` instead of `M-S-h` in its configuration.

### Testing Navigation
To verify tri-modal navigation works in any app:
1. Test vim keys: h (left), l (right), j (down), k (up)
2. Test arrow keys: ←, →, ↓, ↑
3. Test numpad: 4 (left), 6 (right), 2 (down), 8 (up) with NumLock ON

## Dotfiles Management

This system uses a **bare Git repository** for dotfiles management, accessible via the `dots` command.

### How It Works

The dotfiles are managed using a bare Git repository located at `~/.dotfiles/`. This approach allows version control of configuration files without turning the entire home directory into a Git repository.

### The `dots` Command

`dots` is a Fish shell function defined in `~/.config/fish/functions/dots.fish`:
```bash
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
```

### Common Dotfiles Commands

```bash
dots status           # Check status of tracked files
dots add <file>       # Stage a file for commit
dots commit -m "msg"  # Commit changes
dots push            # Push to remote repository
dots diff            # View unstaged changes
dots log             # View commit history
```

### Fish Shell Abbreviations

The following abbreviations are configured in Fish:
- `da` → `dots add`
- `dc` → `dots commit`
- `dp` → `dots push`
- `dst` → `dots status`
- `dd` → `dots diff`


## Key Configuration Files

### Window Manager & Hotkeys
- `~/.config/bspwm/bspwmrc` - BSPWM configuration
- `~/.config/sxhkd/sxhkdrc` - Keyboard shortcuts (including ThinkPad function keys)

### Shell Configurations
- `~/.config/fish/config.fish` - Fish shell configuration
- `~/.config/fish/functions/` - Custom Fish functions (including `dots`)

### Other Important Configs
- `~/.config/alacritty/` - Terminal emulator configuration
- `~/.config/polybar/` - Status bar configuration

## ThinkPad Function Keys

The following function keys are configured in SXHKD:

### Volume Controls
- **Fn+F1** or **Super+F1** → Mute/unmute audio
- **Fn+F2** or **Super+F2** → Volume down (10%)
- **Fn+F3** or **Super+F3** → Volume up (10%)

### Microphone
- **Fn+F4** or **Super+F4** → Mute/unmute microphone

### Display & Brightness
- **Fn+F7** or **Super+F7** → Brightness down (10%)
- **Fn+F8** or **Super+F8** → Brightness up (10%)

## Polybar Window Title System

### Overview
The polybar displays intelligent, context-aware window titles that update in real-time when switching windows, tmux tabs, or browser tabs. This system solves the problem of titles being too long, redundant, or not updating when tabs change within applications.

### How It Works

#### Architecture
1. **Independent Daemon**: `~/.config/polybar/scripts/window-title-daemon.sh` runs separately from polybar
   - Started by `~/.config/polybar/launch.sh` when polybar launches
   - Uses IPC hooks to communicate with polybar (doesn't block hide/show)

2. **Dual Monitoring**:
   - **Focus changes**: Via `bspc subscribe node_focus desktop_focus`
   - **Title changes**: Via `xprop -spy WM_NAME` on the focused window
   - This catches both window switches AND tab switches within apps

3. **Smart Filtering**: Transforms verbose titles into concise labels
   - Removes redundancy: "tmux - tmux" → just shows current tmux window name
   - Simplifies web apps: "(1) WhatsApp — Mozilla Firefox" → "WhatsApp"
   - Intelligent fallback: Shows actual page titles when app can't be identified

### Title Transformation Examples

```
Raw Title                                    → Displayed As
──────────────────────────────────────────────────────────
"~/dev/project: tmux - tmux"                → "project"
"(1) WhatsApp — Mozilla Firefox"            → "WhatsApp"
"Issue #123 · owner/repo — GitHub"          → "GitHub"
"pentaxis93"                                → "pentaxis93" (GitHub profile, no "GitHub" in title)
"Some Blog Post — Medium"                   → "Some Blog Post"
"Video Title - YouTube"                     → "Video Title"
```

### Configuration & Customization

#### Adding a New Web App for Simplified Display
Edit `~/.config/polybar/scripts/window-title-daemon.sh`, find the web apps section (~line 150):
```bash
# Add your app to the detection pattern
elif echo "$title" | grep -qE "(WhatsApp|Gmail|...|YourApp)"; then
    # Add a condition for your app
    elif echo "$title" | grep -q "YourApp"; then
        title="YourApp"
```

#### Adjusting Title Length
Change `MAX_LENGTH` at the top of the daemon script (default: 30 chars)

### Troubleshooting

#### Problem: Tmux tabs not updating when switching
```bash
# Check if tmux titles are enabled
tmux show-options -g | grep set-titles
# Should show: set-titles on

# If not, add to ~/.tmux.conf:
set -g set-titles on
set -g set-titles-string '#W'

# Then reload tmux config:
tmux source-file ~/.tmux.conf
```

#### Problem: Titles stuck or not updating at all
```bash
# Check for zombie daemons
ps aux | grep window-title-daemon

# Kill all and restart cleanly
killall window-title-daemon.sh
killall xprop
rm /tmp/window-title-daemon.pid
~/.config/polybar/launch.sh
```

#### Debug mode for troubleshooting
```bash
# Edit daemon script and set DEBUG=1
vi ~/.config/polybar/scripts/window-title-daemon.sh

# Then check logs:
tail -f /tmp/window-title-daemon.log
```

### Related Files
- `~/.config/polybar/scripts/window-title-daemon.sh` - The main daemon with filtering logic
- `~/.config/polybar/config.ini` - Defines window-title module (custom/ipc type)
- `~/.config/polybar/launch.sh` - Starts daemon with polybar
- `~/.tmux.conf` - Must have `set-titles on` for tmux tab detection
- `/tmp/window-title.txt` - Current title (what polybar reads via hook)

## Common Tasks

### Adding New Configuration to Dotfiles
```bash
dots add ~/.config/newapp/config
dots commit -m 'Add newapp configuration'
dots push
```

### Reloading Configurations
```bash
# Reload SXHKD (or use Super+Escape)
pkill -USR1 -x sxhkd

# Restart BSPWM (or use Super+Alt+R)
bspc wm -r
```

### Audio Management
```bash
# Using wpctl (PipeWire)
wpctl get-volume @DEFAULT_AUDIO_SINK@
wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
```

### Brightness Control
Brightness is controlled via sysfs. Note: Requires sudo privileges.
```bash
# Current brightness
cat /sys/class/backlight/intel_backlight/brightness

# Set brightness (max is 19393)
echo 10000 | sudo tee /sys/class/backlight/intel_backlight/brightness
```

## Documentation Lookup

### Using Context7 for Documentation
When you need documentation for tools, libraries, or terminal emulators, use the context7 MCP server instead of web searches. This provides more accurate and up-to-date documentation.

Examples of when to use context7:
- Terminal emulator documentation (kitty, alacritty, wezterm)
- Tool configurations (tmux, helix, fish)
- Programming libraries and frameworks
- System tools and utilities

To use: Ask Claude Code to "use context7 to get documentation for [tool/library]"

## System Theme: Gruvbox Dark Hard

The entire system uses the **Gruvbox Dark Hard** color scheme with a custom cyan accent hierarchy for semantic consistency across all applications.

### Color Palette Reference

#### Core Colors
- **Background**: `#1d2021` (hard dark) - Primary background
- **Background Alt**: `#3c3836` (dark gray) - Secondary backgrounds, inactive elements
- **Foreground**: `#ebdbb2` (light cream) - Primary text
- **Disabled**: `#928374` (gray) - Disabled or muted elements

#### Accent Colors (Our Cyan Hierarchy)
- **Primary Accent**: `#8ec07c` (bright aqua) - Active/focused/selected elements
- **Secondary Accent**: `#689d6a` (regular aqua) - Labels, informational text, inactive accents

#### Semantic Colors
- **Error/Alert**: `#fb4934` (bright red) - Errors, alerts, urgent items
- **Warning**: `#fabd2f` (bright yellow) - Warnings, caution states
- **Success**: `#b8bb26` (bright green) - Success states, confirmations
- **Info**: `#83a598` (bright blue) - Informational messages

### Why Aqua Looks "Greenish"
The Gruvbox "aqua" colors (`#8ec07c` and `#689d6a`) intentionally lean toward green rather than pure cyan. This creates a warmer, more organic feel that fits Gruvbox's retro, earthy aesthetic. This is not a bug but a deliberate design choice that distinguishes Gruvbox from cooler, more synthetic color schemes.

### Applied Configurations
- **Terminal**: Alacritty, Tmux, Fish shell with Gruvbox colors
- **Window Manager**: BSPWM with aqua borders (`#8ec07c`)
- **Status Bar**: Polybar with cyan accent hierarchy
- **Prompt**: Pure - minimal async prompt for fish
- **Editor**: Helix with gruvbox_dark_hard
- **File Manager**: Thunar with custom GTK overrides
- **Icons**: Papirus-Dark with teal folders (closest to our aqua)
- **GTK Theme**: Gruvbox-Teal-Dark with custom CSS overrides in `~/.config/gtk-3.0/gtk.css`

## Configuration Documentation Best Practices

### In-File Documentation Philosophy
**Documentation should live as close to the code as possible.** Future developers (including yourself) will look at the file itself, not external documentation. Well-documented configurations are self-contained and self-explanatory.

### The Documentation Hierarchy

1. **File Header Block**: Purpose, behavior, dependencies
2. **Section Headers**: Group related settings with clear titles
3. **Inline Comments**: Explain the WHY, not just the what
4. **Examples**: Show usage patterns where helpful

### Best Practices for Discoverable Documentation

#### 1. Start with a Comprehensive Header
Every script or complex config should have:
```bash
# ============================================================================
# TITLE IN CAPS
# ============================================================================
# Purpose:
#   What problem does this solve?
#
# How it works:
#   High-level overview of the mechanism
#
# Dependencies:
#   What needs to be installed/configured
#
# Usage:
#   Examples of how to use it
#
# Troubleshooting:
#   Common issues and solutions
#
# Related Files:
#   Other configs that interact with this
# ============================================================================
```

#### 2. Always Explain the "Why"
Don't just document what a setting does - explain why you chose it.

**Bad:**
```bash
bspc config focused_border_color "#8ec07c"  # Set border color
```

**Good:**
```bash
bspc config focused_border_color "#8ec07c"  # Bright aqua - matches terminal accent, draws attention to focused window
```

**Better:**
```bash
volume=70                        # Default volume level (0-100)
                                # WHY: Safe starting volume that won't blast your ears
```

#### 3. Group Related Settings with Section Headers
```bash
# ============================================================================
# WATCH LATER / RESUME FEATURES
# ============================================================================
# These settings ensure you never lose your place in a video...

save-position-on-quit=yes       # Auto-save position when quitting
resume-playback=yes              # Auto-resume from saved position
```

#### 4. Document Non-Obvious Interactions
```bash
# Kill any existing instances to prevent duplicates
pkill -f polybar-autohide.sh 2>/dev/null
sleep 0.5  # Brief pause to ensure clean termination

# Start with nohup so it survives parent shell exit
nohup "$HOME/.config/bspwm/polybar-autohide.sh" >/dev/null 2>&1 &
```

#### 5. Include Debugging Information
```bash
# Debugging:
#   - Check if running: pgrep -f polybar-autohide.sh
#   - View logs: tail -f /tmp/polybar-autohide.log
#   - Manual restart: pkill -f polybar-autohide.sh && nohup ~/.config/bspwm/polybar-autohide.sh &
```

#### 6. Document Configuration Points
```bash
# To add more video players, add them to this regex pattern (e.g., |kodi|plex)
if [[ "$win_class" =~ ^(mpv|vlc|mplayer|smplayer|celluloid|haruna)$ ]]; then
```

#### 7. Document Color Semantics
Explain what each color represents in your UI hierarchy.

```css
/* Color hierarchy:
 * - Bright aqua (#8ec07c): Active/focused elements (grabs attention)
 * - Regular aqua (#689d6a): Informational text (provides context)
 * - Gray (#928374): Disabled items (de-emphasized)
 */
```

#### 8. Include Both Hex Codes and Names
Always provide both for clarity:
```css
color: #8ec07c;  /* bright aqua */
```

#### 9. Cross-Reference Related Configs
Note when settings should match across tools:
```bash
# This should match the border color in ~/.config/bspwm/bspwmrc
set -g pane-active-border-style 'fg=#8ec07c'
```

#### 10. Explain Non-Obvious Choices
Document anything that might confuse future you:
```css
/* Using 30% opacity to keep text readable while showing selection.
 * Higher opacity makes the underlying text too hard to read. */
background-color: rgba(142, 192, 124, 0.3);
```

#### 11. Document Overrides and Workarounds
Explain why you're overriding defaults:
```css
/* Override Gruvbox-Teal theme selection color (#89b482)
 * to match our consistent aqua accent (#8ec07c) */
.thunar .sidebar row:selected {
  background-color: rgba(142, 192, 124, 0.3);
}
```

## Documentation System

### Structure
Our documentation follows a minimal, high-value approach:

- **docs/adr/** - Architecture Decision Records for important choices
- **docs/issues/** - Investigations of complex problems
- **docs/roadmap/** - Planning for significant features
- **docs/README.md** - Navigation index for all documentation
- **CHANGELOG.md** - Track all changes with date-based versioning
- **CLAUDE.md** - This file, the primary system documentation

### Documentation Triggers

#### Must Document:
- **Architectural decisions** → Create ADR using template
- **Complex problem solutions** → Create issue doc
- **New tool integrations** → Update CLAUDE.md
- **Breaking changes** → Update CHANGELOG.md prominently

#### Consider Documenting:
- Non-obvious workarounds → Inline comments or CLAUDE.md
- Performance optimizations → Brief ADR or commit message
- Configuration rationale → Inline comments

#### Don't Document:
- Obvious changes (formatting, typos)
- Standard tool configurations
- Temporary experiments

### Maintaining Documentation

When making changes:
1. Ask: "Will I wonder why later?" → Create ADR
2. Ask: "Is this non-obvious?" → Add inline comment
3. Ask: "Does this change workflows?" → Update CLAUDE.md
4. Always: Write clear commit messages

Remember: This is personal dotfiles, not enterprise software. Document the
"why" when it matters, skip the bureaucracy when it doesn't.

### Finding Documentation

```bash
# Search all documentation
grep -r "search term" ~/.config/dotfiles/docs/

# Find specific ADRs
ls ~/.config/dotfiles/docs/adr/

# Check recent changes
head -50 ~/.config/dotfiles/docs/CHANGELOG.md
```

## Development Patterns

### Test-and-Commit Checkpoint Pattern
When making configuration changes, follow this critical pattern:

1. **Make a single, atomic change** - One feature/fix at a time
2. **Test the change thoroughly** - Verify it works as expected
3. **Commit immediately if successful** - Create a checkpoint
4. **Document any setup requirements** - In the file where users will look

**Why this matters:**
- **Atomic commits** make it easy to identify which change broke something
- **Immediate testing** catches problems before they compound
- **Frequent commits** create restore points you can revert to
- **In-file documentation** ensures setup requirements are discoverable

**Example workflow:**
```bash
# 1. Make change
vi ~/.config/sxhkd/sxhkdrc

# 2. Test immediately
pkill -USR1 -x sxhkd  # Reload
# Test the actual keybinding

# 3. Commit if working
dots add ~/.config/sxhkd/sxhkdrc
dots commit -m "Fix: Improve keybinding for X feature"

# 4. Move to next change
# Repeat pattern
```

**Bad pattern (avoid this):**
- Making 10 changes across multiple files
- Testing everything at the end
- One giant commit with "Various improvements"
- Finding something broken with no idea which change caused it

### Configuration Philosophy
- **Simplicity First**: Prefer direct inline commands over helper scripts when possible
- **Version Control**: All configuration changes should be committed to the dotfiles repo
- **Documentation**: Update this file when adding new tools or changing workflows
- **Test Checkpoints**: Always test-and-commit after each discrete change

### Commit Message Philosophy
- **Clean Messages**: Focus on what changed and why, not who made the change
- **No Attribution Footers**: Avoid "Generated by", "Co-authored-by", or emoji footers in personal dotfiles
- **Git Tracks Authorship**: The version control system already records who made each commit
- **Signal Over Noise**: Every line should add value - metadata that duplicates git's built-in tracking just adds clutter

**Good commit message:**
```
Update CLAUDE.md: Remove outdated Zsh references

- Fish is now the only shell (Zsh not installed)
- Simplify dotfiles command examples
```

**Unnecessary additions:**
```
🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

These footers don't add value in a personal repository where you're the primary author and git already tracks timestamps and authorship.

### When Making Configuration Changes
1. Test changes locally first
2. Use `dots diff` to review changes
3. Write clean, descriptive commit messages
4. Skip attribution footers - git already tracks authorship

### Best Practices
- Keep SXHKD keybindings simple and well-commented
- Use tabs (not spaces) for indentation in SXHKD config
- Test keybindings after reloading SXHKD
- Document any new tools or scripts added to the system

## System-Specific Notes

- **Package Manager**: `pacman` (with `yay` for AUR packages)
- **Init System**: systemd
- **Graphics**: Intel integrated graphics (Tiger Lake-LP)
- **Backlight Path**: `/sys/class/backlight/intel_backlight/`

## Claude Code Integration

Claude Code is configured with a security-focused, layered approach.

### Installation
- **Method**: Automatically installed via `bootstrap.sh` using NPM
- **Binary Location**: `~/.local/bin/claude` (via NPM prefix configuration)
- **First-time Setup**: Run `claude login` to authenticate
- **Notification Setup**: Handled by `setup-system.sh` (terminal bell)

### Configuration Architecture

#### **Settings Hierarchy**
1. **Global Settings** (`~/.claude/settings.json`) - Tracked in dotfiles
   - Model: `opus` (automatically uses latest)
   - Output style: `Explanatory`
   - Security-zoned permissions (Green + Yellow zones)
   - Development environment variables

2. **Dotfiles Project Settings** (`~/.config/dotfiles/.claude/settings.json`) - Tracked
   - Dotfiles-specific permissions only (dots, bspwm, polybar)
   - No duplication of global permissions

3. **Local Overrides** (`*.local.json`) - Never tracked
   - Machine-specific overrides (kept minimal)

#### **Security Zone Model**

**Green Zone** (Safe, read-only):
- Information commands (echo, ps, which, env)
- File inspection (ls, grep, cat, head, tail)
- Package queries (pacman -Q, npm list)
- Git status operations
- System queries (fc-list, locale, bspc query)

**Yellow Zone** (User-level modifications):
- Process control (pkill, kill)
- Development tools (make, npm, python, cargo)
- Testing/linting (pytest, eslint, ruff)
- Version control (git add/commit/push)
- Common utilities (curl, wget, tar)

**Red Zone** (Implicit - always asks):
- System modifications (sudo, pacman -S)
- Force operations (git push -f, rm -rf)
- Global changes (/etc modifications)

#### **Environment Variables**
```json
{
  "EDITOR": "helix",
  "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1",
  "BASH_MAX_OUTPUT_LENGTH": "50000",
  "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "8192",
  "USE_BUILTIN_RIPGREP": "1"
}
```

### Common Pitfalls to Avoid

**For Future Claude Code Instances - Learn from Our Mistakes:**

❌ **Don't overthink it:**
- Don't create template files that need copying - configs are tracked directly
- Don't create per-app setup helper scripts - configs just work when in place
- Don't track `.config/claude/` - that's the wrong location

✅ **Keep it simple:**
- Track `~/.claude/settings.json` directly - these are user preferences
- Follow the existing pattern - look at how alacritty, fish, or bspwm work
- Install via bootstrap, track config, done - no additional abstraction needed

### The Dotfiles Philosophy

This repository follows a "configs just work" principle:
1. **Install** via bootstrap (pacman/yay/npm)
2. **Track** config files directly where the app expects them
3. **That's it** - no unnecessary abstraction layers

When adding new tools, resist the urge to be clever. The beauty of this dotfiles setup is its simplicity. Configs are tracked in their natural locations, apps find them automatically, everything just works.

**Example of the pattern:**
- Alacritty config? → Track `.config/alacritty/alacritty.toml`
- Fish config? → Track `.config/fish/config.fish`
- Claude user settings? → Track `.claude/settings.json`

No templates, no copying, no setup scripts. Direct tracking.

## Troubleshooting

### If `dots` command not found
The `dots` command is a Fish function. If it's not available, check that Fish is running or use the full Git command:
```bash
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME status
```

### If keybindings don't work
1. Check SXHKD is running: `pgrep sxhkd`
2. Reload configuration: `pkill -USR1 -x sxhkd`
3. Check for syntax errors: `sxhkd -c ~/.config/sxhkd/sxhkdrc`

### Audio issues
- Check PipeWire status: `systemctl --user status pipewire`
- List audio sinks: `pactl list sinks short`
- Check current default: `wpctl status`

### Brightness keys not working
If brightness keys prompt for password or don't work:
1. Run the one-time setup command:
   ```bash
   echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/backlight/intel_backlight/brightness" | sudo tee /etc/sudoers.d/brightness
   ```
2. Test manually: `~/.local/bin/brightness up`
3. Check backlight exists: `ls /sys/class/backlight/`
4. Verify max brightness: `cat /sys/class/backlight/intel_backlight/max_brightness`

### Polybar issues
- Not appearing: Check logs at `/tmp/polybar.log`
- Not hiding for videos:
  - Check daemon: `pgrep -f polybar-autohide.sh`
  - View logs: `tail -f /tmp/polybar-autohide.log`
  - Restart: `pkill -f polybar-autohide.sh && nohup ~/.config/bspwm/polybar-autohide.sh &`
- Manual toggle not working: Ensure `enable-ipc = true` in polybar config

### Terminal colors look wrong
- Verify terminal reports 256 colors: `echo $TERM`
- Test colors: `for i in {0..255}; do printf "\x1b[38;5;${i}mcolor%-5i\x1b[0m" $i ; if ! (( ($i + 1 ) % 8 )); then echo ; fi ; done`
- Check Alacritty config: `alacritty --print-events` (look for config errors)
- Ensure font installed: `fc-list | grep -i meslo`

### Fish shell issues
- Abbreviations not working: Run `abbr --list` to see current abbreviations
- Slow startup: Check for issues with `fish --profile-startup /tmp/fish-profile`
- Config not loading: Verify file exists at `~/.config/fish/config.fish`

### Window manager problems
- BSPWM not starting: Check `~/.xsession-errors` or journalctl
- Windows not tiling: Verify bspwm is running: `pgrep bspwm`
- Can't switch workspaces: Check if sxhkd is running: `pgrep sxhkd`

### Git/Dotfiles issues
- `dots` command not found: Source fish config: `source ~/.config/fish/config.fish`
- Permission denied on push: Check SSH key is loaded: `ssh-add -l`
- Conflicts on checkout: Back up conflicting files first (see README.md)

### Font rendering issues
- Install required fonts:
  ```bash
  yay -S nerd-fonts-meslo ttf-font-awesome
  fc-cache -fv
  ```
- Verify font in terminal: `fc-match "MesloLGS Nerd Font"`

### System performance
- High CPU from polybar: Check for infinite loops in scripts
- Slow window switching: Disable compositor effects temporarily
- Memory issues: Check for memory leaks: `ps aux --sort=-%mem | head`

---

*This file helps Claude Code understand the system context and common workflows. Update it when making significant system changes.*