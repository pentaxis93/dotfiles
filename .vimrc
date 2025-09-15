" Vim Configuration with Gruvbox Dark Hard Theme
" ================================================

" Basic Settings
" --------------
set nocompatible              " Use Vim defaults (not Vi)
set encoding=utf-8            " UTF-8 encoding
set number                    " Show line numbers
set relativenumber            " Show relative line numbers
set cursorline                " Highlight current line
set showcmd                   " Show command in bottom bar
set wildmenu                  " Visual autocomplete for command menu
set showmatch                 " Highlight matching brackets
set laststatus=2              " Always show status line
set ruler                     " Show cursor position

" Indentation
" -----------
set expandtab                 " Use spaces instead of tabs
set tabstop=4                 " Number of visual spaces per TAB
set softtabstop=4             " Number of spaces in tab when editing
set shiftwidth=4              " Number of spaces for autoindent
set autoindent                " Auto indent new lines
set smartindent               " Smart indentation

" Search
" ------
set incsearch                 " Search as characters are entered
set hlsearch                  " Highlight search matches
set ignorecase                " Case insensitive search
set smartcase                 " Case sensitive if uppercase present

" Performance
" -----------
set lazyredraw                " Don't redraw while executing macros
set ttyfast                   " Faster redrawing

" Backups
" -------
set nobackup                  " No backup files
set nowritebackup             " No backup before overwriting
set noswapfile                " No swap files

" Colors and Syntax
" -----------------
syntax enable                 " Enable syntax highlighting
set background=dark           " Dark background

" Try to use Gruvbox if available
try
    colorscheme gruvbox
catch
    " Fallback colors if gruvbox not installed
    colorscheme desert
endtry

" Enable true colors if available
if has('termguicolors')
    set termguicolors
endif

" Set 256 colors
set t_Co=256

" Key Mappings
" ------------
" Quick save
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" Quick quit
nnoremap <C-q> :q<CR>

" Clear search highlighting
nnoremap <leader><space> :nohlsearch<CR>

" Move between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" File Type Specific
" ------------------
filetype plugin indent on     " Enable file type detection

" Python specific
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4

" JavaScript/TypeScript specific
autocmd FileType javascript,typescript setlocal expandtab shiftwidth=2 softtabstop=2

" YAML specific
autocmd FileType yaml setlocal expandtab shiftwidth=2 softtabstop=2

" Markdown specific
autocmd FileType markdown setlocal wrap linebreak

" Note: Gruvbox theme will be automatically applied if you install it with:
" git clone https://github.com/morhetz/gruvbox.git ~/.vim/pack/default/start/gruvbox