# Semantic Color Architecture

> *"Colors have no inherent meaning. Intentions are universal. Configuration speaks only intentions."*

## Executive Summary

This document describes the complete color architecture for our dotfiles, consisting of two complementary systems:

1. **Semantic Colors** - Meaning-based colors (error, success, focus)
2. **Spectrum System** - Algorithmic aesthetic progressions (rainbow gradients)

**Status**: Spectrum System Implemented | Semantic Colors Designed (Phase 5+)
**Total Semantic Colors**: 38 (designed)
**Semantic Categories**: 9
**Config Files**: waybar (spectrum complete), 6 others ready for semantic migration

---

## The Three-Layer Color Philosophy

### Layer 1: Color Codes → Color Names
```yaml
# colors.yaml: Dragon palette
dragon:
  red: "c4746e"          # Hex code → Descriptive name
  green: "8a9a7b"
  blue: "8ba4b0"
```

### Layer 2: Color Names → Semantic Names
```yaml
# colors.yaml: Semantic mappings
semantic_colors:
  state:
    error: "red"         # Semantic purpose → Color name
    success: "green"
```

### Layer 3: Configs Use Only Semantics
```css
/* waybar: No direct color names! */
color: {{ $semantic.state.error }};      /* ✅ Semantic */
color: {{ $c.red }};                     /* ❌ Direct name */
color: #c4746e;                          /* ❌ Hex code */
```

**Benefits**:
- Configs express **intent**, not implementation
- Change theme by updating semantic mappings in ONE place
- Self-documenting: reading config reveals purpose
- Future-proof: semantic meanings persist across themes

---

## The Great Insight: Two Color Systems

During the audit, we discovered that colors serve two fundamentally different purposes:

### Semantic Colors (Meaning-Based)
**Purpose**: Communicate state, feedback, interaction
**Characteristic**: Meaning is universal across contexts
**Examples**:
- `error` = red (because danger/failure)
- `success` = green (because confirmation)
- `focus` = cyan (because active/ready)
- `warning` = yellow (because caution)

**Rule**: If changing the color changes the *meaning*, it's semantic.

### Spectral Colors (Aesthetic-Based)
**Purpose**: Visual beauty, aesthetic progressions
**Characteristic**: Position in spectrum matters, not meaning
**Examples**:
- Waybar modules: disk(red) → cpu(orange) → memory(yellow) → ... → clock(violet)
- The CPU isn't orange because "processing = orange"
- It's orange because it sits at that position in the visible spectrum

**Rule**: If you can reorder colors freely without changing meaning, it's spectral.

### Why This Matters

**Before**: We tried to give semantic names to spectral progressions
- `accent.cpu` → orange
- `accent.memory` → yellow
- `accent.audio` → green

**Problem**: These aren't semantic! The color isn't tied to the domain meaning. We could swap them around and nothing breaks semantically.

**After**: Two separate systems
- **Semantic system**: `state.error`, `interactive.focus`, `text.primary`
- **Spectrum system**: `spectrum(red, violet, 9)` → array of 9 evenly-spaced colors

---

## Semantic Color Categories (38 Total)

### 1. SURFACE (5 colors)
Background colors, containers, layering.

```yaml
surface:
  primary: "bg_dark"        # Main background (windows, bars)
  elevated: "bg_medium"     # Raised surfaces (dialogs, selected items)
  subtle: "bg_dim"          # Alternate rows, subtle differentiation
  overlay: "bg_medium"      # Popups, tooltips, overlays
  muted: "bg_lighter"       # Disabled areas, very subtle backgrounds
```

**Usage**: Any background color for containers, windows, panels.

**Examples**:
- Window background → `surface.primary`
- Dialog background → `surface.elevated`
- Alternate table rows → `surface.subtle`

---

### 2. TEXT (6 colors)
Foreground text, typography hierarchy.

```yaml
text:
  primary: "fg_primary"     # Main text, default foreground
  secondary: "fg_muted"     # Secondary information, less prominent
  muted: "fg_dim"           # Very subtle text, hints
  emphasis: "bright_white"  # Maximum emphasis, important text
  inverted: "black"         # Text on colored backgrounds
  disabled: "bright_black"  # Inactive/disabled text
```

**Usage**: All text and foreground elements.

**Examples**:
- Body text → `text.primary`
- Inactive tab text → `text.secondary`
- Text on colored button → `text.inverted`

---

### 3. STATE (7 colors)
System state, feedback, status indication.

```yaml
state:
  error: "red"                    # Failures, critical issues
  error_emphasis: "bright_red"    # Urgent errors, critical alerts
  warning: "yellow"               # Cautions, non-critical issues
  success: "green"                # Confirmations, successful operations
  success_emphasis: "bright_green" # Strong success, active confirmation
  info: "blue"                    # Informational, neutral state
  info_emphasis: "bright_blue"    # Highlighted information
```

**Usage**: Status messages, feedback, system state indication.

**Examples**:
- Error message → `state.error`
- Success notification → `state.success`
- Loading indicator → `state.info`

---

### 4. INTERACTIVE (5 colors)
User interaction feedback (focus, hover, press, disable).

```yaml
interactive:
  focus: "bright_cyan"            # Currently focused element
  hover_background: "ui_hover"    # Mouse hover background
  hover_text: "green_bright"      # Mouse hover text emphasis
  active: "green"                 # Pressed/active state
  disabled: "bright_black"        # Disabled/inactive elements
```

**Usage**: Interactive element states (buttons, inputs, selections).

**Examples**:
- Focused input border → `interactive.focus`
- Button hover → `interactive.hover_background`
- Disabled button → `interactive.disabled`

---

### 5. SELECTION (3 colors)
Selected content, highlighted regions.

```yaml
selection:
  background: "selection"         # Selected content background
  background_alt: "selection_alt" # Alternate selection style
  foreground: "fg_default"        # Selected content text
```

**Usage**: Text selections, selected items in lists.

**Examples**:
- Text selection in editor → `selection.background`
- Selected menu item → `selection.background`

---

### 6. BORDER (4 colors)
Borders, outlines, separators.

```yaml
border:
  default: "border"         # Standard borders, separators
  focus: "focus"           # Focused element border
  subtle: "bg_light"       # Very subtle borders
  emphasis: "bright_cyan"  # Highlighted borders, important outlines
```

**Usage**: All border and outline elements.

**Examples**:
- Window border → `border.default`
- Focused input border → `border.focus`
- Subtle separator → `border.subtle`

---

### 7. ACCENT (2 colors)
Special purpose, non-state semantic meanings.

```yaml
accent:
  link: "cyan"            # Hyperlinks, targets, references
  private: "magenta"      # Private/incognito modes
```

**Usage**: Special semantic meanings that don't fit state/interactive.

**Examples**:
- Hyperlink → `accent.link`
- Private browsing mode → `accent.private`

**Note**: Originally had 11 accent colors for CPU, audio, network, etc. These moved to the spectrum system!

---

### 8. INDICATOR (4 colors)
Progress bars, loading states, status indicators.

```yaml
indicator:
  loading_start: "blue"      # Loading begins
  loading_complete: "green"  # Loading finished
  loading_error: "red"       # Loading failed
  progress: "bright_cyan"    # Progress bars, active indicators
```

**Usage**: Progress indication, loading states, status indicators.

**Examples**:
- Download in progress → `indicator.loading_start`
- Download complete → `indicator.loading_complete`
- Progress bar → `indicator.progress`

---

### 9. MODE (6 colors)
Editor modes, application modes, modal states.

```yaml
mode:
  normal: "green"      # Normal/command mode
  insert: "blue"       # Insert/input mode
  visual: "yellow"     # Visual/selection mode
  replace: "red"       # Replace/destructive mode
  private: "magenta"   # Private/incognito mode
  passthrough: "blue"  # Passthrough mode
```

**Usage**: Modal editor states, application mode indicators.

**Examples**:
- Helix mode indicator → `mode.normal`, `mode.insert`, `mode.visual`
- Qutebrowser mode indicator → `mode.insert`, `mode.passthrough`, `mode.private`

---

## Spectrum Color System

### Purpose
Generate N evenly-spaced colors along a spectrum for aesthetic progressions.

### Use Cases
- **Waybar modules**: Automatically color modules from red → violet
- **Future**: Any visual progression that needs aesthetic spacing

### Architecture

**Template Helper**: `spectrum-generate.tmpl`

```go-template
{{- /*
Generates N evenly-spaced colors between two endpoints using HSV interpolation.

Parameters (passed as dict):
  - start: Starting color name (e.g., "red")
  - end: Ending color name (e.g., "magenta")
  - count: Number of colors to generate
  - palette: Reference to color palette (.kanagawa.dragon)

Returns: Array of N hex colors
*/ -}}
```

**Algorithm**: HSV Color Space Interpolation
1. Convert start/end hex → HSV
2. Interpolate H, S, V independently across N steps
3. Convert each step back to hex
4. Return array of colors

**Why HSV?** Perceptually uniform color transitions (better than RGB interpolation).

### Waybar Usage Example

**Before** (hardcoded, fragile):
```css
#disk { color: #c4746e; }      /* red */
#cpu { color: #b6927b; }       /* orange */
#memory { color: #c4b28a; }    /* yellow */
/* Adding/removing modules breaks the aesthetic! */
```

**After** (algorithmic, flexible):
```css
{{- $modules := list "disk" "cpu" "memory" "backlight" "pulseaudio" "bluetooth" "network" "weather" "battery" "clock" -}}
{{- $spectrum := template "spectrum-generate.tmpl" (dict "start" "red" "end" "magenta" "count" (len $modules) "palette" $c) -}}

{{- range $i, $module := $modules }}
#{{ $module }} {
    color: {{ index $spectrum $i }};
}
{{- end }}
```

**Benefits**:
- Add/remove modules → spectrum auto-adjusts
- Change endpoints → entire aesthetic shifts
- Always perfectly evenly-spaced
- Self-maintaining

---

## Implementation Strategy

### Phase 0: Spectrum System (Do This First)

**Why First?** Establishes the spectral/semantic separation clearly. Waybar is cleanest test case.

**Tasks**:
1. Implement `spectrum-generate.tmpl` helper with HSV interpolation
2. Add spectrum configuration to colors.yaml (define default endpoints)
3. Migrate waybar modules to use spectrum system
4. Test by adding/removing modules
5. **Commit**: "feat(colors): add algorithmic spectrum generation for aesthetic progressions"

### Phase 1: Semantic Colors Architecture

**Tasks**:
1. Add `semantic_colors:` section to colors.yaml
2. Define 38 semantic colors across 9 categories
3. Document each category's purpose extensively
4. Add usage examples
5. Test template rendering with `chezmoi diff`
6. **Commit**: "feat(colors): add semantic color layer with 38 meaning-based colors"

### Phase 2: Config Migration (One File at a Time)

**Order** (by impact):
1. waybar → semantic (spectrum already done)
2. qutebrowser → semantic (~120 references)
3. kitty → semantic (terminal palette, borders, tabs)
4. niri → semantic (~5 references)
5. wiremix → semantic (~30 references)
6. wofi → semantic (~8 references)
7. zsh → semantic (handled by oh-my-zsh + terminal palette)

**Per-File Process**:
1. Add `{{- $semantic := .kanagawa.semantic_colors -}}` at top
2. Migrate one logical section at a time
3. Test after each section with `chezmoi diff`
4. Visual verification if possible
5. **Commit per file**: "feat(waybar): migrate to semantic colors"

### Phase 3: Cleanup & Documentation

**Tasks**:
1. Verify zero direct color names (`$c.red` etc.)
2. Verify zero hardcoded hex codes
3. Update CLAUDE.md with color architecture
4. Delete temporary audit files
5. **Final commit**: "docs: complete semantic color architecture documentation"

---

## Naming Convention

### Template Variables
```go-template
{{- $c := .kanagawa.dragon -}}              # Color palette (layer 1)
{{- $semantic := .kanagawa.semantic_colors -}} # Semantic mappings (layer 2)
```

### Usage in Configs
```css
/* Semantic colors */
color: {{ $semantic.state.error }};
background: {{ $semantic.surface.primary }};
border: {{ $semantic.border.focus }};

/* Spectrum colors */
{{- $spectrum := template "spectrum-generate.tmpl" (dict "start" "red" "end" "violet" "count" 5 "palette" $c) -}}
color: {{ index $spectrum 0 }};
```

### Benefits of Naming
- Clear distinction from `semantic_keybindings` (parallel systems)
- Self-documenting variable names
- Explicit layer separation

---

## Migration Impact Assessment

### Files by Impact

**Critical** (>20 references):
- qutebrowser/config.py.tmpl: ~120 references
- wiremix/wiremix.toml.tmpl: ~30 references
- waybar/style.css.tmpl: ~25 references (semantic) + 9 (spectrum)
- kitty/kitty.conf.tmpl: ~29 references

**Minor** (<10 references):
- wofi/style.css.tmpl: ~8 references
- niri/config.kdl.tmpl: ~5 references
- (zsh: no direct color references — robbyrussell uses terminal ANSI palette)

### Estimated Effort
- Spectrum system: 2-3 hours (complex algorithm)
- Semantic architecture: 1 hour (YAML structure)
- Config migrations: 4-6 hours (methodical per-file work)
- Testing & documentation: 1-2 hours

**Total**: ~8-12 hours of focused work

---

## Success Criteria

✅ **Separation of Concerns**
- Semantic system handles meanings (error, success, focus)
- Spectrum system handles aesthetics (rainbow progressions)
- No confusion between the two

✅ **Zero Direct References**
- No `$c.red`, `$c.green` in configs
- No hardcoded hex colors (except in colors.yaml)
- All configs use `$semantic.category.purpose`

✅ **Flexibility**
- Waybar modules can be added/removed without breaking spectrum
- Theme can be changed by updating semantic mappings only
- Spectrum endpoints can be adjusted for different aesthetics

✅ **Documentation**
- Each semantic category has clear purpose statement
- Usage examples for ambiguous cases
- CLAUDE.md updated with architecture overview

✅ **Testing**
- All apps visually verified post-migration
- `chezmoi diff` shows valid syntax
- Git history shows incremental, tested commits

---

## Future Enhancements

### Potential Additions

**1. Multiple Spectrum Presets**
```yaml
spectrum:
  rainbow: ["red", "orange", "yellow", "green", "cyan", "blue", "violet"]
  warm: ["red", "orange", "yellow", "pink"]
  cool: ["cyan", "blue", "violet", "magenta"]
```

**2. Alternative Interpolation Methods**
- LAB color space (even more perceptual)
- Bezier curves for non-linear progressions
- Clamped lightness for accessibility

**3. Semantic Color Variants**
```yaml
state:
  error:
    default: "red"
    subtle: "red" at 50% opacity
    emphasis: "bright_red"
```

**4. Dark/Light Theme Support**
```yaml
semantic_colors:
  light_theme:
    surface:
      primary: "white"
  dark_theme:
    surface:
      primary: "bg_dark"
```

---

## Appendix: Color Theory

### Why HSV for Spectrum Interpolation?

**HSV (Hue, Saturation, Value)**:
- **Hue**: Position on color wheel (0-360°)
- **Saturation**: Color intensity (0-100%)
- **Value**: Brightness (0-100%)

**Benefits**:
- Interpolating Hue creates smooth color transitions
- Maintains perceptual evenness
- Matches how humans perceive color progression

**Alternative: RGB Interpolation** (worse)
- Produces muddy intermediate colors
- Non-uniform perceptual spacing
- Red → Blue via RGB goes through brown!

### Accessibility Note

All semantic colors maintain WCAG AA contrast ratios against appropriate backgrounds. The spectrum system is purely aesthetic and should not be used for semantic communication where contrast matters.

---

## Related Documentation

- **KEYBINDINGS.md** - Semantic keybinding system (parallel architecture)
- **color-usage-audit.md** - Detailed audit findings (temporary)
- **CLAUDE.md** - Main project documentation

---

*"Two rivers, two paths. The meaning flows one way, the beauty another. Do not force them to become one stream."* - The Master