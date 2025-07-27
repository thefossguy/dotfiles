--------------------------------------------------------------------------------
-- setup the plugin manager
-- https://github.com/folke/lazy.nvim
--------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath ("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat (lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system ({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo ({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar ()
    os.exit (1)
  end
end
vim.opt.rtp:prepend (lazypath)

--------------------------------------------------------------------------------
-- install plugins
--------------------------------------------------------------------------------
require ("lazy").setup ({
  spec = {
    {
      -- theme
      "catppuccin/nvim",
      name = "catppuccin",
    },

    {
      -- programming/scripting related+adjacent
      "j-hui/fidget.nvim", -- LSP progress messages and notifications
      "lewis6991/gitsigns.nvim", -- adds git signs to the gutter, as well as utilities for managing changes
      "lukas-reineke/indent-blankline.nvim", -- add indentation guides even on blank lines
      "m4xshen/autoclose.nvim", -- autoclose brackets and quotes
      "numToStr/Comment.nvim", -- make commented out code grey
      "nvim-telescope/telescope.nvim", -- powerful fuzzy finder
      {
        -- treesitter configurations and abstraction layer
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
      },
      {
        -- completion
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        -- `luasnip` for `nvim-cmp` to show "completion dropdowns" as a lua snippet
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
    },

    {
      -- misc plugins
      "nvim-lualine/lualine.nvim", -- statusline
    },
  },

  change_detection = {
    enabled = false, -- whether to automatically check for config file changes and reload the ui
    notify = true,
  },
  install = {
    missing = false, -- whether to install missing plugins on startup
    colorscheme = { "mocha" }, -- try to load one of these colorschemes when starting an installation during startup
  },
  -- plugin updates checker section
  checker = {
    enabled = true,
    concurrency = 1,
    notify = true,
    frequency = 86400, -- check for updates every these many seconds
    check_pinned = true, -- whether to check for updates even for pinned plugins
  },
})

--------------------------------------------------------------------------------
-- load the configurations for installed plugins
--------------------------------------------------------------------------------
require ("plugin-setup")
require ("lsp-configs/00-init")
require ("treesitter-config")
require ("code-autocompletion-config")
