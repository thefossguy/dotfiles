--------------------------------------------------------------------------------
-- treesitter is for:
-- * syntax highlighting
-- * indentation
-- * folding
--
-- **USE ONLY WHEN AN LSP IS NOT AVAILABLE (e.g. markup languages)**
--------------------------------------------------------------------------------
require ("nvim-treesitter.configs").setup ({
  -- list of parsers that must always be installed
  -- typically installed/updated with `:TSUpdate`
  ensure_installed = {
    "bash",
    "c",
    "kconfig",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "nix",
    "python",
    "regex",
    "rust",
    "toml",
    "vim",
  },

  sync_install = true, -- whether the parsers in `ensure_installed` are installed one after another
  auto_install = false, -- whether missing parsers are automatically installed
  highlight = {
    enable = true, -- no docs in upstream other than "`false` will disable the whole extension"
  },
})
