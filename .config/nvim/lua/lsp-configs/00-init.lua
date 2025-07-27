--------------------------------------------------------------------------------
-- language server protocol is for:
-- * code completions
-- * diagnostics (errors, warnings, etc)
-- * formatting (but not enabled in my configs)
-- * inlay hints
--
-- `:help vim.lsp.Config`
--------------------------------------------------------------------------------

-- setup for diagnostics in case the LSP server isn't configured properly
-- or if the configuration goes out of sync with neovim's APIs
vim.api.nvim_create_user_command ("LspInfo", ":checkhealth vim.lsp", { desc = "Alias to `:checkhealth vim.lsp`" })
vim.api.nvim_create_user_command (
  "LspLog",
  function () vim.cmd (string.format ("tabnew %s", vim.lsp.get_log_path ())) end,
  { desc = "Opens the Nvim LSP client log." }
)

vim.api.nvim_create_user_command (
  "ToggleInlayHints",
  function () vim.lsp.inlay_hint.enable (not vim.lsp.inlay_hint.is_enabled ()) end,
  { desc = "Toggle inlay hints for the current buffer" }
)

-- actual LSP server configs
require ("lsp-configs/bash")
require ("lsp-configs/c-cpp")
require ("lsp-configs/nix")
require ("lsp-configs/python")
require ("lsp-configs/rust")

require ("lsp-configs/99-final")
