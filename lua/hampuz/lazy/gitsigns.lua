return {
    "lewis6991/gitsigns.nvim",
    config = function()
        require('gitsigns').setup {
            on_attach = function(bufnr)

                -- Toggle diff of current file
                local gitsigns = require('gitsigns')

                -- Toggle diff of current file
                -- vim.keymap.set('n', '<leader>hd', function() gitsigns.diffthis() end, { buffer = bufnr, desc = "Git Diff (Index)" })
                -- vim.keymap.set('n', '<leader>hD', function() gitsigns.diffthis('~') end, { buffer = bufnr, desc = "Git Diff (Last Commit)" })
                --
                -- -- Toggle showing deleted lines
                -- vim.keymap.set('n', '<leader>td', function() gitsigns.toggle_deleted() end, { buffer = bufnr, desc = "Toggle Deleted Lines" })
                --
                -- -- Toggle word diff (inline word-level changes)
                -- vim.keymap.set('n', '<leader>tw', function() gitsigns.toggle_word_diff() end, { buffer = bufnr, desc = "Toggle Word Diff" })
            end
        }
    end
}
