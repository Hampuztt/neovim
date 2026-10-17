-- Runs the current file in a terminal split at the bottom. Used by <F5> (see plugins/keymaps.lua).
-- To support another language, add a line: filetype = "command", where %s is the file path.
local runners = {
  python = "python3 %s",
  cpp = "g++ %s && ./a.out",
  -- c = "gcc %s && ./a.out",
  -- lua = "lua %s",
  -- sh = "bash %s",
}

return function()
  local runner = runners[vim.bo.filetype]
  if not runner then
    vim.notify("<F5>: no runner for filetype '" .. vim.bo.filetype .. "' (see lua/run_file.lua)", vim.log.levels.WARN)
    return
  end
  vim.cmd "noautocmd write"
  local cmd = runner:format(vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))
  vim.cmd "botright new"
  vim.fn.jobstart(cmd, { term = true })
  vim.cmd "startinsert"
end
