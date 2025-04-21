return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000, -- Ensures it loads first
        lazy = false, -- Load immediately at startup
        opts = { flavour = "mocha" }, -- Lazy.nvim will call setup() automatically
        init = function()
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },
}

