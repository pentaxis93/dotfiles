# Selective CachyOS config loading (performance optimized)
# We skip the full config which overwrites our greeting and loads unnecessary plugins
# Instead, we just set up the essential paths and features we actually use

# Add ~/.local/bin to PATH (from CachyOS config, but done more efficiently)
contains ~/.local/bin $PATH; or set -gxa PATH ~/.local/bin $PATH

# Simple greeting (must be defined AFTER any CachyOS sourcing to prevent overwrite)
function fish_greeting
    echo "Welcome to" (set_color cyan)"CachyOS"(set_color normal) "with" (set_color yellow)"fish"(set_color normal) "shell!"
    echo "Type" (set_color green)"help"(set_color normal) "for instructions on how to use fish"
end

# Initialize starship prompt (if installed)
if type -q starship
    starship init fish | source
end

# Set default editor to Helix
set -gx EDITOR helix
set -gx VISUAL helix

# Set SHELL to fish (fixes tmux and other programs)
set -gx SHELL /bin/fish

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

# Dotfiles workspace shortcuts
abbr -a dcd 'cd ~/.config/dotfiles'
abbr -a dcl 'dotclaude'

# Editor shortcuts
abbr -a hx helix
abbr -a v helix
abbr -a sv 'sudo helix'
abbr -a vim vim  # Keep vim available for compatibility

# Quick config edits
abbr -a fishconfig 'helix ~/.config/fish/config.fish'
abbr -a bspconfig 'helix ~/.config/bspwm/bspwmrc'
abbr -a sxhkdconfig 'helix ~/.config/sxhkd/sxhkdrc'
abbr -a polybarconfig 'helix ~/.config/polybar/config.ini'

# Load any local machine-specific configurations
if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end
# Added by Zenvestor setup script - Dart pub global packages
set -gx PATH /home/pentaxis93/.pub-cache/bin $PATH

# Added by Zenvestor setup script - Flutter via FVM
set -gx PATH /home/pentaxis93/fvm/default/bin $PATH
