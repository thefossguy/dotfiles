--------------------------------------------------------------------------------
-- the "spinny-snake" thingy at the bottom-right corner
-- https://github.com/j-hui/fidget.nvim
--------------------------------------------------------------------------------
require('fidget').setup({})

--------------------------------------------------------------------------------
-- tools for better development in Rust using Neovim's built-in LSP
-- https://github.com/simrat39/rust-tools.nvim
--------------------------------------------------------------------------------

require('rust-tools').setup({
  tools = {
    executor = require('rust-tools.executors').termopen, -- termopen, quickfix
    on_initialized = nil,
    reload_workspace_from_cargo_toml = true,
    inlay_hints = {
      auto = true,
      only_current_line = false,
      show_parameter_hits = true,
      parameter_hits_prefix = '<- ',
      other_hints_prefix = '=> ',
      max_len_align = false, -- whether to align to the length of the longest line in the file
      max_len_align_padding = 1, -- padding from the left if mex_len_align is true
      right_align = false, -- whether to align to the extreme right or not
      right_align_padding = 7, -- padding from the right if right_align is true
      highlight = 'comment', -- the color of the hints
    },
    hover_actions = {
      -- the border that is used for the hover window
      -- see vim.api.nvim_open_win()
      border = {
        { '╭', 'FloatBorder' },
        { '─', 'FloatBorder' },
        { '╮', 'FloatBorder' },
        { '│', 'FloatBorder' },
        { '╯', 'FloatBorder' },
        { '─', 'FloatBorder' },
        { '╰', 'FloatBorder' },
        { '│', 'FloatBorder' },
      },
      max_width = nil, -- nil means no max
      max_height = nil,
      auto_focus = false, -- whether the hover action window gets automatically focused
    },
    server = {
      standalone = true,
    },
    dap = {
      adapter = {
        type = 'executable',
        -- command = 'lldb',
        command = 'lldb-vscode',
        name = 'rt_lldb'
      },
    },
  },
})

require('rust-tools').inlay_hints.set()
require('rust-tools').inlay_hints.enable()
require('rust-tools').runnables.runnables()
require('rust-tools').expand_macro.expand_macro()


--------------------------------------------------------------------------------
-- a powerful fuzzy finder
-- https://github.com/nvim-telescope/telescope.nvim
--------------------------------------------------------------------------------

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ['C-u'] = false,
        ['C-d'] = false,
      }
    }
  },
})

require('nvim-mapper').setup({
  no_map = true, -- assign the default keymap '<leader>MM'
  search_path = os.getenv('HOME') .. '/.config/nvim/lua',
  action_on_enter = 'definition', -- definition, execute
})
require('telescope').load_extension('mapper')


vim.keymap.set('n', '<leader>?',       require('telescope.builtin').oldfiles,    { desc = 'Telescope: [?] find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers,     { desc = 'Telescope: [ ] ind existing buffers' })
vim.keymap.set('n', '<leader>sf',      require('telescope.builtin').find_files,  { desc = 'Telescope: [s]earch [f]iles' })
vim.keymap.set('n', '<leader>sh',      require('telescope.builtin').help_tags,   { desc = 'Telescope: [s]earch [h]elp' })
vim.keymap.set('n', '<leader>sw',      require('telescope.builtin').grep_string, { desc = 'Telescope: [s]earch current [w]ord' })
vim.keymap.set('n', '<leader>sg',      require('telescope.builtin').live_grep,   { desc = 'Telescope: [s]earch by [g]rep' })
vim.keymap.set('n', '<leader>sd',      require('telescope.builtin').diagnostics, { desc = 'Telescope: [s]earch [d]iagnostics' })
vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
    windblend = 10,
    previewer = false,
  }))
end, { desc = 'Telescope: [/] Fuzzily search in the current buffer' })


--------------------------------------------------------------------------------
-- incremental parsing system for programming tools
-- https://github.com/nvim-treesitter/nvim-treesitter
--------------------------------------------------------------------------------

require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'c',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    'nix',
    'regex',
    'rust',
    'toml',
    'vim',
  },
  -- install parsers synchronously
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<C-Space>',
      node_incremental = '<C-Space>',
      scope_incremental = '<C-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- automatically jump forward to the textobj
      keymaps = {
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
})

-- diagnostic keymaps
vim.keymap.set('n', '[d',        vim.diagnostic.goto_prev,  { desc = 'Go-to the previous diagnostic message' })
vim.keymap.set('n', ']d',        vim.diagnostic.goto_next,  { desc = 'Go-to the next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })


--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------

-- for Neovim's internal Lua "autocomplete"
require('neodev').setup({})

local lspconfig = require('lspconfig')

lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

lspconfig.bashls.setup({})
lspconfig.clangd.setup({})
lspconfig.nil_ls.setup({}) -- for the Nix expression language
lspconfig.ruff_lsp.setup({}) -- a Python linter, written in 🦀
lspconfig.rust_analyzer.setup({})


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabalities)


--------------------------------------------------------------------------------
-- the actual completion plugin
-- https://github.com/hrsh7th/nvim-cmp
--------------------------------------------------------------------------------

local luasnip = require('luasnip')
luasnip.config.setup({})

local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-Space>'] = cmp.mapping.complete({}),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.expand_or_jumpable(-1) then
        luasnip.expand_or_jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
})
