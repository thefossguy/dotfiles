require('autoclose').setup({
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
    ['*'] = { close = true, escape = false, pair = '**', enabled_filetypes = { 'markdown' } },
    ['_'] = { close = true, escape = false, pair = '__', enabled_filetypes = { 'markdown' } },
    ['~'] = { close = true, escape = false, pair = '~~', enabled_filetypes = { 'markdown' } },
  },
})
require('ibl').setup({})

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
