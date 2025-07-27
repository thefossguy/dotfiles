vim.lsp.config["c_cpp"] = {
  cmd = { "clangd" },
  filetypes = { "c", "cpp" },
  root_markers = { ".git" },
}
vim.lsp.enable ("c_cpp")
