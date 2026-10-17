-- Git: vim-fugitive for :Git commands (keys <Leader>gs/gS/gd/gb/gL in keymaps.lua)
-- and gitsigns for the +/-/~ signs next to the line numbers.

---@type LazySpec
return {
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gvdiffsplit", "Gdiffsplit", "Gread", "Gwrite", "Gedit", "GBrowse" },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function() end, -- show the signs, but don't add gitsigns' keybindings
    },
  },
}
