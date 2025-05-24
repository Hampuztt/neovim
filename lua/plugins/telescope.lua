return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",

    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",  -- Ensure fzf-native is built
        },
    },
    opts = {
        defaults = {
            file_ignore_patterns = { "node_modules", ".git/" },
            mappings = {
                i = {
                    ["<C-u>"] = false,
                    ["<C-d>"] = false,
                },
            },
        },
        pickers = {
            find_files = { hidden = true },
            live_grep = { additional_args = function() return { "--hidden" } end },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
        },
    },
    keys = {
        { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Telescope find files" },
        {
            "<leader>fi",
            function()
                local cwd = vim.bo.filetype == "netrw" and vim.fn.getcwd() or vim.fn.expand("%:p:h")
                require("telescope.builtin").find_files({ cwd = cwd })
            end,
            desc = "Telescope find files (context-aware)",
        },
        { "<leader>fw", function() require("telescope.builtin").live_grep() end, desc = "Telescope live grep" },
        { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Telescope buffers" },
        { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Telescope help tags" },
    },
    init = function()
        require("telescope").load_extension("fzf")  -- Load the fzf extension
    end,
}

