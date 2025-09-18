# ADR-001: Fish Shell Over Zsh/Bash

Date: 2024-09-13

## Context
Needed a modern shell with excellent defaults and minimal configuration requirements for the new dotfiles setup.

## Decision
Chose Fish shell as the default interactive shell.

## Why
- Out-of-box features: autosuggestions, syntax highlighting, web-based config
- Sane scripting language without bash's arcane syntax
- Universal variables eliminate complex dotfile management for shell state

## Consequences
- Non-POSIX scripts require explicit shebang or separate bash scripts
- Smaller ecosystem of plugins compared to Zsh
- Need to use `dots` function instead of alias for bare git repo