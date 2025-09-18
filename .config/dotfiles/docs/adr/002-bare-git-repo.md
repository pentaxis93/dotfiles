# ADR-002: Bare Git Repository Pattern

Date: 2024-09-13

## Context
Managing dotfiles across machines requires version control without turning $HOME into a git repository.

## Decision
Use a bare git repository with $HOME as the work-tree.

## Why
- No symlink management or installation step required
- Edit files directly in their natural locations
- Simple disaster recovery: clone and checkout
- Clean git status by default (untracked files ignored)

## Consequences
- Need special git command: `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME`
- Requires `dots` function/alias for convenience
- Must explicitly add files to track them