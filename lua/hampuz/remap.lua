vim.g.mapleader = " "
vim.keymap.set("n", "<leader>o", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- vim.keymap.set({ "n", "x" }, "<leader>p", [["0p]], { desc = "paste from yank register" })
-- Yank into system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y') -- yank motion
vim.keymap.set({'n', 'v'}, '<leader>Y', '"+Y') -- yank line

-- Delete into system clipboard
vim.keymap.set({'n', 'v'}, '<leader>d', '"+d') -- delete motion
vim.keymap.set({'n', 'v'}, '<leader>D', '"+D') -- delete line

-- Paste from system clipboard
vim.keymap.set('n', '<leader>p', '"+p')  -- paste after cursor
vim.keymap.set('n', '<leader>P', '"+P')  -- paste before cursor

vim.keymap.set("n", "Q", "<nop>")
