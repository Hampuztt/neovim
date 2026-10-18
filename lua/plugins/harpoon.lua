-- Harpoon: mark a few files and jump straight to them.
-- Keys (in keymaps.lua): <Leader>a add file, <Leader><Tab> menu, <Leader>1 ... <Leader>6 jump.
-- The marked files are the tabs at the top (drawn in heirline.lua). Each working folder has its own.

-- Show the tabline only while this folder has Harpoon files (or more than one Neovim tab is open).
local function update_tabline()
  local has_files = next(require("harpoon"):list().items) ~= nil
  vim.o.showtabline = (has_files or #vim.api.nvim_list_tabpages() > 1) and 2 or 0
  vim.cmd.redrawtabline()
end

---@type LazySpec
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy", -- loaded right after startup, so the tabs show the files you marked last time
  config = function()
    local harpoon = require "harpoon"
    harpoon:setup()
    harpoon:extend { -- the list changed: <Leader>a, or saving the menu
      ADD = update_tabline,
      REMOVE = update_tabline,
      REPLACE = update_tabline,
      LIST_CHANGE = update_tabline,
    }
    vim.api.nvim_create_autocmd({ "DirChanged", "TabNew", "TabClosed" }, {
      group = vim.api.nvim_create_augroup("harpoon_tabline", { clear = true }),
      desc = "Show the Harpoon tabs only when there are some",
      callback = update_tabline,
    })
    update_tabline()
  end,
}
