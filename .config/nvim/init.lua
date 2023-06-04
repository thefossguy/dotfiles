--------------------------------------------------------------------------------
-- initial setup
--------------------------------------------------------------------------------

-- disable netrw at the very start of init.lua
-- (strongly advised by 'nvim-tree.lua')
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set <space> as the leader key
-- this must happen before the pllugs are loaded
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


-- initialize the package manager
require('plugins/init')
-- setup the plugins
require('plug-setup')
-- load the options, autocmds, key bindings and statusline
require('vim-options')
require('autocmds')
require('key-mappings')
