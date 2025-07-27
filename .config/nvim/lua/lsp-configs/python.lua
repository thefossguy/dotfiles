vim.lsp.config["python"] = {
  cmd = { "pyrefly", "lsp", "--indexing-mode", "lazy-non-blocking-background" },
  filetypes = { "python" },
  root_markers = { ".git" },
}
vim.lsp.enable ("python")
