--------------------------------------------------------------------------------
-- LSP related setup after server configuration and enablement
--------------------------------------------------------------------------------

local function enable_inlay_hints_for_lsp_buffers ()
  local clients = vim.lsp.get_clients ()
  if #clients == 0 then return end
  local buffers = vim.api.nvim_list_bufs ()

  for _, bufnr in ipairs (buffers) do
    if vim.api.nvim_buf_is_loaded (bufnr) then
      local buffer_clients = vim.lsp.get_clients ({ bufnr = bufnr })
      if #buffer_clients > 0 then
        local supports_inlay_hints = false
        for _, client in ipairs (buffer_clients) do
          if client.server_capabilities.inlayHintProvider then
            supports_inlay_hints = true
            break
          end
        end

        if supports_inlay_hints and not vim.lsp.inlay_hint.is_enabled () then
          vim.lsp.inlay_hint.enable (true, { bufnr = bufnr })
          print ("LSP inlay hints enabled")
        end
      end
    end
  end
end
enable_inlay_hints_for_lsp_buffers ()
