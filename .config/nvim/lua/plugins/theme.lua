require('catppuccin').setup({
  flavour = 'mocha', -- latte, frappe, macciato, mocha
  background = {
    light = 'latte',
    dark = 'mocha',
  },
  transparent_background = false,
  show_end_of_buffer = false,
  term_colors = false,
  dim_inactive = {
    enabled = false,
    shade = 'dark',
    percentage = 0.15,
  },
  no_italic = false, -- force no_italic
  no_bold = false,
  styles = {
    -- `:h highlight-args`
    comments = { 'italic' },
    conditionals = { 'italic' },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = { 'bold' },
    numbers = {},
    booleans = { 'italic', 'bold' },
    properties = {},
    types = {},
    operators = { 'bold' },
  },
  color_overrides = {},
  highlight_overrides = {
    mocha = function(C)
      return {
        TabLineSel = { bg = C.pink },
        CmpBorder = {fg = C.surface },
        Pmenu = { bg = C.none },
        TelescopeBorder = { link = 'FloatBorder' },
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
