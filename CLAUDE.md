# Chezmoi Dotfiles - AI Instructions

> Simplicity is the ultimate sophistication

**Project**: Chezmoi-managed dotfiles following YAGNI principles
**Source**: `~/.local/share/chezmoi` → **Target**: `~` (home directory)

## Quick Reference

@docs/ai-context/chezmoi-commands.md
@docs/ai-context/project-structure.md

---

## QUICK DECISIONS

**Fresh installation?** → Pre-install `yay` + `python-colour` + `fortune-mod` (CRITICAL) + `bitwarden-cli` (optional, needs login) BEFORE `chezmoi apply`

**Adding a package?** → Edit `home/.chezmoidata/packages.yaml` (declarative only)

**Need secrets?** → Use Bitwarden templates (`@bitwarden-*.tmpl`)

**New config file?** → MUST use semantic colors + keybindings templates

**Moving/renaming files?** → Use `git mv` (preserve history)

**Looking up external library docs?** → Use Context7 MCP (`resolve-library-id` → `get-library-docs`)

**Simple code change?** → Use built-in tools (Read, Edit, Write, Grep)

**Refactoring workflow?** → `chezmoi edit` → `chezmoi diff` → `chezmoi apply -v` → **Update docs**

**ZFS snapshots?** → `zsnap` (manual), `zlist` (view), `zclean` (prune), `zfsstatus` (health) - See @docs/ai-context/systems/zfs.md

---

## CRITICAL DIRECTIVES

### Package Management (CRITICAL - NEVER VIOLATE)

**ABSOLUTE PROHIBITION**: NEVER execute `pacman`, `yay`, `sudo pacman`, `sudo yay`, or ANY package manager command directly.
**ONLY PATH**: Edit `home/.chezmoidata/packages.yaml` declaratively.
**USER INSTALLS**: User runs `chezmoi apply` to install packages.

**Even if**:
- ❌ Mirrors are down → Do NOT manually install
- ❌ Package download fails → Do NOT troubleshoot with direct commands
- ❌ Package unavailable in repo → Do NOT try alternative methods
- ❌ User asks you to install → Still edit packages.yaml, inform them to run `chezmoi apply`

**Correct Workflow** (non-negotiable):
1. Edit `home/.chezmoidata/packages.yaml` to add/remove packages
2. Inform user that packages have been added to the manifest
3. User runs `chezmoi apply` to trigger installation
4. If installation fails, inform user of the error and let THEM troubleshoot

**Why This Matters**:
- Configuration as code - all changes tracked in git
- Reproducible across machines
- User maintains control over their system
- Prevents AI from making untracked system modifications

### Security Rules (IMPORTANT)

**NEVER** commit secrets to git repository.
**ALWAYS** use `private_` prefix for sensitive files (600 permissions).
**Secrets flow** through Bitwarden templates only (`@bitwarden-*.tmpl`).

See: @docs/ai-context/apps/bitwarden.md

### Core Workflow (IMPORTANT)

```bash
1. chezmoi edit <file>
2. chezmoi diff
3. chezmoi apply -v
4. Update documentation (CRITICAL!)
```

**Documentation Synchronization**: After any code change, update all relevant docs including `CLAUDE.md`, `README.md`, and subdirectory READMEs. Documentation updates and code updates are **integral parts of the same action** - never complete a task without updating affected documentation.

### Enabling Claude Code to Run `chezmoi apply` (IMPORTANT)

By default, Claude Code cannot run `chezmoi apply` because Bitwarden templates require an unlocked vault with interactive password entry.

**Solution**: Export `BW_SESSION` before starting Claude Code:
```bash
export BW_SESSION=$(bw unlock --raw)
claude   # Now Claude Code can run chezmoi apply autonomously
```

**Why this matters**: With `BW_SESSION` exported, Claude Code can:
- Apply configuration changes without user intervention
- Restart services after config updates
- Complete full edit→apply→verify cycles independently

**Security note**: The session token is ephemeral and scoped to your terminal session.

---

## MCP SERVER USAGE GUIDE

### Context7 MCP - Documentation Retrieval

**Purpose**: Fetch up-to-date documentation for external libraries and frameworks.

**When to use:**
- ✅ Need current documentation for external libraries (React, Rust, Python packages, etc.)
- ✅ Exploring unfamiliar frameworks or APIs
- ✅ Verifying best practices for third-party tools
- ✅ Looking up breaking changes or migration guides

**When NOT to use:**
- ❌ Internal project documentation (use Read/Grep tools instead)
- ❌ Chezmoi-managed config files (use project structure knowledge)
- ❌ Questions answerable from existing context

**Usage pattern:**
```
1. mcp__context7__resolve-library-id(libraryName: "react")
   → Returns Context7-compatible library ID (e.g., "/facebook/react")

2. mcp__context7__get-library-docs(
     context7CompatibleLibraryID: "/facebook/react",
     topic: "hooks",  # Optional: focus on specific area
     tokens: 5000     # Optional: adjust context size
   )
   → Returns relevant documentation focused on topic
```

**Philosophy**: Bring external knowledge into our realm when needed, but prefer local understanding first.

---

### New Configuration Mandate (CRITICAL)

When creating ANY new application configuration, you MUST use the semantic systems:

**Semantic Colors (MANDATORY)**:
- **NEVER** hardcode hex colors in new configs
- **ALWAYS** use `{{ template "color-hex.tmpl" (index $theme $s.semantic.category) }}`
- Define semantic meaning first, let theme provide color
- Single source of truth: `home/.chezmoidata/colors.yaml`
- See @docs/ai-context/systems/colors.md for complete system

**Semantic Keybindings (MANDATORY)**:
- **NEVER** hardcode keybindings for core semantic actions (navigate, discover, dismiss, transform, preserve, select, manipulate)
- **ALWAYS** use `{{ template "keybind-<app>.tmpl" dict ... }}` for semantic actions
- Create app-specific template if needed (follow existing patterns)
- Hardcode ONLY application-specific non-semantic bindings
- Helix-native philosophy: `ge` for end (not `G`), `gh/gl` for line start/end - semantic clarity over vim tradition
- Single source of truth: `home/.chezmoidata/keybindings.yaml`
- See @docs/ai-context/systems/keybindings.md for complete system

**Non-Negotiable**: These systems are architectural foundations. Deviation requires explicit user approval.

---

## ARCHITECTURE PRINCIPLES

### YAGNI Philosophy
**Each configuration option must justify its existence.**
- Prefer defaults when they align with our principles
- Choose simplicity over complexity when outcomes are equivalent
- Delete before adding

### MCP Server Philosophy
**"Bring external knowledge into our realm when needed"**

- **Context7**: Fetches up-to-date documentation for external libraries
- **Private Journal**: Personal learning and reflection tool for Claude Code
- **Built-in tools**: For execution and implementation

### Reverse Video Selections Philosophy
*"Do not paint the water to make the fish visible. Let the fish and water exchange places."*

Selections use **reverse video** (fg/bg swap), not colored backgrounds:
- Perfect contrast always guaranteed
- No configuration complexity
- Universal solution for all TUI apps

---

## THINGS NOT TO DO

**DON'T** run `chezmoi apply` on fresh install without pre-installing `python-colour` and `fortune-mod` first (will fail during template/script processing).
**DON'T** create duplicate configs outside chezmoi source directory.
**DON'T** hardcode colors - MUST use semantic color templates from `colors.yaml`.
**DON'T** hardcode semantic keybindings - MUST use keybind templates from `keybindings.yaml`.
**DON'T** break git history (use `git mv` for refactoring, not delete+create).
**DON'T** skip documentation updates after code changes (CRITICAL).
**DON'T** install packages directly (use declarative `packages.yaml`).
**DON'T** commit secrets (use Bitwarden templates).
**DON'T** fetch Context7 docs for internal project files (use Read/Grep instead).

---

## CLAUDE CODE CUSTOM COMMANDS

### Slash Commands with Model Configuration

Custom slash commands can specify their default model via frontmatter metadata. This ensures consistent behavior when invoking specific workflows.

**File Location**: `~/.claude/private_commands/` (project-specific) or `~/.claude/commands/` (global)

**Frontmatter Format**:
```markdown
---
name: commandname
description: What this command does
model: haiku
---

## Command Instructions

Your detailed instructions here...
```

**Available Model Aliases** (short aliases automatically update to latest versions):
- `haiku` - Fast, lightweight model (ideal for structured tasks)
- `sonnet` - Balanced model (default for general work)
- `opus` - Most capable model (for complex analysis)
- `opusplan` - Hybrid mode: Opus planning + Sonnet execution
- `default` - Your account's recommended model

**Note**: Use short aliases (`haiku`, `sonnet`, `opus`) instead of dated versions. Short aliases automatically point to the latest model releases without manual updates.

**Examples**:
- **`/storyline`** - Uses Haiku for fast atomic commit planning
  - File: `home/dot_claude/private_commands/storyline.md`
  - Purpose: Analyze uncommitted changes and plan Zen commits
  - Why Haiku: Structured analysis task, fast execution

**Benefits**:
- **Predictable Performance**: Each command uses its optimal model
- **Cost Efficiency**: Haiku for structured tasks, Sonnet for complex work
- **Consistency**: Commands always use the same model regardless of global settings

### Adding New Custom Commands

When creating a new custom command:
1. **Create file**: `~/.claude/private_commands/mycommand.md`
2. **Add frontmatter** with name, description, and model
3. **Write instructions** as clear, actionable prompts
4. **Document in CLAUDE.md** why that model was chosen

**Model Selection Guidelines** (use short aliases):
- **`model: haiku`** for: Structured analysis, planning, pattern matching, fast iteration
- **`model: sonnet`** for: General-purpose work, code review, creative tasks
- **`model: opus`** for: Complex architecture decisions, deep analysis, research
- **`model: opusplan`** for: Hybrid workflows needing Opus reasoning with Sonnet execution

### Superpowers Plugin

The **superpowers plugin** provides 20+ battle-tested skills for structured software development workflows.

**Installation** (manual one-time setup):
```bash
# Start Claude Code in interactive mode
claude

# Run these slash commands
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace --scope user

# Restart Claude Code to activate
```

**Why Manual?**: Plugin installation cannot be automated from CLI - it requires slash commands in an interactive Claude Code session.

**What You Get**:
- **Structured Workflows**: `/superpowers:brainstorm`, `/superpowers:write-plan`, `/superpowers:execute-plan`
- **20+ Skills**: TDD, debugging, collaboration patterns, and more
- **Skill Discovery**: `find_skills` and `use_skill` tools for exploring available capabilities
- **SessionStart Context**: Automatic context injection on session start

**Configuration**:
- Script: `home/run_after_claude-code.sh` - Checks installation status and prompts if needed
- Marketplace: obra/superpowers-marketplace (auto-registered in known marketplaces)
- Scope: User-level (works across all projects)

**Verification**: After installation, ask Claude "do you have superpowers?" or check `/help` for the superpowers commands.

---

## APPLICATION CONFIGURATIONS

### Core Applications
- @docs/ai-context/apps/helix.md - Modal editor with semantic colors and soft wrap
- @docs/ai-context/apps/mpv.md - Media player with LF browser integration
- @docs/ai-context/apps/zen-browser.md - Privacy-focused browser with vertical tabs and semantic theming (primary browser)
- @docs/ai-context/apps/qutebrowser.md - Keyboard-driven web browser
- @docs/ai-context/apps/weechat.md - IRC client with XDCC support
- @docs/ai-context/apps/transmission.md - BitTorrent with VPN killswitch
- @docs/ai-context/apps/lf.md - Terminal file manager
- @docs/ai-context/apps/lazygit.md - Git TUI with reverse video

### System Tools
- @docs/ai-context/apps/automation.md - System automation (ydotool, wev, socat, slurp, grim)
- @docs/ai-context/apps/vpn.md - OpenVPN with Bitwarden secrets
- @docs/ai-context/apps/wiremix.md - PipeWire audio mixer TUI
- @docs/ai-context/apps/bluetui.md - Bluetooth device manager TUI
- @docs/ai-context/apps/shell-enhancements.md - eza, zoxide, Fish shell
- @docs/ai-context/apps/flutter.md - Flutter/Dart development with fvm version manager
- @docs/ai-context/apps/fortune.md - Fortune with Zen quotes for contemplative terminal sessions

---

## SYSTEM ARCHITECTURES

- @docs/ai-context/systems/colors.md - Semantic color system & reverse video
- @docs/ai-context/systems/keybindings.md - Semantic keybinding architecture
- @docs/ai-context/systems/spectrum.md - Algorithmic color spectrum generation
- @docs/ai-context/systems/zfs.md - ZFS time machine with automated snapshots

---

## MULTI-MACHINE CONFIGURATION

### Dual Laptop/Desktop Architecture

**Philosophy**: *"One configuration flows to many machines; hardware differences manifest through feature detection, not explicit naming"*

### Machine Detection System

**Auto-detection via `.is_laptop`**:
- **Detection Method**: Presence of `/sys/class/power_supply/BAT*` (battery detection)
- **Configuration**: Set in `home/.chezmoi.toml.tmpl` via `promptBoolOnce` with smart defaults
- **Benefits**: Works on new machines without hardcoding hostnames

### Machine-Specific Configurations

**Display Configuration** (Niri):
- **Desktop**: Dual monitors - HDMI-A-1 (primary, right) and DP-1 (secondary, left)
  - Per-monitor workspaces: Each monitor has independent workspace 1-9
  - Monitor focus: `MOD+;` (left) / `MOD+'` (right) - spatial 2-key shortcuts
  - Alternative: `MOD+SHIFT+H/L` or arrow keys for monitor switching
  - Move windows: `MOD+CTRL+;/'` or `MOD+SHIFT+CTRL+H/L`
- **Laptop**: Single eDP-1 display with auto-detected resolution
- **Implementation**: `home/dot_config/niri/config.kdl.tmpl` - Conditional `output` blocks based on `.is_laptop`

**Network Interface** (Waybar):
- **Auto-detection enabled**: No hardcoded interface specification
- **Desktop**: Automatically shows active interface (Ethernet enp42s0 or WiFi wlan0)
- **Laptop**: Automatically shows WiFi (wlan0)
- **Implementation**: `home/dot_config/waybar/config.tmpl` - Interface auto-detection
- **Benefit**: Handles failover scenarios automatically

**Battery Widget** (Waybar):
- **Conditional inclusion**: Only appears when `.is_laptop` is true
- **Implementation**: `home/dot_config/waybar/config.tmpl` - Conditional battery module

### What Remains Universal

**Application Configurations**: All app configs (Helix, Fish, MPV, etc.) are identical across machines
**Semantic Systems**: Both color and keybinding systems are machine-agnostic
**Security & Secrets**: Bitwarden integration works identically everywhere
**ZFS Configuration**: Gracefully handles presence/absence of ZFS

### Troubleshooting Multi-Machine Setup

**Display Issues**:
- Run `niri msg outputs` to verify output names match configuration
- Check that `.is_laptop` is set correctly in `chezmoi data`

**Network Widget Not Showing**:
- Auto-detection should work automatically
- Verify interface is up: `ip link`
- Check Waybar logs if widget shows "offline"

**Battery Widget Missing on Laptop**:
- Verify `.is_laptop` detection: `chezmoi data | grep is_laptop`
- Check battery exists: `ls /sys/class/power_supply/BAT*`

**Wrong Configuration Applied**:
- Check `.is_laptop` value: `chezmoi data | grep is_laptop`
- Re-run chezmoi to re-prompt: `chezmoi init --force`

---

## REFERENCE FILES

- @docs/ai-context/critical-files.md - Key files and their purposes
- @docs/ai-context/best-practices.md - Development guidelines

---

## WORKING PRINCIPLES

1. **Template only when necessary** - machine-specific or secrets
2. **Security first** - never commit secrets, use `private_` prefix
3. **Preview before apply** - `chezmoi diff` then `chezmoi apply -v`
4. **Document everything** - in-document comments, inline docs, discoverable methods
5. **Git history matters** - use `git mv`, not delete+create
6. **YAGNI mindfulness** - justify every configuration option

---

*Each configuration choice must earn its place.*