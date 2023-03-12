--------------------------------------------------------------------------------
-- setup package manager
--------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- install plugins
--------------------------------------------------------------------------------

require('lazy').setup({

  -- git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  { -- theme
    'chriskempson/base16-vim',
    -- config = function()
    --   vim.cmd.colorscheme 'base16-google-dark'
    -- end,
  },

  { -- Rust
    'rust-lang/rust.vim',
    'simrat39/rust-tools.nvim',
  },

  { -- tree view
    'nvim-tree/nvim-tree.lua',
    'nvim-tree/nvim-web-devicons',
  },

  { -- LSP configuration and plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  },

  { -- autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  -- useful plugin to show you pending keybinds
  { 'folke/which-key.nvim', opts = {} },
  { -- adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  { -- set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        theme = 'nightfly',
        globalstatus = true,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        always_divide_middle = false,
        refres = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff'},
        lualine_c = {
          {
            'filename',
            file_status = true,
            icon_only = true,
            symbols = {
              modified = '[+]',
              readonly = '[RO]',
              unnamed = '[NO NAME]',
              newfile = '[NEW FILE]',
            },
          }, {
            'diagnostics',
            sources = { 'nvim_lsp' },
            sections = { 'error', 'warn', 'info', 'hint' },
            colored = true,
            always_visible = true,
          }
        },
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'searchcount', 'progress'},
        lualine_z = {'location'},
      },
    },
  },

  { -- add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    opts = {
      char = '┊',
      show_trailing_blankline_indent = false,
    },
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', version = '*', dependencies = { 'nvim-lua/plenary.nvim' } },

  { -- highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  },

}, {})
