vim.keymap.set ("n", "<Esc>", "<cmd>nohlsearch<CR>") -- clear the highlighted search on <Esc> in normal mode
vim.keymap.set ({ "n", "i" }, "<C-S-V>", "'+P") -- for using clipboard in neovide
vim.keymap.set ({ "n", "v" }, "<leader>i", vim.lsp.buf.hover, { desc = "[I]nfo (hover)" }) -- show info with <leader>i
vim.keymap.set ({ "n", "v" }, "H", "^", {}) -- jump to the start of line
vim.keymap.set ({ "n", "v" }, "L", "$", {}) -- jump to the end of line
vim.keymap.set ({ "n", "v" }, "J", "1<C-d>", { remap = true }) -- move screen down one line respectively
vim.keymap.set ({ "n", "v" }, "K", "1<C-u>", { remap = true }) -- move screen up one line respectively
vim.keymap.set ({ "n", "v", "i", "c" }, "<C-h>", "<C-n><C-w>h") -- move to the buffer on left using Ctrl-h
vim.keymap.set ({ "n", "v", "i", "c" }, "<C-l>", "<C-n><C-w>l") -- move to the buffer on right using Ctrl-l
vim.keymap.set ({ "n", "v", "i", "c" }, "<C-j>", "<C-n><C-w>j") -- move to the buffer below using Ctrl-j
vim.keymap.set ({ "n", "v", "i", "c" }, "<C-k>", "<C-n><C-w>k") -- move to the buffer on top using Ctrl-k
-- jump `count` lines up and down while "skipping wrapped lines"
-- treat wrapped lines as single
-- i.e. 3 wrapped lines of single line are treated as 1
vim.keymap.set ("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true }) -- jump `count` lines up while "skipping wrapped lines"
vim.keymap.set ("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true }) -- jump `count` lines down while "skipping wrapped lines"

-- indentation
vim.o.autoindent = true
vim.o.breakindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4

-- search
vim.o.gdefault = false -- diable global substitution by default, let me specify it
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.showmatch = true
vim.o.smartcase = true

vim.o.clipboard = "unnamedplus"
vim.o.colorcolumn = "72"
vim.o.cursorcolumn = true
vim.o.cursorline = true
vim.o.encoding = "utf-8"
vim.o.list = true
vim.o.listchars = "precedes:«,extends:»,trail:␣,tab:  "
vim.o.mouse = "n" -- toggle mouse support
vim.o.mousefocus = false -- whether the window that the mouse pointer is on is automatically activated
vim.o.mousehide = true -- whether the mouse pointer is hidden when characters are typed
vim.o.mousemoveevent = false -- whether the mouse move events are delivered to the input queue and are available for mapping
vim.o.mousescroll = "ver:5,hor:5" -- number of lines to scroll per mouse scroll event
vim.o.number = true -- show numbers
vim.o.relativenumber = true -- show numbers relative to cusor line
vim.o.showcmd = true -- whether to show command that is being typed with `:<cmd>`
vim.o.signcolumn = "yes"
vim.o.spell = true -- enable spellcheck
vim.o.splitright = true -- open splits in right
vim.o.swapfile = false
vim.o.termguicolors = true -- whether to enable 24-bit RGB color in the TUI
vim.o.timeout = true
vim.o.timeoutlen = 300 -- time in milliseconds to wait for a mapped sequence to complete.
vim.o.title = true
vim.o.undodir = vim.fn.expand ("~/.nvim/undodir")
vim.o.undofile = true
vim.o.undolevels = 200
vim.o.wildmenu = true -- whether to show completion in typing vim commands

vim.g.loaded_perl_provider = false -- disable perl support

-- highlight line when yanking
vim.api.nvim_create_autocmd ("TextYankPost", {
  callback = function () vim.highlight.on_yank () end,
  group = vim.api.nvim_create_augroup ("YankHighlight", { clear = true }),
  pattern = "*",
})

-- thank you, Prime
-- https://github.com/ThePrimeagen/neovimrc/blob/4d7a467091706a75684ee9a32b1e1e8f2e187e39/lua/theprimeagen/init.lua#L44-L48
vim.api.nvim_create_autocmd ("BufWritePre", {
  pattern = "*",
  callback = function ()
    local save_cursor = vim.fn.getpos (".")
    vim.cmd ([[%s/\s\+$//e]])
    vim.fn.setpos (".", save_cursor)
  end,
})
