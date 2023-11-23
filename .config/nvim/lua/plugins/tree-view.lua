require('nvim-tree').setup({
  auto_reload_on_write = true,
  disable_netrw = false,
  hijack_netrw = true,
  sort_by = 'case_sensitive',
  view = {
    width = 30,
    number = true,
    relativenumber = true,
    side = "right",
  },
  renderer = {
    group_empty = false,
    highlight_git = true,
    icons = {
      symlink_arrow = ' ➛ ',
      glyphs = {
        modified = '●',
        git = {
          unstaged = '✗',
          staged = '✓',
          unmerged = '',
          renamed = '➜',
          untracked = '[ ]',
          deleted = '',
          ignored = '◌',
        },
      },
    },
    special_files = { 'Cargo.toml', 'README.md' },
    symlink_destination = true,
  },
  filters = {
    dotfiles = true,
  },
})
