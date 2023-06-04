require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
    untracked = { text = '' },
  },
  signcolumn = true, -- show the sings (set above) in the "gutter" (before the numbers in the numberline)
  numhl = true, -- highlight the numbers for lines that are modified
})
