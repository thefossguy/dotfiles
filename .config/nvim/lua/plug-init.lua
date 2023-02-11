--------------------------------------------------------------------------------
-- Packer related setup
--------------------------------------------------------------------------------

-- This section is HEAVILY "inspired" by this guide
-- https://www.chiarulli.me/Neovim-2/03-plugins/

-- Use a protected call so that we do not error out on the first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have Packer use a pop-up window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({
        border = "single"
      })
    end
  }}
)


--------------------------------------------------------------------------------
-- Install packages
--------------------------------------------------------------------------------

return require("packer").startup(function(use)
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  -- decorations
  use {
    "chriskempson/base16-vim"
  }

  -- plugins for finding stuff
  use {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "jremmen/vim-ripgrep",
  }

  -- auto-complete
  use {
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",
  }

  -- parser/highlighter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
  }

  -- Rust lang
  use {
    "rust-lang/rust.vim",
    "simrat39/rust-tools.nvim",
  }

  -- git
  use "tpope/vim-fugitive"

  -- tree view
  use {
    "nvim-tree/nvim-tree.lua",
    "nvim-tree/nvim-web-devicons",
  }


  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
