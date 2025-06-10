vim.keymap.set("n", "<leader>o", "<CMD>Oil<CR>", { desc = "Open Oil" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })
vim.o.scrolloff = 20

-- run files with leader x
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<leader>x", ":source %<CR>")
vim.keymap.set("v", "<leader>x", ":.lua<CR>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<C-;>", "<cmd>:w<CR>")

-- Paste from system clipboard
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>P", '"+P', { desc = "Paste before cursor from system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Normal mode only, since "D" deletes to end of line
vim.keymap.set("n", "<leader>D", '"+D', { desc = "Delete to end of line (system clipboard)" })
--  this disables auto use of system clipboard
--  this disables auto use of system clipboard
--  this disables auto use of system clipboard

-- search and replace thing
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- should be set by astro instead but im lazy
vim.api.nvim_set_keymap("i", "kk", "<Esc>", { noremap = true, silent = true })

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>rr", "<cmd>AstroReload<cr>", { desc = "Reload AstroNvim config" })

vim.opt.clipboard = ""

vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  callback = function()
    vim.opt_local.cursorline = true
  end,
})

