# ADR-004: Tmux Tabs-Only (No Panes)

Date: 2024-09-14

## Context
BSPWM provides window tiling, tmux provides terminal multiplexing. Having both create splits causes navigation confusion.

## Decision
Disabled tmux panes entirely. BSPWM handles all window splitting, tmux only manages terminal tabs.

## Why
- Clear mental model: one tool per responsibility
- Consistent navigation: Super+hjkl always navigates windows
- Eliminates "am I in tmux or BSPWM?" confusion
- Simpler keybindings without collision concerns

## Consequences
- Cannot use tmux's powerful pane features (synchronize-panes, layouts)
- Cannot have terminal splits within a single BSPWM tile
- Alt+Shift+hjkl reserved exclusively for tab navigation