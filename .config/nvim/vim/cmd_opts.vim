" ==============================================================================
" Vimscript things that I can't "rewrite" in Lua
" ==============================================================================

syntax on
filetype plugin indent on
set encoding=utf-8


" appearance
set colorcolumn=80
set cursorcolumn
set autoindent expandtab tabstop=4 shiftwidth=4 "softtabstop=4
set number relativenumber
set noshowmode " I will set the status line manually; Neovim doesn't need to show this
set showcmd
set spell
set termguicolors
set cursorline
set title
set showmatch
set splitright

let base16colorspace=256
colorscheme base16-google-dark


" speed/other improvements
set timeoutlen=300 " http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
set updatetime=300 " updatetime for CursorHold
set noswapfile
set wildmenu " use <Tab> to auto-complete Neovim commands

" have a fixed column for diagnostics to appear in; this removes the jigger when warnings/errors flow in
set signcolumn=yes 

" auto completion
" :help completeopt
" menuone: popup even when there's only one match
" preview: show extra information about the currently selected completion
" noinsert: do not insert text until a selection is made
" noselect: do not select, force the user to select one from the menu
set completeopt=menuone,preview,noinsert,noselect

" disable messages like 'match 1 of 2', 'the only match', 'pattern not found', etc
set shortmess+=c

" undo
set undolevels=200
set undodir=~/.vimdid
set undofile


" search and/or replace
set incsearch ignorecase smartcase hlsearch
set nogdefault


" disable mouse
set mouse=


" change highlight color when yanking
au TextYankPost * silent! lua vim.highlight.on_yank {higroup="Visual", timeout=250}
