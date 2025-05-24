return {
  "folke/which-key.nvim",
  opts = {
    defaults = {
      ["<leader>xq"] = nil, -- disable quickfix list mapping
      ["<leader>xl"] = nil, -- disable location list mapping
      -- disable for visual (x) mode
      ["<leader>d"] = { mode = "x", nil },
      ["<leader>D"] = { mode = "x", nil },
    },
  },
}
