-- appearance
vim.cmd.colorscheme 'base16-google-dark'
vim.o.colorcolumn = '80'
vim.o.cursorcolumn = true
vim.o.cursorline = true
vim.o.termguicolors = true
vim.o.title = true
vim.o.signcolumn = 'yes'
vim.o.showmatch = true

-- indentation
vim.o.autoindent = true
vim.o.expandtab = true
vim.o.tabstop = '4'
vim.o.shiftwidth = '4'
vim.o.softtabstop = '4'
vim.o.breakindent = true

-- line numbers
vim.o.number = true
vim.o.relativenumber = true

-- behaviour
vim.o.splitright = true -- open splits in right
vim.o.wildmenu = true -- completion in typing vim commands
vim.o.encoding = 'utf-8'

-- show command that is being typed with `:<cmd>`
vim.o.showcmd = true

-- spelling
vim.o.spell = true

-- search related opts
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.nogdefault = true

-- speed up
vim.o.timeout = true
vim.o.timeoutlen = '300'
vim.o.updatetime = '250'
vim.o.noswapfile = true

-- auto-completion
vim.o.completeopt = 'menuone,preview,noinsert,noselect'

-- disable messages like 'match 1 of 2', 'the only match', 'pattern not found', etc
-- vim.o.shortmess:append('c')

-- undo
vim.o.undolevels = '200'
vim.o.undodir = vim.fn.expand('~/.nvim/undodir')
vim.o.undofile = true

-- disable mouse
vim.o.mouse = 'a'
