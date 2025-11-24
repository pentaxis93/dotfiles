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

**Need systematic investigation?** → Use Zen MCP workflows (debug, codereview, analyze, etc.)

**Simple code change?** → Use built-in tools (Read, Edit, Write, Grep)

**Refactoring workflow?** → `chezmoi edit` → `chezmoi diff` → `chezmoi apply -v` → **Update docs**

**ZFS snapshots?** → `zsnap` (manual), `zlist` (view), `zclean` (prune), `zfsstatus` (health) - See @docs/ai-context/systems/zfs.md

---

## CRITICAL DIRECTIVES

### Package Management (IMPORTANT)

**NEVER** use `pacman`, `yay`, or other package managers directly.
**ALWAYS** edit `home/.chezmoidata/packages.yaml` declaratively.
**User runs** `chezmoi apply` to install packages.

**Workflow**:
1. Edit `home/.chezmoidata/packages.yaml` to add/remove packages
2. Inform user that packages have been added to the manifest
3. User runs `chezmoi apply` to trigger installation

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

### Zen MCP - Systematic Investigation Workflows

**Core Philosophy**:
*"These are not merely other AI models - they are **structured investigation methodologies** that guide systematic analysis."*

The value lies in the **workflows themselves**: multi-step investigations with hypothesis testing, evidence gathering, and expert validation. The models are vessels; the workflows are the meditation practice.

**When to use:**
- ✅ Complex problems requiring **systematic multi-step investigation**
- ✅ Tasks demanding **structured methodology** (security audit, code review, deep debugging)
- ✅ Situations where **hypothesis testing** and **evidence gathering** add rigor
- ✅ Need **expert validation** to increase confidence in conclusions
- ✅ Problems with **multiple valid approaches** requiring careful analysis

**When NOT to use:**
- ❌ Simple edits or straightforward implementations
- ❌ Quick lookups or one-line answers
- ❌ Trivial bug fixes with obvious solutions
- ❌ Routine refactoring without architectural implications

**Workflow-First Decision Tree:**

```
Problem Type                          → Zen MCP Workflow Tool
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Code needs review                     → mcp__zen__codereview
Complex bug or mysterious behavior    → mcp__zen__debug
Planning major refactor/redesign      → mcp__zen__planner
Security concerns or audit needed     → mcp__zen__secaudit
Understanding code execution flow     → mcp__zen__tracer
Architecture or pattern analysis      → mcp__zen__analyze
Need comprehensive test coverage      → mcp__zen__testgen
Validating git changes pre-commit     → mcp__zen__precommit
Refactoring code smells               → mcp__zen__refactor
Generating documentation              → mcp__zen__docgen
Complex decision needs consensus      → mcp__zen__consensus
General deep investigation            → mcp__zen__thinkdeep
Brainstorming or discussion           → mcp__zen__chat
```

**Key Workflows Explained:**

- **codereview**: Systematic quality/security/performance analysis with expert validation
- **debug**: Multi-stage root cause investigation with hypothesis testing
- **planner**: Interactive task breakdown with revision and branching capabilities
- **secaudit**: OWASP Top 10, compliance, threat modeling with structured assessment
- **tracer**: Execution flow mapping or dependency analysis (precision/dependencies modes)
- **analyze**: Architecture, performance, maintainability analysis with strategic insights
- **testgen**: Edge case identification and comprehensive test suite generation
- **precommit**: Multi-repository validation and change impact assessment
- **refactor**: Code smell detection, decomposition planning, modernization opportunities
- **docgen**: Function/class documentation with complexity analysis
- **consensus**: Multi-model debate and synthesis for complex decisions
- **thinkdeep**: Deep investigation with progressive hypothesis refinement
- **chat**: Collaborative thinking partner for brainstorming

**Core Insight**: These workflows provide **systematic rigor** that prevents overlooked edge cases, ensures comprehensive analysis, and builds confidence through structured investigation patterns.

**Model Selection**: Each tool has optimal defaults. Respect token budgets - use larger models only for complex analysis. Use `continuation_id` for multi-turn conversations within same workflow.

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
**"One mind seeks wisdom through systematic practice"**

- **Context7**: Brings external knowledge into our realm when needed
- **Zen MCP**: Provides structured investigation workflows for complex problems
- **Built-in tools**: For execution and implementation
- **MCP tools**: For contemplation, systematic analysis, and validation
- **Workflow-first thinking**: Use the appropriate systematic methodology for the problem type
- **Systematic rigor**: Prevents overlooked edge cases through structured investigation patterns

The workflows themselves are the value - they guide multi-step investigations with hypothesis testing, evidence gathering, and expert validation. The models are merely vessels; the workflows are the meditation practice.

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
**DON'T** use Zen MCP workflows for trivial tasks (overkill for simple edits or quick answers).
**DON'T** fetch Context7 docs for internal project files (use Read/Grep instead).
**DON'T** mix `continuation_id` between different Zen MCP workflow types.

---

## APPLICATION CONFIGURATIONS

### Core Applications
- @docs/ai-context/apps/helix.md - Modal editor with semantic colors and soft wrap
- @docs/ai-context/apps/mpv.md - Media player with LF browser integration
- @docs/ai-context/apps/qutebrowser.md - Keyboard-driven web browser
- @docs/ai-context/apps/weechat.md - IRC client with XDCC support
- @docs/ai-context/apps/transmission.md - BitTorrent with VPN killswitch
- @docs/ai-context/apps/lf.md - Terminal file manager
- @docs/ai-context/apps/lazygit.md - Git TUI with reverse video

### System Tools
- @docs/ai-context/apps/vpn.md - OpenVPN with Bitwarden secrets
- @docs/ai-context/apps/wiremix.md - PipeWire audio mixer TUI
- @docs/ai-context/apps/bluetui.md - Bluetooth device manager TUI
- @docs/ai-context/apps/shell-enhancements.md - eza, zoxide, Fish shell
- @docs/ai-context/apps/flutter.md - Flutter/Dart development with fvm version manager
- @docs/ai-context/apps/fortune.md - Fortune with Zen quotes for contemplative terminal sessions
- @docs/ai-context/apps/zen-mcp-server.md - AI model access via OpenRouter

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