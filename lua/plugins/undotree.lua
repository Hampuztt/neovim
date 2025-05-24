return {
    "mbbill/undotree", enabled = false,
    config = function()
        -- Optional: Automatically enable persistent undo
        vim.o.undofile = true
        vim.o.undodir = vim.fn.stdpath("data") .. "/undodir"
        vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle UndoTree" })
    end
}
