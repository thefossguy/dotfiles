" ==============================================================================
" Plugins
" ==============================================================================
call plug#begin('~/.vim/plugged')

" base16 theme
Plug 'chriskempson/base16-vim'

" auto-complete
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
" for vsnip
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" fuzzy finder
Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" optional
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" vim ripgrep
Plug 'jremmen/vim-ripgrep'

" official rust plugin
Plug 'rust-lang/rust.vim'
" to enable more of the features of rust-analyzer, such as inlay hints and more!
Plug 'simrat39/rust-tools.nvim'

" git wrapper
Plug 'tpope/vim-fugitive'

" src tree view
Plug 'preservim/nerdtree'

call plug#end()


" ==============================================================================
" Neovim core(?)
" ==============================================================================
" dealing with files
syntax on
filetype plugin indent on
set colorcolumn=80
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
colorscheme base16-google-dark
"colorscheme base16-gruvbox-dark-hard
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
" Rust
" ==============================================================================
" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set updatetime=300

" have a fixed column for the diagnostics to appear in
" this removes the jitter when warnings/errors flow in
set signcolumn=yes

" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Avoid showing extra messages when using completion
set shortmess+=c

" Show diagnostic popup on cursor hold
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })

" format-on-write
autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync(nil, 200)

" use 4 spaces for indent rust
autocmd FileType rust setlocal expandtab shiftwidth=4 softtabstop=4

let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0

luafile ~/.config/nvim/lua/simrat39__rust-tools.nvim.lua
luafile ~/.config/nvim/lua/hrsh7th__nvim-cmp.lua


" ==============================================================================
" Indentation
" ==============================================================================
" use 2 spaces for indentation of specific file types
autocmd FileType lua setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType json setlocal expandtab shiftwidth=2 softtabstop=2

" use 4 spaces for indentation of specific file types
autocmd FileType bash setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType c setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType gitconfig setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType sh setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType vim setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType yaml setlocal expandtab shiftwidth=4 softtabstop=4


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

" RUST
" Code navigation shortcuts
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
" code actions
nnoremap <silent> ga    <cmd>lua vim.lsp.buf.code_action()<CR>
" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>


" ==============================================================================
" change highlight color when yanking
" ==============================================================================
au TextYankPost * silent! lua vim.highlight.on_yank {higroup="Visual", timeout=250}
