# ADR-003: Gruvbox Dark Hard Theme

Date: 2024-09-13

## Context
Need consistent color scheme across terminal, editor, window manager, and all tools for visual coherence.

## Decision
Standardized on Gruvbox Dark Hard variant with custom cyan accent hierarchy.

## Why
- Warm, earthy colors reduce eye strain during long sessions
- Excellent contrast with dark hard variant (#1d2021 background)
- Wide tool support: available for virtually every application
- Distinctive greenish-aqua creates unique visual identity

## Consequences
- Aqua colors (#8ec07c, #689d6a) lean green by design
- Must maintain custom CSS overrides for GTK apps
- Some tools need manual color configuration