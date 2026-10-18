-- Git: vim-fugitive does the work (status window, diffs, blame, log; keys <Leader>g... in keymaps.lua).
-- gitsigns draws the signs next to the line numbers and the one-line blame popup (<Leader>gl).

-- The files that a discard on line `lnum` of the status window touches (full paths): the file on that
-- line, or the file whose expanded diff (=) the line is in.
local function status_files(lnum, root)
  while lnum > 1 and vim.fn.getline(lnum):match "^[@+ %-]" do -- inside an expanded diff: its file line
    lnum = lnum - 1
  end
  local path = vim.fn.getline(lnum):match "^[MADRCTU?] (.+)$"
  if not path then return {} end
  local old, new = path:match "^(.-) %-> (.+)$" -- renames: "old -> new"
  return vim.tbl_map(function(p) return root .. "/" .. p end, old and { old, new } or { path })
end

-- x / X in the status window: discard like fugitive's X, but so that `u` in the file brings the change
-- back. The files are loaded into buffers first and reloaded after the discard, which makes the discard
-- an undoable change in them. (A deleted new file: `u` brings its text back, then :w recreates it.)
local function discard()
  local first, last = vim.fn.line "v", vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  local root, bufs = vim.fn.FugitiveWorkTree(), {}
  for lnum = first, last do
    for _, file in ipairs(status_files(lnum, root)) do
      if vim.fn.filereadable(file) == 1 then
        local buf = vim.fn.bufadd(file)
        if vim.bo[buf].modified then
          return vim.notify(vim.fn.fnamemodify(file, ":~:.") .. " has unsaved changes; save or undo them first")
        end
        vim.fn.bufload(buf)
        bufs[#bufs + 1] = buf
      end
    end
  end
  local count = vim.v.count > 0 and tostring(vim.v.count) or ""
  vim.api.nvim_feedkeys(count .. vim.keycode "<Plug>fugitive:X", "mx", false)
  local undoreload = vim.o.undoreload
  vim.o.undoreload = -1 -- reloads can be undone in long files too (by default only up to 10000 lines)
  for _, buf in ipairs(bufs) do
    if vim.fn.filereadable(vim.api.nvim_buf_get_name(buf)) == 1 then
      vim.cmd.checktime(buf) -- reload the discarded version (an undoable change)
    else -- the discard deleted the file (a new file): empty the buffer, also undoably
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
      vim.bo[buf].modified = false
    end
  end
  vim.o.undoreload = undoreload
  if #bufs > 0 then vim.notify "Discarded. To get it back: open the file, press u, then :w" end
end

---@type LazySpec
return {
  {
    "tpope/vim-fugitive",
    lazy = false, -- loaded at start, so every :G... command (e.g. :0Gclog) works straight away
    dependencies = { "tpope/vim-rhubarb" }, -- :GBrowse opens the file / line / commit on GitHub
    -- History lists (<Leader>gh, :Gclog): date before each commit message, e.g. "2026-10-17 Fix parser"
    init = function() vim.g.fugitive_summary_format = "%as %s" end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fugitive", -- the status window
        callback = function(args)
          for _, key in ipairs { "x", "X" } do
            vim.keymap.set(
              { "n", "x" },
              key,
              discard,
              { buffer = args.buf, desc = "Discard change (u in the file undoes it)" }
            )
          end
        end,
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function() end, -- no AstroNvim gitsigns keys; your git keys are in keymaps.lua
    },
  },
}
