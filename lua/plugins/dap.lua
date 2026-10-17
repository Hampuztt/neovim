-- Debugger: AstroNvim's debugger (nvim-dap + its UI) is turned off, along with its keys
-- (<Leader>d..., F9/F10/F11). Delete this file to get it back.
-- Your old gdb "Attach to Running Lidar Node" setup is in git history (lua/plugins/mason.lua).

---@type LazySpec
return {
  { "mfussenegger/nvim-dap", enabled = false },
  { "rcarriga/nvim-dap-ui", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
  { "rcarriga/cmp-dap", enabled = false },
}
