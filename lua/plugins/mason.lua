-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",
        "pyrefly",

        -- install formatters
        "stylua",

        -- install debuggers
        "debugpy",

        -- install any other package
        "tree-sitter-cli",
      },
    },
  },

{
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")

    dap.adapters.cpp = {
      type = 'executable',
      command = 'gdb',
      args = { '-i', 'dap' },
    }

    dap.configurations.cpp = {
      {
        name = "Attach to Running Lidar Node",
        type = "cpp",
        request = "attach",
        pid = require('dap.utils').pick_process,
        cwd = vim.fn.getcwd(),
      },
    }

    dap.configurations.c = dap.configurations.cpp
  end,
}
}
