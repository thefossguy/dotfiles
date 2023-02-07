--------------------------------------------------------------------------------
-- initial setup
--------------------------------------------------------------------------------

-- disable netrw at the very start of init.lua (strongly advised by _nvim-tree.lua_)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


--------------------------------------------------------------------------------
-- Plugin setup
--------------------------------------------------------------------------------



-- 'nvim-tree.lua' setup
require("nvim-tree").setup({
  auto_reload_on_write = true,
  disable_netrw = false,
  hijack_netrw = true,
  sort_by = "case_sensitive",
  view = {
    width = 30,
    number = true,
    relativenumber = true,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
      },
    },
  },
  renderer = {
    group_empty = false,
    highlight_git = true,
      icons = {
        symlink_arrow = " ➛ ",
      glyphs = {
        modified = "●",
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "[ ]",
          deleted = "",
          ignored = "◌",
        },
      },
    },
    special_files = { "Cargo.toml", "README.md", "Readme.md", "readme.md" },
    symlink_destination = true,
  },
  filters = {
    dotfiles = true,
  },
})


--------------------------------------------------------------------------------
-- open _things_...
--------------------------------------------------------------------------------

local function open_nvim_tree()
  require("nvim-tree.api").tree.open()
end

-- UNDO THIS   open_nvim_tree()
