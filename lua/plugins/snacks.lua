-- Snacks: the picker behind <Leader>f..., plus notifications, dashboard and more.  Docs: `:h snacks`

---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    indent = { enabled = false }, -- no indent guide lines
    picker = {
      sources = {
        files = { hidden = true, exclude = { "node_modules" } }, -- include dotfiles (.git is always skipped)
        grep = { hidden = true, exclude = { "node_modules" } },
      },
      win = {
        input = {
          keys = {
            -- Keep <C-u>/<C-d> as normal insert-mode keys in the search box (<C-u> clears it)
            -- instead of scrolling the result list.
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
      },
    },
  },
}
