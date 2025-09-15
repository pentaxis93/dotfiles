# Papirus Gruvbox Aqua Folder Icons

These are customized Papirus folder icons with Gruvbox aqua colors.

## Color Modifications

Original Papirus teal colors have been replaced with Gruvbox aqua:
- **Main color**: `#16a085` → `#8ec07c` (bright aqua)
- **Dark shade**: `#12806a` → `#689d6a` (regular aqua)

## Why Custom Icons?

The standard Papirus folder colors (cyan, teal, etc.) are too saturated and clash with our Gruvbox theme. These modified icons use the same greenish-cyan "aqua" colors from the Gruvbox palette, creating perfect visual harmony across the system.

## Installation

These SVGs are automatically applied by the `~/.local/bin/papirus-gruvbox-folders` script.

To manually install:
```bash
# Copy to system icons (requires sudo)
sudo cp -r * /usr/share/icons/Papirus/
sudo gtk-update-icon-cache -f /usr/share/icons/Papirus
```

## Sizes Included

- 16x16 - Small icons (list views)
- 22x22 - Panel/toolbar icons
- 24x24 - Standard toolbar size
- 32x32 - Medium icons
- 48x48 - Large icons
- 64x64 - Extra large icons

Each size contains the modified `folder-teal.svg` which is symlinked as the default folder icon.

## Color Reference

These colors match our system-wide Gruvbox Dark Hard theme:
- `#8ec07c` - Bright aqua (active/focused elements)
- `#689d6a` - Regular aqua (secondary/depth elements)

The greenish tint is intentional - it creates a warmer, more organic feel compared to pure cyan.