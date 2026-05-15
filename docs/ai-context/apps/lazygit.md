# Lazygit - Git TUI

## Architecture
- **Reverse Video Philosophy** - Selections use terminal fg/bg swap for perfect contrast
- **Kanagawa Theme** - Active borders use semantic focus green (color2)
- **Vi Navigation** - Full vi keybindings for all operations
- **Visual Branch Management** - Interactive rebasing, cherry-picking, branch switching

## Configuration
- **File**: `home/dot_config/lazygit/config.yml` - Custom theme following our philosophy
- **Zsh Integration**: `lg` alias launches lazygit

## Semantic Colors
- Active borders: Green (focus/ready)
- Search borders: Cyan (discovery)
- Options text: Blue (information)
- Selections: Reverse video (Master's wisdom - perfect contrast always)

## Usage
```bash
lg    # Launch lazygit in current git repository
```

### Key Operations
- hjkl navigation throughout
- Space to stage/unstage files
- c to commit, P to push/pull
- b to checkout branches
- Full interactive rebasing support
- Cherry-picking and branch management