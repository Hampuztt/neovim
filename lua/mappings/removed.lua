return {
  "folke/which-key.nvim",
  opts = {
    defaults = {
      ["<Leader>xq"] = nil, -- disable quickfix list mapping
      ["<Leader>xl"] = nil, -- disable location list mapping
      -- disable for visual (x) mode
      ["<Leader>d"] = { mode = "x", nil },
      ["<Leader>D"] = { mode = "x", nil },
    },
  },
}
