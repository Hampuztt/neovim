-- Oil: edit folders like a normal buffer (open with <Leader>o).
-- The keys below only work inside an Oil buffer. Press g? there for help.

-- Text at the top of Oil windows: the folder you're in plus a few key hints.
function _G.oil_winbar()
  local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(buf)
  local hint = "     [g?] Help, [C-p] Preview, [<Leader>v/h] open in split"
  return (dir and vim.fn.fnamemodify(dir, ":~") or vim.api.nvim_buf_get_name(buf)) .. hint
end

local show_details = false

---@type LazySpec
return {
  {
    "stevearc/oil.nvim",
    lazy = false, -- so `nvim some/folder` opens Oil
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      use_default_keymaps = false,
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<Leader>v"] = { "actions.select", opts = { vertical = true } },
        ["<Leader>h"] = { "actions.select", opts = { horizontal = true } },
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["<Leader>r"] = { "actions.refresh", nowait = true }, -- nowait: don't wait for <Leader>rr
        ["-"] = { "actions.parent", mode = "n" },
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        ["r"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
        ["t"] = {
          callback = function()
            show_details = not show_details
            if show_details then
              require("oil").set_columns { "icon", "permissions", "size", "mtime" }
            else
              require("oil").set_columns { "icon" }
            end
          end,
          desc = "Toggle file details (size, date, permissions)",
        },
      },
      view_options = { show_hidden = true },
      win_options = { winbar = "%!v:lua.oil_winbar()" },
    },
  },
  { "nvim-neo-tree/neo-tree.nvim", enabled = false }, -- Oil replaces AstroNvim's file tree
}
