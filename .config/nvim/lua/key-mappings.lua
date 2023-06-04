-- jump to start and end of line using the home row keys
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', '$')

-- remap uppercase J and K to move screen down/up one line respectively
-- been bitten too many times
vim.keymap.set('n', 'K', '1<C-u>', { remap = true })
vim.keymap.set('n', 'J', '1<C-d>', { remap = true })

-- move between buffers using Ctrl+[h,j,k,l]
vim.keymap.set({'n', 'v', 'i', 'c'}, '<C-h>', '<C-n><C-w>h')
vim.keymap.set({'n', 'v', 'i', 'c'}, '<C-j>', '<C-n><C-w>j')
vim.keymap.set({'n', 'v', 'i', 'c'}, '<C-k>', '<C-n><C-w>k')
vim.keymap.set({'n', 'v', 'i', 'c'}, '<C-l>', '<C-n><C-w>l')

-- neovide (GUI) clipboard
vim.keymap.set({'n', 'i'}, '<C-S-V>', '\'+P')

-- idk what this is
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

-- remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- `cargo run` when '<leader>[r|R]'
vim.keymap.set('n', '<leader>r', ':!cargo run<CR>')
vim.keymap.set('n', '<leader>R', ':!cargo run<CR>')

-- toggle nvim-tree with '<leader>t'
vim.keymap.set('n', '<leader>t', function()
  require('nvim-tree.api').tree.toggle()
end)
vim.keymap.set('n', 'T', function()
  require('nvim-tree.api').tree.toggle()
end)
