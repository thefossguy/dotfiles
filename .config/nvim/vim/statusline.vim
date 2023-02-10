" Define all the different modes
let g:currentmode={
    \ 'n'  : 'NORMAL',
    \ 'no' : 'NORMAL·OPERATOR PENDING',
    \ 'v'  : 'VISUAL',
    \ 'V'  : 'V·LINE',
    \ '' : 'V·BLOCK',
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
