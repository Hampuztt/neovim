-- Leave insert mode by quickly typing jj, jk or kk.
-- Unlike a normal mapping, a single j or k shows up right away (no waiting).

---@type LazySpec
return {
  "max397574/better-escape.nvim",
  opts = {
    timeout = 300, -- ms allowed between the two keys
    mappings = {
      i = {
        j = { j = "<Esc>", k = "<Esc>" },
        k = { k = "<Esc>" },
      },
    },
  },
}
