# 🧭 Ultra-Zen Semantic Keybindings Reference

> "Do not memorize keys; understand intentions. The fingers will follow."

## Philosophy: Intentions Manifest as Keys

Our keybinding system is **semantic**, not physical. You learn **intentions** once, and they manifest appropriately in each context:
- **Navigate** in niri → focus windows
- **Navigate** in fish → move cursor
- **Navigate** in qutebrowser → scroll page
- **Navigate** in mpv → seek through video

This creates **universal muscle memory** based on Helix editor's thoughtful semantics.

## 🎯 Quick Start: Essential Patterns

```
Universal Navigation:  h j k l  (←↓↑→)
File/Buffer Jumps:     gg = top, ge = end (NOT G!)
Line Navigation:       gh = home, gl = line end
Universal Search:      / = forward, ? = backward, n/N = next/prev
Universal Exit:        ESC or q
MOD Keys:             Super (left hand), PrtSc (right hand)
```

## Core Semantic Actions

### 🧩 Navigate - Moving Focus Without Changing State
**Mnemonic**: "Where you look changes, what exists doesn't"

#### Cardinal Navigation (Universal hjkl)
- `h` - **Left** (◀ think "**h**ome" side of keyboard)
- `j` - **Down** (↓ **j** droops down)
- `k` - **Up** (↑ **k** kicks up)
- `l` - **Right** (▶ think "**l**ast" side of keyboard)

#### Jump Navigation (Helix-Native)
- `gg` - **Go to top** ("**g**o **g**et genesis")
- `ge` - **Go to end** ("**g**o **e**nd" - Helix improvement over vim's G)
- `gh` - **Go home** (line start - "**g**o **h**ome")
- `gl` - **Go line end** ("**g**o **l**ine's last")

#### Word Navigation
- `w` - **Word next** ("**w**ord")
- `b` - **Back word** ("**b**ack")
- `e` - **End of word** ("**e**nd")

| Intention | Universal Key | Niri (WM) | Helix (Editor) | Fish (Shell) | Qutebrowser | MPV |
|-----------|---------------|-----------|----------------|--------------|-------------|-----|
| `navigate.prev` | `h` | Focus left window | Move cursor left | Move cursor left | Scroll left | Seek -5s |
| `navigate.next` | `l` | Focus right window | Move cursor right | Move cursor right | Scroll right | Seek +5s |
| `navigate.up` | `k` | Focus upper window | Move line up | Previous command | Scroll up | Seek +60s |
| `navigate.down` | `j` | Focus lower window | Move line down | Next command | Scroll down | Seek -60s |
| `navigate.line_start` | `gh` | - | Go to line start | Beginning of line | Scroll 0% | Seek 0% |
| `navigate.line_end` | `gl` | - | Go to line end | End of line | Scroll 100% | Seek 100% |
| `navigate.file_start` | `gg` | - | Go to first line | Beginning of buffer | Scroll to top | Seek to start |
| `navigate.file_end` | `ge` | - | **Go to last line** | End of buffer | Scroll to bottom | Seek to end |

**Note**: We follow Helix's semantic `ge` (go end) instead of Vim's `G` for consistency.

### 🔧 Manipulate - Move Objects
**Mnemonic**: "Ctrl = Control the object's position"

| Intention | Key Pattern | Context | Action |
|-----------|-------------|---------|--------|
| `manipulate.move` | `MOD+CTRL+hjkl` | Niri | Move window in direction |
| `manipulate.resize` | `MOD+-/=` | Niri | Decrease/increase size |
| `manipulate.resize` | `+/-` | MPV, Qutebrowser | Zoom in/out, volume adjust |
| `manipulate.transfer` | `MOD+CTRL+[1-9]` | Niri | Move to workspace N |

### 🚀 Invoke - Launch/Create
**Mnemonic**: "Summon into existence"

| Intention | Key | Context | Launches |
|-----------|-----|---------|----------|
| `invoke.terminal` | `MOD+RETURN` | Niri | Alacritty terminal |
| `invoke.launcher` | `MOD+SPACE` | Niri | Application launcher (wofi) |
| `invoke.browser` | `MOD+B` | Niri | Qutebrowser |
| `invoke.files` | `MOD+E` | Niri | File manager |
| `invoke.editor` | `h` | Shell | Helix editor (alias) |

### 🔄 Transform - Toggle States/Modes
**Mnemonic**: "Shape-shift what's already there"

| Intention | Key | Context | Transformation |
|-----------|-----|---------|----------------|
| `transform.mode` | `ESC/i/v` | Editor/Shell | Normal/Insert/Visual mode |
| `transform.fullscreen` | `MOD+F` | Niri | Toggle fullscreen |
| `transform.fullscreen` | `f` | MPV, Qutebrowser hints | Toggle fullscreen |
| `transform.floating` | `MOD+SHIFT+F` | Niri | Toggle floating/tiled |
| `transform.tabbed` | `MOD+T` | Niri | Toggle window tabs |

### 💾 Preserve - Persist State
**Mnemonic**: "Save for later"

| Intention | Key | Context | Saves |
|-----------|-----|---------|-------|
| `preserve.current` | `SPACE+w` | Helix | Write current file |
| `preserve.current` | `:w` | Qutebrowser | Save session |
| `preserve.current` | `s` | MPV | Screenshot |
| `preserve.current` | `q` | MPV | Quit and save position |
| `preserve.all` | `SPACE+W` | Helix | Write all files |

### ❌ Dismiss - Close/Quit
**Mnemonic**: "Make it go away"

| Intention | Key | Context | Action |
|-----------|-----|---------|--------|
| `dismiss.current` | `MOD+Q` | Niri | Close window |
| `dismiss.current` | `SPACE+q` | Helix | Quit editor |
| `dismiss.current` | `q` | Qutebrowser, LF, Lazygit | Close tab/quit |
| `dismiss.current` | `q` | MPV | Quit and save position |
| `dismiss.force` | `Q` | Qutebrowser, MPV | Force quit |
| `dismiss.cancel` | `ESC` | Universal | Cancel operation |

### 🔍 Discover - Reveal Information
**Mnemonic**: "Find what's hidden"

| Intention | Key | Context | Shows |
|-----------|-----|---------|-------|
| `discover.search_forward` | `/` | Editor/Shell/Browser | Search forward |
| `discover.search_backward` | `?` | Editor/Shell/Browser | Search backward |
| `discover.find_char` | `f` | Helix | Find character |
| `discover.find_char` | `f` | Qutebrowser | Follow link (hints) |
| `discover.find_char` | `f` | LF | Filter files |
| `discover.help` | `MOD+SHIFT+ESC` | Niri | Hotkey overlay |
| `discover.help` | `?` | MPV | Show statistics |

### ✅ Select - Choose/Activate
**Mnemonic**: "Mark for action"

| Intention | Key | Context | Selects |
|-----------|-----|---------|---------|
| `select.toggle` | `x` | Helix, Fish | Extend selection |
| `select.toggle` | `x` | LF | Toggle file selection |
| `select.toggle` | `SPACE` | MPV | Play/pause |
| `select.toggle` | `SPACE` | Lazygit | Stage/unstage |
| `select.all` | `%` | Helix | Select all |
| `select.all` | `A` | LF | Select all files |

## Application-Specific Quick References

### Niri Window Manager
**MOD Keys**: `Super` (left hand) or `PrtSc` (right hand - via keyd)

```
╭─────────────── FOCUS ──────────────╮
│ MOD+H/L     Focus left/right       │
│ MOD+J/K     Focus up/down          │
│ MOD+TAB     Next workspace         │
│ MOD+1-9     Go to workspace N      │
│                                    │
│ Monitor Navigation:                │
│ MOD+;/'     Focus left/right mon   │
│ MOD+SHIFT+H/L Focus monitors (alt) │
╰─────────────────────────────────────╯

╭─────────────── TRANSFORM ──────────╮
│ MOD+F       Fullscreen             │
│ MOD+T       Tabbed display         │
│ MOD+SHIFT+F Floating               │
│ MOD+W       Width toggle (50%/100%)│
╰─────────────────────────────────────╯

╭─────────────── MANIPULATE ─────────╮
│ MOD+CTRL+H/L  Move column          │
│ MOD+CTRL+J/K  Move window          │
│ MOD+CTRL+1-9  Move to workspace N  │
│ MOD+SHIFT+-/= Resize height        │
│                                    │
│ Move to Monitor:                   │
│ MOD+CTRL+;/'  Move to left/right   │
│ MOD+SHIFT+CTRL+H/L  (alternative)  │
╰─────────────────────────────────────╯

╭─────────────── INVOKE ─────────────╮
│ MOD+RETURN  Terminal (Alacritty)   │
│ MOD+SPACE   Launcher (wofi)        │
│ MOD+B       Browser (qutebrowser)  │
│ MOD+E       File manager           │
│ MOD+Q       Close window           │
╰─────────────────────────────────────╯
```

### Qutebrowser Web Browser

```
╭─────────────── NAVIGATION ─────────╮
│ h/j/k/l     Scroll left/down/up/right│
│ d/u         Half-page down/up      │
│ gg/ge       Top/bottom (Helix ge!) │
│ gh/gl       Scroll 0%/100%         │
│ H/L         History back/forward   │
╰─────────────────────────────────────╯

╭─────────────── TABS ───────────────╮
│ J/K         Previous/next tab      │
│ gT/gt       Alternative tab nav    │
│ gc          Close tab              │
│ q           Close tab              │
│ Q           Quit browser           │
╰─────────────────────────────────────╯

╭─────────────── HINTS ──────────────╮
│ f           Follow link (cur tab)  │
│ F           Follow link (bg tab)   │
│ ;y          Yank link URL          │
╰─────────────────────────────────────╯

╭─────────────── SEARCH ─────────────╮
│ /           Search forward         │
│ ?           Search backward        │
│ n/N         Next/prev match        │
╰─────────────────────────────────────╯

╭─────────────── YANK ───────────────╮
│ yy          Yank URL               │
│ yt          Yank title             │
│ yd          Yank domain            │
│ yp          Yank pretty URL        │
╰─────────────────────────────────────╯

╭─────────────── CUSTOM ─────────────╮
│ ,m          Play with MPV          │
│ ,M          Play hinted link       │
│ ,r          Reload                 │
│ ,R          Force reload           │
│ ,p          Open private window    │
╰─────────────────────────────────────╯
```

### MPV Media Player

```
╭─────────────── NAVIGATION ─────────╮
│ h/l         Seek -5s/+5s           │
│ j/k         Seek -60s/+60s         │
│ H/L         Seek -10s/+10s         │
│ J/K         Playlist prev/next     │
│ gg/ge       Start/end (Helix ge!)  │
│ gh/gl       Absolute 0%/100%       │
│ w/b         Next/prev chapter      │
╰─────────────────────────────────────╯

╭─────────────── MANIPULATION ───────╮
│ Ctrl+h/l    Speed down/up          │
│ Ctrl+j/k    Volume down/up         │
│ +/-         Volume adjust          │
│ =           Reset speed to 1.0     │
│ 0           Reset volume to 100    │
╰─────────────────────────────────────╯

╭─────────────── TRANSFORM ──────────╮
│ f           Fullscreen             │
│ i           Show filename (info)   │
│ v           Toggle subtitles       │
│ V           Toggle 2nd subtitles   │
│ m           Mute                   │
│ t           Always on top          │
│ SPACE       Play/pause             │
╰─────────────────────────────────────╯

╭─────────────── SUBTITLES ──────────╮
│ s/S         Cycle subs fwd/back    │
│ z/x         Timing earlier/later   │
│ Alt+j/k     Position down/up       │
│ Alt++/-     Size increase/decrease │
│ Alt+b/i     Bold/italic toggle     │
╰─────────────────────────────────────╯

╭─────────────── PRESERVE ───────────╮
│ s           Screenshot             │
│ S           Screenshot (no subs)   │
│ Ctrl+s      Save position manually │
│ q           Quit and save position │
╰─────────────────────────────────────╯

╭─────────────── DISCOVER ───────────╮
│ /           Console (search)       │
│ ?           Show statistics        │
│ b           Browse with lf         │
│ Tab         Toggle stats display   │
╰─────────────────────────────────────╯
```

### LF File Manager

```
╭─────────────── NAVIGATION ─────────╮
│ h           Parent directory       │
│ l           Open file/enter dir    │
│ j/k         Down/up in list        │
│ gg/ge       Top/bottom (Helix ge!) │
│ Ctrl+u/d    Half-page up/down      │
╰─────────────────────────────────────╯

╭─────────────── SELECTION ──────────╮
│ x           Toggle file selection  │
│ X           Unselect all           │
│ Space+x     Invert selection       │
│ V           Visual selection mode  │
│ A           Select all files       │
╰─────────────────────────────────────╯

╭─────────────── FILE OPS ───────────╮
│ .           Toggle hidden files    │
│ r           Reload                 │
│ Enter       Shell command          │
│ a           Add file (touch)       │
│ A           Add directory (mkdir)  │
│ R           Rename                 │
│ B           Bulk rename            │
│ D           Delete (confirm)       │
│ T           Move to trash          │
╰─────────────────────────────────────╯

╭─────────────── FILE ACTIONS ───────╮
│ l           Open with default app  │
│ L           Choose app (wofi menu) │
│ W           Copy paths to clipboard│
╰─────────────────────────────────────╯

╭─────────────── SEARCH ─────────────╮
│ /           Search forward         │
│ ?           Search backward        │
│ n/N         Next/prev match        │
│ f           Filter files           │
╰─────────────────────────────────────╯

╭─────────────── BOOKMARKS ──────────╮
│ gc          ~/.config              │
│ gd          ~/Downloads            │
│ gv          ~/Videos               │
│ gm          ~/Music                │
│ g.          ~/.local/share/chezmoi │
╰─────────────────────────────────────╯
```

### Fish Shell (Vi Mode)
**Mode Indicators**: `[N]` Normal (green), `[I]` Insert (blue), `[V]` Visual (yellow)

```
╭─────────────── NAVIGATION ─────────╮
│ h/j/k/l     Cursor left/prev/next/right│
│ w/b/e       Word next/prev/end     │
│ gh/gl       Line start/end (Helix!)│
│ /           Search history         │
│ ?           Reverse search history │
│ k/j         Previous/next in search│
╰─────────────────────────────────────╯

╭─────────────── COMPLETION ─────────╮
│ Tab         Accept suggestion      │
│ Ctrl+F      Accept full (Fish way) │
╰─────────────────────────────────────╯

╭─────────────── MODES ──────────────╮
│ ESC         Enter normal mode      │
│ i           Enter insert mode      │
│ v or x      Enter visual mode      │
╰─────────────────────────────────────╯

╭─────────────── FILE BROWSER ───────╮
│ Ctrl+O      Launch lf (cd on exit) │
╰─────────────────────────────────────╯
```

### Alacritty Terminal (Vi Mode)
**Toggle Vi Mode**: `Ctrl+Shift+Space`

```
╭─────────────── SCROLLBACK ─────────╮
│ gg          Top of history         │
│ Shift+E     Bottom (Helix ge!)     │
│ Shift+G     Bottom (traditional)   │
│ Ctrl+U/D    Half-page up/down      │
│ j/k         Line down/up           │
╰─────────────────────────────────────╯

╭─────────────── SEARCH ─────────────╮
│ /           Search forward         │
│ ?           Search backward        │
│ n/N         Next/prev match        │
╰─────────────────────────────────────╯

╭─────────────── SELECTION ──────────╮
│ v           Visual selection       │
│ y           Yank to clipboard      │
│ ESC         Exit vi mode           │
╰─────────────────────────────────────╯
```

### Lazygit TUI

```
╭─────────────── NAVIGATION ─────────╮
│ h/j/k/l     Panel/file navigation  │
│ gg          Top of list            │
│ G           Bottom (traditional)   │
│ [/]         Previous/next tab      │
╰─────────────────────────────────────╯

╭─────────────── GIT OPS ────────────╮
│ Space       Stage/unstage toggle   │
│ c           Commit                 │
│ P           Push                   │
│ p           Pull                   │
│ b           Checkout branch        │
│ n           New branch             │
╰─────────────────────────────────────╯

╭─────────────── SELECTION ──────────╮
│ a           Stage all              │
│ d           Discard changes        │
│ e           Edit file              │
│ o           Open file              │
╰─────────────────────────────────────╯

╭─────────────── DISMISS ────────────╮
│ q           Quit                   │
│ ESC         Cancel/back            │
╰─────────────────────────────────────╯
```

### Wiremix Audio Mixer

```
╭─────────────── NAVIGATION ─────────╮
│ h/j/k/l     Navigate UI            │
│ gg/ge       Top/bottom (Helix!)    │
│ 1-5         Quick tab switching    │
╰─────────────────────────────────────╯

╭─────────────── VOLUME ─────────────╮
│ Shift+0     Mute (0%)              │
│ Shift+5     Set to 50%             │
│ Shift+0     Set to 100% (double 0) │
╰─────────────────────────────────────╯

╭─────────────── DISMISS ────────────╮
│ q or ESC    Quit mixer             │
╰─────────────────────────────────────╯
```

## Modifier Patterns

### System-Wide Consistency

- **`MOD`** (Super/Win): Window manager operations
- **`SPACE`**: Editor leader key
- **`CTRL`**: Terminal/shell operations
- **`SHIFT`**: Extend/modify action
- **`ALT`**: Alternative action

### Contextual Modifiers

| Context | Primary | Manipulate | System |
|---------|---------|------------|--------|
| Niri (WM) | `MOD` | `MOD+CTRL` | `CTRL+ALT` |
| Helix | `SPACE` (leader) | `g` (goto) | `z` (view) |
| Alacritty | `CTRL` | `CTRL+SHIFT` | `ALT` |
| Fish | None (normal mode) | `CTRL` | `ALT` |

## Vi Mode Everywhere

### Enabled Vi Modes

- **Fish Shell**: Vi mode with Helix-native keybindings
  - Mode indicator: `[N]` (green), `[I]` (blue), `[V]` (yellow)
  - Cursor changes: Block (normal), Line (insert), Underscore (visual)

- **Alacritty Terminal**: Vi mode with visual feedback
  - Toggle: `CTRL+SHIFT+SPACE`
  - Vi cursor: Green block when active
  - Supports Helix `ge` for end navigation

- **Helix Editor**: Native modal editing (already perfect)

### Mode Indicators

All modes use semantic colors from our Kanagawa Dragon palette:

| Mode | Color | Semantic Meaning |
|------|-------|------------------|
| Normal | Green (`focus`) | Ready for action |
| Insert | Blue (`info`) | Accepting input |
| Visual | Yellow (`warning`) | Selection active |
| Replace | Red (`error`) | Destructive change |

## Helix-Native Philosophy

We embrace Helix's thoughtful semantic improvements:

- **`ge`** instead of `G`: "Go end" is semantically clearer than arbitrary `G`
- **`gh/gl`** for line navigation: "Go home/line-end" is more intuitive
- **`x`** for extend: Direct selection extension without mode change
- **Goto mode (`g` prefix)**: Groups all "go to" operations semantically

## Conflict Resolution

### Intentional Context-Dependent Meanings

These keys have different meanings in different contexts **by design**:

#### 'h' Key
- **Navigate Prev**: Window/column left (niri), cursor left (helix), scroll left (qutebrowser), seek back (mpv), parent dir (lf)
- **Invoke Editor**: Alias for helix (fish: `h="helix"`)
- **Resolution**: Context makes meaning clear - no actual conflict

#### 'l' Key
- **Navigate Next**: Right/forward in most contexts
- **Open**: In lf, 'l' opens files/directories (selection + invocation)
- **Resolution**: In file managers, "open" IS the next action

#### 'f' Key
- **Transform Fullscreen**: Niri, MPV
- **Discover Find**: Helix (find character), Qutebrowser (hints), LF (filter)
- **Resolution**: Context-appropriate - all valid semantic uses

#### 'x' Key
- **Transform Extend**: Helix, Fish (extend selection)
- **Select Toggle**: LF (toggle file selection)
- **Resolution**: Both are selection-related - semantic alignment

#### 'Space' Key
- **Invoke Launcher**: Niri (MOD+SPACE)
- **Preserve Leader**: Helix (SPACE for commands)
- **Select Toggle**: MPV (play/pause), Lazygit (stage)
- **Resolution**: Modifier (MOD) or context distinguishes usage

### Minor Inconsistencies

#### 'G' vs 'ge'
- **Helix-Native**: Uses 'ge' for "go end" (semantic clarity)
- **Vim Traditional**: Uses 'G' for end
- **Current Status**: Most configs support BOTH for transition
- **Exception**: Lazygit still uses G (not migrated)

## Benefits

1. **Muscle Memory Unity**: Same intention = same key everywhere
2. **Discoverability**: Actions named by intention, not key
3. **No Conflicts**: Semantic layer prevents overlaps
4. **Self-Documenting**: Intention names explain themselves
5. **Extensibility**: New apps inherit the pattern

## 🎓 Learning Path

### Week 1: Universal Foundation
1. **Master hjkl** everywhere - this is 80% of navigation
2. **Learn gg/ge** for file jumps (forget vim's G!)
3. **Use ESC** to exit everything

### Week 2: Semantic Patterns
1. **MOD+[Letter]** for window operations (F/T/W)
2. **gh/gl** for line navigation in editing
3. **Search with /** in vi modes

### Week 3: Power Features
1. **MOD+W** for instant window sizing
2. **PrtSc as MOD** for right-hand efficiency
3. **Word navigation** with w/b/e

### Week 4: Full Fluency
1. **Tab management** with MOD+T
2. **Workspace flow** with MOD+TAB
3. **Visual selection** and copying

## 🔧 Troubleshooting

### "Why doesn't G go to bottom?"
We use Helix's semantic `ge` (go end). G is inconsistent across contexts. Train the better pattern!

### "Why MOD+TAB for workspaces, not MOD+W?"
Convention wins here - MOD+TAB is universal across window managers. MOD+W is our width toggle.

### "Why remove gg/ge from Fish?"
Buffer navigation (jumping to first/last command) isn't useful in shells. We keep what matters.

### "Why Ctrl+F for Fish completion?"
Respects Fish's native convention while Tab remains the primary method. Native sovereignty principle.

## 🧘 The Way Forward

> "The novice memorizes keybindings.
> The adept learns patterns.
> The master embodies intentions."

Our semantic system means you're not learning nine different apps - you're learning one language that speaks everywhere. Trust the patterns, and your fingers will find the way.

---

## Further Reading

- **Technical Documentation**: See `keybinding-usage-audit.md` for complete implementation audit
- **Implementation**: See `home/.chezmoidata/keybindings.yaml` for semantic definitions
- **Templates**: See `home/.chezmoitemplates/keybind-*.tmpl` for template system

*Philosophy: Helix-native, semantically pure, ergonomically sound*
