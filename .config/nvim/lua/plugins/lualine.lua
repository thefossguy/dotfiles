require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'nightfly',
    globalstatus = true,
    component_separators = {
      left = '',
      right = ''
    },
    section_separators = {
      left = '',
      right = ''
    },
    always_divide_middle = false,
    refres = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff' },
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
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'searchcount', 'progress' },
    lualine_z = { 'location' },
  }
})
