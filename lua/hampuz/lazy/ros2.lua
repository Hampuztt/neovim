return {
    "ErickKramer/nvim-ros2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        autocmds = true,
        telescope = true,
        treesitter = true,
    },

    keys = {
        { "<leader>fra", "<cmd>Telescope ros2 actions<cr>",     desc = "ROS2: Active actions (info preview)" },
        { "<leader>fri", "<cmd>Telescope ros2 interfaces<cr>",  desc = "ROS2: Active interfaces (show preview)" },
        { "<leader>frn", "<cmd>Telescope ros2 nodes<cr>",       desc = "ROS2: Active nodes (info preview)" },
        { "<leader>frs", "<cmd>Telescope ros2 services<cr>",    desc = "ROS2: Active services (type preview)" },
        { "<leader>frt", "<cmd>Telescope ros2 topics_info<cr>", desc = "ROS2: Active topics (info preview)" },
        { "<leader>fre", "<cmd>Telescope ros2 topics_echo<cr>", desc = "ROS2: Echo topic" },
    }

}
