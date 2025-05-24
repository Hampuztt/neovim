function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  local help_hint = "     [g?] Help, [C-p] Preview, [<Leader>v/h] open " -- Add more if needed
  if dir then
    return vim.fn.fnamemodify(dir, ":~") .. help_hint
  else
    return vim.api.nvim_buf_get_name(0) .. help_hint
  end
end

local detail = false
return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    keymaps = {
      ["g?"] = { "actions.show_help", mode = "n" },
      ["<CR>"] = "actions.select",
      ["<Leader>v"] = { "actions.select", opts = { vertical = true } },
      ["<Leader>h"] = { "actions.select", opts = { horizontal = true } },
      ["<C-t>"] = { "actions.select", opts = { tab = true } },
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = { "actions.close", mode = "n" },
      ["<Leader>r"] = "actions.refresh",
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
          detail = not detail
          if detail then
            require("oil").set_columns { "icon", "permissions", "size", "mtime" }
          else
            require("oil").set_columns { "icon" }
          end
        end,
        desc = "Toggle file detail view",
      },
    },
    use_default_keymaps = false,
    view_options = {
      show_hidden = true,
    },
    win_options = {
      winbar = "%!v:lua.get_oil_winbar()",
    },
  },

  -- Optional dependencies
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
