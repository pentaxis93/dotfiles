# Fortune with Zen Quotes

## Ultra-Zen Philosophy
**"Wisdom flows through the terminal; each command begins with contemplation"**

## Architecture
- **Fortune-Mod** - BSD fortune cookie program for displaying random quotations
- **Zen Database** - Hand-crafted high-quality collection of Zen and Buddhist wisdom quotes
- **Git-Managed** - Fortune databases tracked in dotfiles repository
- **User-Local** - Installed to `~/.local/share/fortune/` (no system-wide changes)
- **Optional Greeting** - Can display wisdom on terminal startup via zsh prompt hook

## Configuration Files
- **Package**: `home/.chezmoidata/packages.yaml` - Declaratively managed fortune-mod
- **Database**: `home/dot_local/share/fortune/Zen_en` - Zen quotes fortune database (271 quotes)
- **Index Generator**: `home/run_once_generate-fortune-index.sh.tmpl` - Creates .dat indexes locally
- **PATH Wrapper**: `home/dot_local/bin/executable_fortune` - Universal wrapper script (works everywhere)
- **Zsh Greeting** (optional): `home/dot_zshrc.tmpl` - Terminal startup integration
- **Ignore Rule**: `.chezmoiignore` - Excludes generated .dat files from chezmoi management

## Usage

The PATH wrapper script (`~/.local/bin/fortune`) intercepts all fortune invocations:

```bash
fortune                    # Zen_en quote (default)
fortune Zen_en             # Zen_en quote (explicit)
fortune fortunes           # System fortunes database
fortune -a                 # Show all databases (passed through)
fortune -s                 # Short quotes from Zen_en
/usr/bin/fortune           # Bypass wrapper (use system fortune directly)
```

### How the PATH Wrapper Works

Since `~/.local/bin` precedes `/usr/bin` in PATH, the wrapper script intercepts all `fortune` commands:

**No arguments** → Defaults to `Zen_en` for contemplative wisdom
**Any arguments** → Passes through to `/usr/bin/fortune` unchanged
**Works everywhere** → Zsh, bash, scripts, systemd, cron

This universal approach means:
- Interactive shells get Zen by default
- Scripts calling `fortune` get Zen by default
- All fortune options work unchanged (`-a`, `-l`, `-s`, `-m pattern`, etc.)
- Users can bypass with `/usr/bin/fortune` if needed

### Fortune Index Generation

Fortune databases require binary `.dat` index files for random access. These indexes are:
- **Platform-specific** (endianness, data structures)
- **Version-specific** (fortune-mod format changes)
- **Generated locally** via `strfile` utility

**Why not track .dat in git?**
Binary indexes from other systems are incompatible and cause corrupted output. The `run_once_generate-fortune-index.sh` script ensures indexes match your system.

**Automatic generation:**
```bash
chezmoi apply  # Deploys Zen_en + runs strfile automatically
```

The script runs once and regenerates if the text file changes.

## Sample Quotes

Watch how wisdom manifests through these curated teachings:

**On Mindfulness:**
> "Basically, being aware in the present moment is the only game in town, and if we miss this moment it will be gone forever."
> — Jack Kornfield

**On Non-Attachment:**
> "Leave your front and back door open. Allow your thoughts to come and go. Just don't serve them tea."
> — Shunryu Suzuki

**On Observation:**
> "Be the witness of your thoughts. You are what observes, not what you observe."
> — Buddhist proverb

**On Impermanence:**
> "Everything passes, nothing remains. Understand this, loosen your grip, and find serenity."
> — Lama Surya Das

**On Simplicity:**
> "To a mind that is still the whole universe surrenders."
> — Lao Tzu

## Database Details

### Zen_en Database
- **Source**: https://github.com/bitmagier/fortune-mod-zen
- **Quote Count**: 271 curated quotations
- **Authors**: Buddha, Lao Tzu, Shunryu Suzuki, Pema Chödrön, Thich Nhat Hanh, Alan Watts, and many more
- **Themes**: Mindfulness, non-attachment, meditation, suffering, impermanence, awareness, presence
- **License**: CC0-1.0 (Public Domain)

### Quote Format
Quotes are separated by `%` delimiter and include attribution:
```
Quote text here, potentially multi-line.
                — Attribution
%
Next quote...
```

## Optional Zsh Greeting Integration

To display zen wisdom on every new terminal session, add the following to `dot_zshrc.tmpl`:

```zsh
# Display zen wisdom on shell startup
if [[ -o interactive ]]; then
    fortune Zen_en
    echo ""  # Add spacing after quote
fi
```

This follows the philosophy: **"Each shell begins with wisdom"**

## Benefits

- **Contemplative Terminal** - Start each session with mindful wisdom
- **Zero Maintenance** - Git-tracked databases deploy automatically via chezmoi
- **Standard Command** - Everyone already knows `fortune`
- **User-Local Installation** - No root privileges or system modifications needed
- **YAGNI Focused** - Simple text files, no complex infrastructure
- **Extensible** - Easy to add more fortune databases in the future

## Alternative Usage Patterns

### Random Zen Alias
Create a simple alias in `aliases.zsh.tmpl` for convenience:
```zsh
alias zen='fortune Zen_en'
```

### Multiple Databases
If you add more fortune databases, you can select from them randomly:
```bash
fortune 50% Zen_en 50% other_database  # 50/50 chance between databases
fortune Zen_en other_database          # Equal weight to all listed
```

### Fortune in MOTD
For system-wide wisdom (requires root), add to `/etc/motd`:
```bash
#!/bin/sh
fortune ~/.local/share/fortune/Zen_en
```

## YAGNI Principles Applied

- ✅ **Git-tracked databases** - Text files only, no binaries
- ✅ **Generated indexes** - Built locally for guaranteed compatibility
- ✅ **User-local installation** - No system-wide changes
- ✅ **English only** - German available in upstream if needed
- ✅ **PATH wrapper** - Universal solution (works in all shells and scripts)
- ✅ **Single implementation** - One wrapper, not shell-specific functions
- ✅ **Optional greeting** - User can enable if desired
- ✅ **Self-maintaining** - run_once script handles generation

---

*"Just remain in the center; watching. And then forget that you are there."* — Lao Tzu, Tao Te Ching
