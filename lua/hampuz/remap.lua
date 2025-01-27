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



--vim.keymap.set('n', '<C-h>', '<C-w>h')  -- Faster navigation
--vim.keymap.set('n', '<C-j>', '<C-w>j')  -- Faster navigation
--vim.keymap.set('n', '<C-k>', '<C-w>k')  
--vim.keymap.set('n', '<C-l>', '<C-w>l') 

-- vim.keymap.set('n', '<leader>c', ':ex ~./config/nvim/<CR>', { noremap = true, silent = true })
--
-- vim.api.nvim_set_keymap('n', '<F5>', ':w<CR>:!clear<CR>:!python3 %<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', 'kk', '<Esc>', { noremap = true, silent = true })
vim.keymap.set("n", "Q", "<nop>")

-- vim.api.nvim_set_keymap('n', '<F5>', ':w<CR>:terminal clear && python3 %; <CR>i', { noremap = true, silent = true })


vim.keymap.set('n', '<F5>', function()
    -- Save the path to the current file
    vim.cmd('noautocmd write')
    local file_path = vim.api.nvim_buf_get_name(0)

    -- Determine the file type
    local file_type = vim.bo.filetype

    -- Open a horizontal split at the bottom
    vim.cmd('botright new')

    -- Check the file type and execute the appropriate command
    if file_type == 'cpp' then
        -- Compile and run the C++ file
        vim.fn.termopen('g++ "$source_file" && ./a.out', {
            env = {
                source_file = file_path,
            },
        })
    elseif file_type == 'python' then
        -- Run the Python file
        vim.fn.termopen('python3 "$source_file"', {
            env = {
                source_file = file_path,
            },
        })
    else
        -- If the file type is unsupported, print an error and close the terminal
        vim.api.nvim_err_writeln('Unsupported file type: ' .. file_type)
        vim.cmd('bd!') -- Close the terminal buffer
        return
    end

    -- Jump to the end of the terminal buffer to follow output
    vim.cmd('$')

    -- Enter insert mode for easier interaction
    vim.cmd('startinsert')
end)

vim.keymap.set('n', '<F6>', function()
    vim.cmd("lua require('cmp').setup.buffer({ enabled = false })")
end)


