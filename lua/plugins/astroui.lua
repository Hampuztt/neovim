-- Colorscheme and highlight tweaks.  Docs: `:h astroui`
-- Try other themes with <Leader>ft. The statusline is in heirline.lua.

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "catppuccin-mocha",
      highlights = {
        init = { -- changes applied to every colorscheme, e.g.
          -- Normal = { bg = "#000000" },
        },
      },
    },
  },
  { "catppuccin/nvim", name = "catppuccin", opts = {} },
}
