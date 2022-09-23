" ==============================================================================
" Plugins
" ==============================================================================
call plug#begin('~/.vim/plugged')

" base16 theme
Plug 'chriskempson/base16-vim'

" ncm2 (Neovim-only auto-complete)
"Plug 'roxma/nvim-yarp'
"Plug 'ncm2/ncm2'
"Plug 'ncm2/ncm2-bufword'
"Plug 'ncm2/ncm2-path'

" Fuzzy finder
Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" vim ripgrep
Plug 'jremmen/vim-ripgrep'

" .rs
Plug 'rust-lang/rust.vim'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'dense-analysis/ale'

"Plug 'wuelnerdotexe/vim-enfocado'
"Plug 'tpope/vim-fugitive'
Plug 'preservim/nerdtree'
"Plug 'pineapplegiant/spaceduck'
"Plug 'pineapplegiant/spaceduck', { 'branch': 'main' }

call plug#end()


" ==============================================================================
" Neovim core(?)
" ==============================================================================
" dealing with files
syntax on
filetype plugin indent on
set colorcolumn=72
set autoindent expandtab tabstop=4 shiftwidth=4
set encoding=utf-8

" appearance
set number relativenumber
set noshowmode
set showcmd
set timeoutlen=300 " (http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line)
set spell
set termguicolors
set cursorline
let base16colorspace=256
colorscheme base16-gruvbox-dark-hard
colorscheme base16-google-dark
"set cursorcolumn

"set clipboard=unnamed,unnamedplus
set title
set noswapfile
"set lazyredraw
"set ttyfast (https://neovim.io/doc/user/vim_diff.html#'ttyfast')

" undo
set undolevels=200
set undodir=~/.vimdid
set undofile

" search
set incsearch ignorecase smartcase hlsearch
" do not substitute _globally_
set nogdefault

set visualbell
set wildmenu
set showmatch

set pastetoggle=<F2>
"set guifont=Fira\ Code:h12
"set viminfo=


" ==============================================================================
" Auto-complete (ncm2)
" ==============================================================================
" enable ncm2 for all buffers
"autocmd BufEnter * call ncm2#enable_for_buffer()

" IMPORTANT: :help Ncm2PopupOpen for more information
"set completeopt=noinsert,menuone,noselect

" ncm2: CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
"inoremap <c-c> <ESC>

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
"inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup menu:
"inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
"inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"


" ==============================================================================
" Rust
" ==============================================================================
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
"let g:ale_linters = {'rust': ['analyzer']}
"au Filetype rust set colorcolumn=80
"au Filetype c set colorcolumn=80
"let g:LanguageClient_serverCommands = {
"      \ 'rust': ['rust-analyzer'],
"      \ }
"let g:ale_linters = {'rust': ['rustc', 'rls']}


" ==============================================================================
" Statusline
" ==============================================================================
" Define all the different modes
let g:currentmode={
    \ 'n'  : 'NORMAL',
    \ 'no' : 'NORMAL·OPERATOR PENDING',
    \ 'v'  : 'VISUAL',
    \ 'V'  : 'V·LINE',
    \ '^V' : 'V·BLOCK',
    \ 's'  : 'SELECT',
    \ 'S'  : 'S·LINE',
    \ '^S' : 'S·BLOCK',
    \ 'i'  : 'INSERT',
    \ 'R'  : 'REPLACE',
    \ 'Rv' : 'V·REPLACE',
    \ 'c'  : 'COMMAND',
    \ 'cv' : 'VIM EX',
    \ 'ce' : 'EX',
    \ 'r'  : 'PROMPT',
    \ 'rm' : 'MORE',
    \ 'r?' : 'CONFIRM',
    \ '!'  : 'SHELL',
    \ 't'  : 'TERMINAL'
    \}

set statusline=
" 2 space padding
set statusline+=%#ErrorMsg#\ \ 
" shows mode
set statusline+=%#Search#\ %{g:currentmode[mode()]}\ 
" shows '[+]' if modified else '[0]'
set statusline+=%#ErrorMsg#\ %{&modified?'[+]':'[0]'}\ 
" show if a file is readonly
set statusline+=%#Question#%{&readonly?'[RO]':'[RW]'}\ 
" show the file name
set statusline+=%#CursorLineNr#\ %f\ 
" show filename
set statusline+=%#SignColumn#\(%{wordcount().words}\)\ %#Comment#
" show wc
set statusline+=%=
" show file format dos/UNIX
set statusline+=%#Title#%{&ff}\ 
" show encoding format
set statusline+=%#Directory#%{&fileencoding}\ 
" show the syntax/file type eg Rust, C, Python, Vim etc
set statusline+=%#Todo#\ %Y\ 
" show percentage through a file
set statusline+=%#Identifier#\ %p%%
" show the currentline/totallines
set statusline+=%#Normal#\ %lL\ 
" show column number
set statusline+=%#CursorColumn#\ %cC\ 
" 2 space padding
set statusline+=%#Normal#\ \ 
set laststatus=2


" ==============================================================================
" key bindings
" ==============================================================================
" Jump to start and end of line using the home row keys
map H ^
map L $

" remap uppercase J and K to their lowercase counterparts;
" been bitten too many times
nnoremap K k
nnoremap J j
"inoremap K k
"inoremap J j

"map-command [map-arg] {lhs} {rhs}
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"enable nerdtree with ^\
map <C-Bslash> :NERDTreeToggle<CR>


" ==============================================================================
" change highlight color when yanking
" ==============================================================================
au TextYankPost * silent! lua vim.highlight.on_yank {higroup="Visual", timeout=250}

