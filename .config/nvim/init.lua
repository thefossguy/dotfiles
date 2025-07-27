--------------------------------------------------------------------------------
-- initial setup
--------------------------------------------------------------------------------

-- disable netrw at the very start of init.lua
-- (strongly advised by 'nvim-tree.lua')
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set <space> as the leader key
-- this must happen before the pllugs are loaded
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set ({ "n", "v" }, "<Space>", "<Nop>") -- disable <space> in normal and visual modes

require ("00-startup-checks")
require ("01-setup")
require ("02-plugins-setup")
-- require('vim-options')
-- require('autocmds')
-- require('key-mappings')
