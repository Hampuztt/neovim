-- which-key: the popup listing the next possible keys after you press <Leader> (or g, [, ], ...).

---@type LazySpec
return {
  "folke/which-key.nvim",
  opts = {
    win = {
      no_overlap = true, -- never cover the cursor
      padding = { 1, 2 }, -- top/bottom, left/right
      title = true,
      title_pos = "center",
      zindex = 500,
    },
  },
}
