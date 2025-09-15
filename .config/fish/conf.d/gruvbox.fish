# Gruvbox Dark Hard color scheme for Fish shell

# Syntax Highlighting Colors
set -U fish_color_normal ebdbb2  # default color
set -U fish_color_command b8bb26  # commands like echo (bright green)
set -U fish_color_keyword fb4934  # keywords like if, else (bright red)
set -U fish_color_quote fabd2f  # quoted text (bright yellow)
set -U fish_color_redirection 8ec07c  # IO redirections (bright cyan)
set -U fish_color_end fe8019  # process separators like ; and & (bright orange)
set -U fish_color_error fb4934  # errors (bright red)
set -U fish_color_param 83a598  # command parameters (bright blue)
set -U fish_color_comment 928374  # comments (gray)
set -U fish_color_selection --background=3c3836  # selected text background
set -U fish_color_search_match --background=504945  # search matches
set -U fish_color_operator 8ec07c  # operators (bright cyan)
set -U fish_color_escape fe8019  # escape sequences (bright orange)
set -U fish_color_autosuggestion 689d6a  # autosuggestions (darker cyan)
set -U fish_color_cancel fb4934  # the ^C indicator (bright red)

# Completion Pager Colors
set -U fish_pager_color_progress fabd2f  # progress bar (bright yellow)
set -U fish_pager_color_prefix b8bb26  # prefix string (bright green)
set -U fish_pager_color_completion ebdbb2  # completion text
set -U fish_pager_color_description a89984  # completion descriptions (light gray)
set -U fish_pager_color_selected_background --background=3c3836

# FZF Integration with Gruvbox colors
set -gx FZF_DEFAULT_OPTS '
  --height 40% --layout=reverse --border --info=inline
  --color=bg+:#3c3836,bg:#1d2021,spinner:#fb4934,hl:#928374
  --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934
  --color=marker:#fe8019,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934
'

# Comprehensive LS_COLORS with Gruvbox palette
# Directories: bold cyan (our accent color!)
# Executables: bold green
# Symlinks: cyan
# Archives: yellow
# Media: magenta
set -gx LS_COLORS 'di=1;36:ln=36:so=35:pi=33:ex=1;32:bd=33;1:cd=33;1:su=37;41:sg=30;43:tw=30;42:ow=34;42:or=31;1:mi=0:mh=0:*.tar=33:*.tgz=33:*.zip=33:*.gz=33:*.bz2=33:*.7z=33:*.xz=33:*.rar=33:*.jpg=35:*.jpeg=35:*.png=35:*.gif=35:*.bmp=35:*.svg=35:*.mp4=35:*.mkv=35:*.avi=35:*.mp3=35:*.flac=35:*.wav=35:*.pdf=31:*.doc=31:*.docx=31:*.txt=37:*.md=37:*.yml=36:*.yaml=36:*.json=36:*.toml=36:*.xml=36:*.sh=32:*.bash=32:*.fish=32:*.py=32:*.rs=32:*.go=32:*.js=32:*.ts=32:*.c=32:*.cpp=32:*.h=32:*.hpp=32'