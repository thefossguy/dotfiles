--------------------------------------------------------------------------------
-- misc plugin setup
--------------------------------------------------------------------------------

-- autoclose parentheses and quotes
require ("autoclose").setup ({
  keys = {
    -- LEGEND:
    -- close: toggle autoclosing
    -- escape: useful when pair consists of the same characters; when pressed
    --         twice, escape the sequence of pairs instead of **nesting**
    --         (disabled): pressing ** would result in **<cursor>** (nesting)
    --         (enabled): pressing ** would result in **<cursor> (!nesting)

    -- disable autoclosing of single quotes; this is insanity!
    ["'"] = { close = false, escape = false, pair = "''" },

    -- specific to markdown
    ["*"] = { close = true, escape = false, pair = "**", enabled_filetypes = { "markdown" } },
    ["_"] = { close = true, escape = false, pair = "__", enabled_filetypes = { "markdown" } },
    ["~"] = { close = true, escape = false, pair = "~~", enabled_filetypes = { "markdown" } },
  },
})

-- setup for `indent-blankline`
vim.cmd ([[highlight IndentBlanklineIndent1 guifg=#E06C75 gui=nocombine]])
vim.cmd ([[highlight IndentBlanklineIndent2 guifg=#E5C07B gui=nocombine]])
vim.cmd ([[highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]])
vim.cmd ([[highlight IndentBlanklineIndent4 guifg=#56B6C2 gui=nocombine]])
vim.cmd ([[highlight IndentBlanklineIndent5 guifg=#61AFEF gui=nocombine]])
vim.cmd ([[highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine]])
require ("ibl").setup ({})

-- the "spinny snake" thingy at the bottom right corner
require ("fidget").setup ({})

-- statusline
require ("lualine").setup ({
  options = {
    icons_enabled = true,
    theme = "nightfly",
    globalstatus = true,
    component_separators = {
      left = "",
      right = "",
    },
    section_separators = {
      left = "",
      right = "",
    },
    always_divide_middle = false,
    refres = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff" },
    lualine_c = {
      {
        "filename",
        file_status = true,
        icon_only = true,
        symbols = {
          modified = "[+]",
          readonly = "[RO]",
          unnamed = "[NO NAME]",
          newfile = "[NEW FILE]",
        },
      },
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        sections = { "error", "warn", "info", "hint" },
        colored = true,
        always_visible = true,
      },
    },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "searchcount", "progress" },
    lualine_z = { "location" },
  },
})

--
require ("gitsigns").setup ({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "" },
  },
  signcolumn = true, -- show the sings (set above) in the "gutter" (before the numbers in the numberline)
  numhl = true, -- highlight the numbers for lines that are modified
})

-- plugin to style commented out code
require ("Comment").setup ({
  padding = true, -- whether to add a space between the comment and the line
  sticky = true, -- whether the cursor should stay at its position
  ignore = nil, -- lines to be ignored while (un)commenting
  toggler = {
    line = "gcc", -- line comment toggle keymap
    block = "gbc", -- block comment toggle keymap
  },
  opleader = {
    -- LHS of operator-padding mappings in NORMAL and VISUAL modes
    line = "gc",
    block = "gb",
  },
  extra = {
    -- LHS of the extra mapping
    above = "gcO",
    below = "gco",
    eol = "gcA",
  },
  mappings = {
    -- whether enable keymappings
    basic = true,
    extra = true,
  },
  pre_hook = nil, -- function to call before (un)comment
  post_hook = nil, -- function to call after (un)comment
})

--------------------------------------------------------------------------------
-- theme setup
--------------------------------------------------------------------------------
require ("catppuccin").setup ({
  flavour = "mocha", -- latte, frappe, macciato, mocha
  background = {
    light = "latte",
    dark = "mocha",
  },
  transparent_background = false,
  show_end_of_buffer = false,
  term_colors = false,
  dim_inactive = {
    enabled = false,
    shade = "dark",
    percentage = 0.15,
  },
  no_italic = false, -- force no_italic
  no_bold = false,
  styles = {
    -- `:h highlight-args`
    comments = { "italic" },
    conditionals = { "italic" },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = { "bold" },
    numbers = {},
    booleans = { "italic", "bold" },
    properties = {},
    types = {},
    operators = { "bold" },
  },
  color_overrides = {},
  highlight_overrides = {
    mocha = function (C)
      return {
        TabLineSel = { bg = C.pink },
        CmpBorder = { fg = C.surface },
        Pmenu = { bg = C.none },
        TelescopeBorder = { link = "FloatBorder" },
      }
    end,
  },
  custom_highlights = {},
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = false,
    telescope = true,
    --markdown = true,
    mason = true,
  },
})
vim.cmd.colorscheme ("catppuccin")
