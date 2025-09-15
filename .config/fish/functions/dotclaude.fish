function dotclaude --description "Launch Claude Code for dotfiles management"
    # Change to dotfiles workspace where CLAUDE.md lives
    cd ~/.config/dotfiles

    # Launch Claude Code with any passed arguments
    # CLAUDE.md will be discovered here, not in home directory
    claude code $argv
end