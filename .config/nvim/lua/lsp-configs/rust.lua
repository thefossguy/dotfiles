vim.lsp.config["rust"] = {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { ".git" },
  on_attach = function (client, bufnr) vim.lsp.inlay_hint.enable (true, { bufnr = bufnr }) end,
  settings = {
    ["rust-analyzer"] = {
      -- https://rust-analyzer.github.io/book/configuration.html
      completion = {
        addSemicolonToUnit = true,
        autoAwait = {
          enable = true,
        },
        autoIter = {
          enable = true,
        },
        autoimport = {
          enable = false,
        },
        autoself = {
          enable = true,
        },
        callable = {
          snippets = "fill_arguments",
        },
        limit = nil,
        postfix = {
          enable = true,
        },
        privateEditable = {
          enable = false,
        },
        termSearch = {
          enable = true,
        },
      },
      diagnostics = {
        enable = true,
      },
      highlightRelated = {
        branchExitPoints = {
          enable = true,
        },
        breakPoints = {
          enable = true,
        },
        closureCaptures = {
          enable = true,
        },
        exitPoints = {
          enable = true,
        },
        references = {
          enable = true,
        },
        yieldPoints = {
          enable = true,
        },
      },
      hover = {
        debug = {
          enable = true,
        },
        actions = {
          enable = true,
        },
        gotoTypeDef = {
          enable = true,
        },
        implementations = {
          enable = true,
        },
        documentation = {
          enable = true,
          keywords = {
            enable = true,
          },
        },
        dropGlue = {
          enable = true,
        },
        links = {
          enable = true,
        },
        show = {
          enumVariants = 10,
          fields = 10,
        },
      },
      inlayHints = {
        bindingModeHints = {
          enable = true,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
          minLines = 40,
        },
        closureCaptureHints = {
          enable = true,
        },
        parameterHints = {
          enable = true,
        },
        renderColons = true,
        typeHints = {
          enable = true,
        },
      },
      signatureInfo = {
        detail = "full",
        documentation = {
          enable = true,
        },
      },
    },
  },
}
vim.lsp.enable ("rust")
