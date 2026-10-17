-- Harpoon: mark a few files and jump straight to them.
-- Keys (in keymaps.lua): <Leader>a add file, <Leader><Tab> menu, <Leader>1 ... <Leader>6 jump.

---@type LazySpec
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = true, -- loaded the first time you press one of its keys
  config = function() require("harpoon"):setup() end,
}
