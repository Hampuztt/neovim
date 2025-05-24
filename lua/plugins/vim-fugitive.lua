return {
    "tpope/vim-fugitive",
    keys = {
        { "<leader>gs", "<cmd>vert Git<cr>",           desc = "Git status" },
        { "<leader>gS", "<cmd>vert Git<cr>",           desc = "Git status (horizontal)" },
-- { "<leader>gs", "<cmd>Git | only<cr>", desc = "Git status (fullscreen)" },

        -- { "<leader>gc", "<cmd>G commit<cr>", desc = "Git commit" },
        { "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "Git diff split" },
        { "<leader>gb", "<cmd>Git blame<cr>",   desc = "Git blame" },
        { "<leader>gl", "<cmd>G log<cr>",       desc = "Git log" },
    },
}
