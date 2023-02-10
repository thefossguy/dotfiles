--------------------------------------------------------------------------------
-- Initial setup
--------------------------------------------------------------------------------

-- disable netrw at the very start of init.lua (strongly advised by _nvim-tree.lua_)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


require("plug-init")
vim.cmd("source ~/.config/nvim/vim/cmd_opts.vim")
require("autocmds")
require("key-bindings")
vim.cmd("source ~/.config/nvim/vim/statusline.vim")
require("plug-setup")
