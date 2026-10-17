-- Runs the current file in a terminal split at the bottom. Used by <F5> (see plugins/keymaps.lua).
-- To support another language, add a line: filetype = "command".
--   {file} is replaced by the file's path,
--   {bin}  by a temporary path for compiled programs (so no a.out lands in your project).
local runners = {
  python = "python3 {file}",
  cpp = "g++ -std=c++17 -Wall -g {file} -o {bin} && {bin}",
  -- c = "gcc -Wall -g {file} -o {bin} && {bin}",
  -- lua = "lua {file}",
  -- sh = "bash {file}",
}

return function()
  local runner = runners[vim.bo.filetype]
  if not runner then
    vim.notify("<F5>: no runner for filetype '" .. vim.bo.filetype .. "' (see lua/run_file.lua)", vim.log.levels.WARN)
    return
  end
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("<F5>: save the file first (:w name)", vim.log.levels.WARN)
    return
  end
  vim.cmd "noautocmd write"
  local bin = vim.fn.tempname()
  local cmd = runner
    :gsub("{file}", function() return vim.fn.shellescape(file) end)
    :gsub("{bin}", function() return vim.fn.shellescape(bin) end)
  vim.cmd "botright new"
  vim.fn.jobstart(cmd, { term = true })
  vim.cmd "startinsert"
end
