-- Jump to start and end of line using the home row keys
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")

-- remap uppercase J and K to their lowercase counterparts;
-- been bitten too many times
vim.keymap.set("n", "J", "j")
vim.keymap.set("n", "K", "k")

-- move between buffers using Ctrl+[h,j,k,l]
vim.keymap.set({"n", "v", "i", "c"}, "<C-H>", "<C-W><C-H>")

-- neovide (GUI) clipboard
vim.keymap.set({"n", "i"}, "<C-S-V>", "\"+P")
