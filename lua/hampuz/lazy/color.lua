return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000, -- Ensure it loads early
        config = function()
            -- Runs after the plugin is fully loaded
            require("catppuccin").setup({ flavour = "mocha" })
            vim.cmd("colorscheme catppuccin-mocha")
        end,
    },
}

