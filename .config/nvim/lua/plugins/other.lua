require('Comment').setup({
  padding = true, -- add a space between the comment and the line
  sticky = true, -- weather the cursor should stay at its position
  ignore = nil, -- lines to be ignored while (un)commenting
  toggler = {
    line = 'gcc', -- line comment toggle keymap
    block = 'gbc', -- block comment toggle keymap
  },
  opleader = {
    -- LHS of operator-padding mappings in NORMAL and VISUAL modes
    line = 'gc',
    block = 'gb',
  },
  extra = {
    -- LHS of the extra mapping
    above = 'gcO',
    below = 'gco',
    eol = 'gcA',
  },
  mappings = {
    -- enable keymappings
    basic = true,
    extra = true,
  },
  pre_hook = nil, -- function to call before (un)comment
  post_hook = nil, -- function to call after (un)comment
})

require('indent_blankline').setup({
  show_current_context = true,
  show_current_context_start = true,
  space_char_blankline = ' ',
  char_highlight_list = {
    'IndentBlanklineIndent1',
    'IndentBlanklineIndent2',
    'IndentBlanklineIndent3',
    'IndentBlanklineIndent4',
    'IndentBlanklineIndent5',
    'IndentBlanklineIndent6',
  },
})

require('autoclose').setup({
  keys = {
    ["*"] = {
      escape = true,
      close = true,
      pair = "**",
    },
    ["^"] = {
      escape = true,
      close = true,
      pair = "^^",
    },
    ["~"] = {
      escape = true,
      close = true,
      pair = "~~",
    },
    --[[ remove escape for '<>'
    ["<"] = {
      escape = false,
      close = false,
      pair = "<>",
    },
    [">"] = {
      escape = false,
      close = false,
      pair = "<>",
    },
    -- ]]
  },
})
