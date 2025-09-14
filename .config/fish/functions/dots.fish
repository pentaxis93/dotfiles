function dots --description 'Manage dotfiles with git bare repo'
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
end