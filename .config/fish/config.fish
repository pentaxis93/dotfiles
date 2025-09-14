source /usr/share/cachyos-fish-config/cachyos-config.fish

# Simple greeting instead of fastfetch
function fish_greeting
    echo "Welcome to" (set_color cyan)"CachyOS"(set_color normal) "with" (set_color yellow)"fish"(set_color normal) "shell!"
    echo "Type" (set_color green)"help"(set_color normal) "for instructions on how to use fish"
end

# Initialize starship prompt (if installed)
if type -q starship
    starship init fish | source
end

# Set default editor (will change to nvim later)
set -gx EDITOR vim
set -gx VISUAL vim

# Enable vi mode for command line editing
fish_vi_key_bindings

# FZF integration (if installed)
if type -q fzf
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --info=inline'
end

# Git abbreviations
abbr -a g git
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gp 'git push'
abbr -a gpl 'git pull'
abbr -a gst 'git status'
abbr -a gd 'git diff'
abbr -a gco 'git checkout'
abbr -a gb 'git branch'
abbr -a glog 'git log --oneline --graph --decorate'

# Dotfiles management abbreviations
abbr -a da 'dots add'
abbr -a dc 'dots commit'
abbr -a dp 'dots push'
abbr -a dst 'dots status'
abbr -a dd 'dots diff'

# System management abbreviations
abbr -a syu 'sudo pacman -Syu'
abbr -a install 'sudo pacman -S'
abbr -a search 'pacman -Ss'
abbr -a remove 'sudo pacman -Rns'
abbr -a orphans 'pacman -Qtdq'

# Directory navigation shortcuts
abbr -a config 'cd ~/.config'
abbr -a downloads 'cd ~/Downloads'
abbr -a documents 'cd ~/Documents'
abbr -a dotfiles 'cd ~/.dotfiles'

# Editor shortcuts (will update when nvim is installed)
abbr -a v vim
abbr -a sv 'sudo vim'

# Quick config edits
abbr -a fishconfig 'vim ~/.config/fish/config.fish'
abbr -a bspconfig 'vim ~/.config/bspwm/bspwmrc'
abbr -a sxhkdconfig 'vim ~/.config/sxhkd/sxhkdrc'
abbr -a polybarconfig 'vim ~/.config/polybar/config.ini'

# Load any local machine-specific configurations
if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end