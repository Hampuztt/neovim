-- Move between Neovim splits and tmux panes with the same keys: <C-h/j/k/l> (set in keymaps.lua).
-- The tmux half is the christoomey/vim-tmux-navigator plugin in ~/.config/tmux/tmux.conf.

---@type LazySpec
return {
  "christoomey/vim-tmux-navigator",
  cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight", "TmuxNavigatePrevious" },
  init = function() vim.g.tmux_navigator_no_mappings = 1 end, -- keys come from keymaps.lua
}
