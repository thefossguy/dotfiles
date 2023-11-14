--------------------------------------------------------------------------------
-- setup the plugin manager
-- https://github.com/folke/lazy.nvim
--------------------------------------------------------------------------------

local lazy_path = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazy_path) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazy_path,
  }
end
vim.opt.rtp:prepend(lazy_path)


--------------------------------------------------------------------------------
-- install plugins
--------------------------------------------------------------------------------

require('lazy').setup({

  {
    -- theme
    'catppuccin/nvim',
    name = 'catppuccin',
  },

  -- detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  {
    -- programming/scripting langauges

    'm4xshen/autoclose.nvim', -- autoclose brackets and quotes

    {
      -- Rust
      'rust-lang/rust.vim',
      'simrat39/rust-tools.nvim',

      -- debugging
      'nvim-lua/plenary.nvim',
      'mfussenegger/nvim-dap',
    },

  },

  {
    -- LSP
    'neovim/nvim-lspconfig',
    dependencies = {
      'folke/neodev.nvim', -- additional lua configuration, makes nvim stuff amazing
      {
        'j-hui/fidget.nvim', -- useful status updates for LSP
        branch = 'legacy'
      }
    },
  },

  {
    -- autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'windwp/nvim-autopairs',
      {
        -- snippet plugin
        'L3MON4D3/LuaSnip',
        dependencies = 'rafamadriz/friendly-snippets',
      },
    },
  },

  {
    -- telescope
    'nvim-telescope/telescope.nvim',
    'gregorias/nvim-mapper', -- shows keymaps
    'nvim-lua/popup.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },

  {
    -- treesitter
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      pcall(require('nvim-treesitter.install').update({
        with_sync = true
      }))
    end
  },

  -- adds git signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',

  {
    -- git operations inside the editor
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'sindrets/diffview.nvim',
      'ibhagwan/fzf-lua',
    },
  },

  -- to view diffs "side-by-side"
  'sindrets/diffview.nvim',

  -- incrementally rename
  'smjonas/inc-rename.nvim',

  {
    -- tree view
    'nvim-tree/nvim-tree.lua',
    'nvim-tree/nvim-web-devicons',
  },

  -- set lualine as statusline
  'nvim-lualine/lualine.nvim',

  -- show a pop-up with possible **key-bindings** of the command you started typing
  'folke/which-key.nvim',

  {
    -- notifications
    'folke/noice.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    }
  },

  -- add indentation guides even on blank lines
  'lukas-reineke/indent-blankline.nvim',

  -- 'gc' to comment visual regions/lines
  'numToStr/Comment.nvim',

  -- Nix[OS] things
  'oxalica/nil',

}, {
  defaults = {
    lazy = true, -- enable lazy-loading of plugins
  },
  checker = {
    -- automatically check for plugin updates
    enabled = true,
    concurrency = nil,
    notify = true,
    frequency = 604800, -- check for updates every week
  },
  change_detection = {
    -- automatically check for config file changes and reload the ui
    enabled = true,
    notify = true,
  }
})


--------------------------------------------------------------------------------
-- setup the plugins
--------------------------------------------------------------------------------

require('plugins/theme')
require('plugins/lualine')
require('plugins/gitsigns')
require('plugins/neogit')
require('plugins/tree-view')
require('plugins/notifs') -- nvim-notify, noice.nvim
require('plugins/other') -- Comment.nvim, indent-blankline.nvim

require('plugins/autocomplete') -- autocomplete + LSP
require('plugins/debugging')
-- require('plugins/')
