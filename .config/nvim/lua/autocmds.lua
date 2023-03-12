-- highlight line when yanking
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- format on write
vim.g.rustfmt_autosave = 1
vim.g.rustfmt_emit_files = 1
vim.g.rustfmt_fail_silently = 0
vim.api.nvim_create_autocmd({'BufWritePre'}, {
  pattern = {'*.rs'},
  command = 'lua vim.lsp.buf.format(nil, 200)',
})

-- set indentation to 2 spaces for special file types
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'*.lua'},
  command = 'setlocal autoindent expandtabe tabstop=2 shiftwidth=2 softtabstop=2',
})
