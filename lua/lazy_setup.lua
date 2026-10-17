-- Starts lazy.nvim (the plugin manager) with AstroNvim, AstroCommunity packs and your plugins.
-- Your own settings are in lua/plugins/ (one file per topic) and lua/community.lua.

require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^6", -- AstroNvim major version. After changing it, run `:Lazy update` twice.
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here
      mapleader = " ", -- <Leader> is Space
      maplocalleader = ",",
      icons_enabled = true, -- set to false if you don't have a Nerd Font
      pin_plugins = nil, -- default: pin plugins to versions tested with this AstroNvim release
      update_notifications = true, -- remind you to run `:Lazy update` twice when pinned versions change
    },
  },
  { import = "community" },
  { import = "plugins" },
} --[[@as LazySpec]], {
  install = { colorscheme = { "catppuccin", "astrotheme", "habamax" } },
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      -- built-in Vim plugins you don't need
      disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "tohtml", "zipPlugin" },
    },
  },
} --[[@as LazyConfig]])
