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
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {'*.rs'},
  command = 'lua vim.lsp.buf.format(nil, 200)',
})
-- thank you, Prime
-- https://github.com/ThePrimeagen/neovimrc/blob/4d7a467091706a75684ee9a32b1e1e8f2e187e39/lua/theprimeagen/init.lua#L44-L48
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})
