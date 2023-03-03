-- CursorHold
vim.api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  command = "lua vim.diagnostic.open_float(nil, { focusable = false })",
})


-- format on write
vim.g.rustfmt_autosave = 1
vim.g.rustfmt_emit_files = 1
vim.g.rustfmt_fail_silently = 0
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = {"*.rs"},
  command = "lua vim.lsp.buf.format(nil, 200)",
})


-- indentation (2 spaces)
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*.lua"},
  command = "setlocal expandtab shiftwidth=2 softtabstop=2",
})
