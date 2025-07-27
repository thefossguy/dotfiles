vim.lsp.config["nix"] = {
  cmd = { "nil" },
  filetypes = { "nix" },
  root_markers = { ".git", "flake.nix" },
  settings = {
    ["nil"] = {
      -- https://github.com/oxalica/nil/blob/main/docs/configuration.md
      formatting = {
        command = nil,
      },
      nix = {
        flake = {
          autoArchive = false,
          autoEvalInputs = false,
        },
      },
    },
  },
}
vim.lsp.enable ("nix")
