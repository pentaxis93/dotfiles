function lazydots --description 'Open lazygit for dotfiles bare repo'
    lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
end