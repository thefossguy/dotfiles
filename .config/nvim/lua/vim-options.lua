-- appearance
vim.cmd.colorscheme 'base16-google-dark'
vim.opt.colorcolumn = '80'
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.title = true
vim.opt.signcolumn = 'yes'
vim.opt.showmatch = true

-- indentation
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.breakindent = true

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- behaviour
vim.opt.splitright = true -- open splits in right
vim.opt.wildmenu = true -- completion in typing vim commands
vim.opt.encoding = 'utf-8'

-- show command that is being typed with `:<cmd>`
vim.opt.showcmd = true

-- spelling
vim.opt.spell = true

-- search related opts
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.o.nogdefault = true -- diable global substitution by default, let me specify it

-- speed up
vim.opt.timeout = true
vim.o.timeoutlen = '300'
vim.o.updatetime = '250'
vim.o.noswapfile = true

-- auto-completion
vim.opt.completeopt = 'menuone,preview,noinsert,noselect'

-- disable messages like 'match 1 of 2', 'the only match', 'pattern not found', etc
vim.opt.shortmess:append('c')

-- undo
vim.o.undolevels = '200'
vim.opt.undodir = vim.fn.expand('~/.nvim/undodir')
vim.opt.undofile = true

-- disable mouse
vim.opt.mouse = 'a'

-- clipboard
vim.opt.clipboard:append('unnamedplus')
