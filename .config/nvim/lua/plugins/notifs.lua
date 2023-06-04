vim.opt.termguicolors = true -- needs to be pre-loaded for 'rcarriga/nvim-notify'
require('notify').setup({
  background_color = '#000000',
  render = 'compact',
  stages = 'static',
  timeout = -1,
  icons = {
    DEBUG = '',
    ERROR = '',
    INFO = '',
    TRACE = '✎',
    WARN = '',
  },
})

local noice = require('noice')
noice.setup({
  lsp = {
    override = {
      -- override the default lsp markdown formatter with noice
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      -- override the lsp markdown formatter with noice
      ['vim.lsp.util.stylize_markdown'] = true,
      -- override cmp documentation with noice
      ['cmp.entry.get_documentation'] = true,
    },
  },
  presets = {
    bottom_search = false, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and pop-up menu together
    long_message_to_split = true, -- long messages be sent to a split
    inc_rename = true, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true, -- add a border to hover docs and signature help
  },
  popupmenu = {
    enabled = true,
    backend = 'nui'
  },
})


vim.keymap.set('n', '<C-c>', function() noice.cmd('dismiss') end, { desc = 'Noice: Dismiss notifications' })
