--------------------------------------------------------------------------------
-- code autocompletion
--------------------------------------------------------------------------------

vim.go.completeopt = "menuone,preview,noinsert,noselect"

local luasnip = require ("luasnip")
luasnip.config.setup ({})

-- completion setup with `nvim-cmp`
require ("cmp_nvim_lsp").default_capabilities (capabalities)
local cmp = require ("cmp")
cmp.setup ({
  snippet = {
    expand = function (args) luasnip.lsp_expand (args.body) end,
  },
  mapping = cmp.mapping.preset.insert ({
    ["<C-f>"] = cmp.mapping.scroll_docs (4),
    ["<C-d>"] = cmp.mapping.scroll_docs (-4),
    ["<C-Space>"] = cmp.mapping.complete ({}),
    ["<CR>"] = cmp.mapping.confirm ({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ["<Tab>"] = cmp.mapping (function (fallback)
      if cmp.visible () then
        cmp.select_next_item ()
      elseif luasnip.expand_or_jumpable () then
        luasnip.expand_or_jump ()
      else
        fallback ()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping (function (fallback)
      if cmp.visible () then
        cmp.select_prev_item ()
      elseif luasnip.expand_or_jumpable (-1) then
        luasnip.expand_or_jump (-1)
      else
        fallback ()
      end
    end, { "i", "s" }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  },
})
