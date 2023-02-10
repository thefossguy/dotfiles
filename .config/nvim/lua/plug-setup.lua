--------------------------------------------------------------------------------
-- nvim-tree setup
--------------------------------------------------------------------------------

require("nvim-tree").setup({
 auto_reload_on_write = true,
 disable_netrw = false,
 hijack_netrw = true,
 sort_by = "case_sensitive",
 view = {
   width = 30,
   number = true,
   relativenumber = true,
   mappings = {
     list = {
       { key = "u", action = "dir_up" },
     },
   },
 },
 renderer = {
   group_empty = false,
   highlight_git = true,
     icons = {
       symlink_arrow = " ➛ ",
     glyphs = {
       modified = "●",
       git = {
         unstaged = "✗",
         staged = "✓",
         unmerged = "",
         renamed = "➜",
         untracked = "[ ]",
         deleted = "",
         ignored = "◌",
       },
     },
   },
   special_files = { "Cargo.toml", "README.md", "Readme.md", "readme.md" },
   symlink_destination = true,
 },
 filters = {
   dotfiles = true,
 },
})


-- open nvim-tree
-- this function checks if all of the arguments provided to Neovim
-- are either file(s) or director(y|ies)
-- returns true only if an argv is file
function dir_or_file()
  local iter = 0
  while iter < vim.fn.argc() do
    local fpath = io.open(vim.fn.argv(iter), "r")
    iter = iter + 1
    if fpath ~= nil then
      io.close(fpath)
      return true
    end
  end
end

-- open the tree if no files are specified in argv
local open_tree = dir_or_file()
if open_tree ~= true then
  require("nvim-tree.api").tree.open()
end


--------------------------------------------------------------------------------
-- nvim-cmp setup
--------------------------------------------------------------------------------

-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
  })
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
require("lspconfig")["rust_analyzer"].setup {
  cmd = {"rust-analyzer"},
  filetypes = {"rust"},
  capabilities = capabilities,
}


--------------------------------------------------------------------------------
-- rust-tools.nvim setup
--------------------------------------------------------------------------------
local opts = {
  tools = { -- rust-tools options

    -- how to execute terminal commands
    -- options right now: termopen / quickfix
    executor = require("rust-tools/executors").termopen,

    -- callback to execute once rust-analyzer is done initializing the workspace
    -- The callback receives one parameter indicating the `health` of the server: "ok" | "warning" | "error"
    on_initialized = nil,

    -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
    reload_workspace_from_cargo_toml = true,

    -- These apply to the default RustSetInlayHints command
    inlay_hints = {
      -- automatically set inlay hints (type hints)
      -- default: true
      auto = true,

      -- Only show inlay hints for the current line
      only_current_line = false,

      -- whether to show parameter hints with the inlay hints or not
      -- default: true
      show_parameter_hints = true,

      -- prefix for parameter hints
      -- default: "<-"
      parameter_hints_prefix = "<- ",

      -- prefix for all the other hints (type, chaining)
      -- default: "=>"
      other_hints_prefix = "=> ",

      -- whether to align to the length of the longest line in the file
      max_len_align = false,

      -- padding from the left if max_len_align is true
      max_len_align_padding = 1,

      -- whether to align to the extreme right or not
      right_align = false,

      -- padding from the right if right_align is true
      right_align_padding = 7,

      -- The color of the hints
      highlight = "Comment",
    },

    -- options same as lsp hover / vim.lsp.util.open_floating_preview()
    hover_actions = {

      -- the border that is used for the hover window
      -- see vim.api.nvim_open_win()
      border = {
        { "╭", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╮", "FloatBorder" },
        { "│", "FloatBorder" },
        { "╯", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╰", "FloatBorder" },
        { "│", "FloatBorder" },
      },

      -- whether the hover action window gets automatically focused
      -- default: false
      auto_focus = true,
    },

    -- settings for showing the crate graph based on graphviz and the dot
    -- command
    crate_graph = {
      -- Backend used for displaying the graph
      -- see: https://graphviz.org/docs/outputs/
      -- default: x11
      backend = "x11",
      -- where to store the output, nil for no output stored (relative
      -- path from pwd)
      -- default: nil
      output = nil,
      -- true for all crates.io and external crates, false only the local
      -- crates
      -- default: true
      full = true,

      -- List of backends found on: https://graphviz.org/docs/outputs/
      -- Is used for input validation and autocompletion
      -- Last updated: 2021-08-26
      enabled_graphviz_backends = {
        "bmp",
        "cgimage",
        "canon",
        "dot",
        "gv",
        "xdot",
        "xdot1.2",
        "xdot1.4",
        "eps",
        "exr",
        "fig",
        "gd",
        "gd2",
        "gif",
        "gtk",
        "ico",
        "cmap",
        "ismap",
        "imap",
        "cmapx",
        "imap_np",
        "cmapx_np",
        "jpg",
        "jpeg",
        "jpe",
        "jp2",
        "json",
        "json0",
        "dot_json",
        "xdot_json",
        "pdf",
        "pic",
        "pct",
        "pict",
        "plain",
        "plain-ext",
        "png",
        "pov",
        "ps",
        "ps2",
        "psd",
        "sgi",
        "svg",
        "svgz",
        "tga",
        "tiff",
        "tif",
        "tk",
        "vml",
        "vmlz",
        "wbmp",
        "webp",
        "xlib",
        "x11",
      },
    },
  },

  -- all the opts to send to nvim-lspconfig
  -- these override the defaults set by rust-tools.nvim
  -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
  server = {
    -- standalone file support
    -- setting it to false may improve startup time
    standalone = true,
  }, -- rust-analyzer options

  -- debugging stuff
  dap = {
    adapter = {
      type = "executable",
      command = "lldb-vscode",
      name = "rt_lldb",
    },
  },
}

require('rust-tools').setup(opts)

-- Set inlay hints for the current buffer
require('rust-tools').inlay_hints.set()
-- Unset inlay hints for the current buffer
--require('rust-tools').inlay_hints.unset()
-- Enable inlay hints auto update and set them for all the buffers
require('rust-tools').inlay_hints.enable()
-- Disable inlay hints auto update and unset them for all buffers
--require('rust-tools').inlay_hints.disable()

-- RustRunnables
require('rust-tools').runnables.runnables()

-- RustExpandMacro
require'rust-tools'.expand_macro.expand_macro()
