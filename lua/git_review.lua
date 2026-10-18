-- Review everything your branch changed compared with another branch or commit (<Leader>gm / <Leader>gM,
-- see plugins/keymaps.lua). The changed files go in the quickfix list, and the current one is shown side
-- by side with its version at the point where your branch split off (git merge-base). That way, changes
-- made on the other branch after you branched don't show up as if you had undone them.
-- Uncommitted changes and new files you haven't `git add`ed yet are included. Changed submodules aren't
-- (they can't be shown side by side): the message when the review starts names them.

local M = {}
-- While a review is open: { ref, base, qf_id, tab, file_win, old_win, old_is_new }
local review

-- The keys, shown at the top of the changed-files list: the longest of these that fits the window
local hints = {
  " ]r [r  next/prev file  ·  ]c [c  next/prev change  ·  do  take the old version  ·  <Leader>gm  close",
  " ]r [r  next/prev file  ·  ]c [c  next/prev change  ·  <Leader>gm  close",
  " ]r [r  next/prev file  ·  <Leader>gm  close",
  " ]r [r  next/prev file",
}
local status_names = { M = "modified", A = "added", D = "deleted", R = "renamed", C = "copied", T = "type changed" }

local function git(root, args)
  local result = vim.system(vim.list_extend({ "git", "-C", root }, args), { text = true }):wait()
  if result.code ~= 0 then return nil, vim.trim(result.stderr) end
  return result.stdout
end

-- Quickfix items for every file changed since `base` (renames included) plus untracked new files, and
-- the paths of the changed submodules. user_data.old is the file's path at `base`, or nil for a new file.
local function changed_files(root, base)
  local items, submodules, listed = {}, {}, {}
  local fields = vim.split(git(root, { "diff", "--raw", "-z", "-M", base }) or "", "\0")
  local i = 1
  while fields[i] and fields[i] ~= "" do
    -- ":<old mode> <new mode> <old hash> <new hash> <status>", then the path (renames: old and new path)
    local old_mode, new_mode, status = fields[i]:match "^:(%d+) (%d+) %S+ %S+ (%u)"
    local path, old = fields[i + 1], fields[i + 1]
    if status == "R" or status == "C" then
      path, i = fields[i + 2], i + 3
    else
      i = i + 2
    end
    if old_mode == "160000" or new_mode == "160000" then -- a submodule
      submodules[#submodules + 1] = path
    else
      listed[path] = true
      items[#items + 1] = {
        filename = root .. "/" .. path,
        text = (status_names[status] or status) .. (path ~= old and (" from " .. old) or ""),
        user_data = { old = status ~= "A" and old or nil },
      }
    end
  end
  local untracked = git(root, { "ls-files", "--others", "--exclude-standard", "-z" }) or ""
  for _, path in ipairs(vim.split(untracked, "\0", { trimempty = true })) do
    if not listed[path] then -- (a file you `git rm --cached` is untracked, but already listed as deleted)
      items[#items + 1] = { filename = root .. "/" .. path, text = "new, not added to git yet", user_data = {} }
    end
  end
  table.sort(items, function(a, b) return a.filename < b.filename end)
  return items, submodules
end

-- A window in the review's tab showing a normal file (not the quickfix list, a terminal, Oil, ...)
local function normal_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(review.tab)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" and win ~= review.old_win then return win end
  end
end

local function close_old()
  if review.old_win and vim.api.nvim_win_is_valid(review.old_win) then vim.api.nvim_win_close(review.old_win, true) end
  review.old_win = nil
  if vim.api.nvim_win_is_valid(review.file_win) then vim.api.nvim_win_call(review.file_win, vim.cmd.diffoff) end
end

-- Show changed file number `idx` side by side with its old version, in the review's own windows.
local function show(idx)
  vim.api.nvim_set_current_tabpage(review.tab)
  close_old()
  if not vim.api.nvim_win_is_valid(review.file_win) then
    review.file_win = normal_win() or vim.api.nvim_get_current_win()
  end
  vim.api.nvim_set_current_win(review.file_win)
  vim.fn.setqflist({}, "a", { id = review.qf_id, idx = idx })
  local item = vim.fn.getqflist({ id = review.qf_id, items = 0 }).items[idx]
  vim.cmd.buffer(item.bufnr)
  local before = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    before[win] = true
  end
  local old = type(item.user_data) == "table" and item.user_data.old or nil
  if old then
    vim.cmd("Gvdiffsplit " .. vim.fn.fnameescape(review.base .. ":" .. old))
  else -- a new file: compare with an empty buffer
    vim.cmd "diffthis | rightbelow vnew | setlocal buftype=nofile bufhidden=wipe noswapfile | diffthis"
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not before[win] then review.old_win = win end
  end
  review.old_is_new = old == nil
  if review.old_win then vim.wo[review.old_win].winbar = "%{%v:lua.require'git_review'.label()%}" end
  vim.api.nvim_set_current_win(review.file_win)
end

-- The longest of `texts` that fits the window being drawn, or the shortest one cut to fit.
-- (Neovim itself would cut a too-long winbar off from the left, hiding the most important part.)
local function fitting(texts)
  local width = vim.api.nvim_win_get_width(vim.g.statusline_winid or 0)
  local text = vim.iter(texts):find(function(t) return vim.fn.strdisplaywidth(t) <= width end)
    or vim.fn.strcharpart(texts[#texts], 0, width)
  return (text:gsub("%%", "%%%%"))
end

-- The old version's winbar: what you're comparing with
function M.label()
  if not review then return "" end
  if review.old_is_new then return fitting { (" new file, not in %s"):format(review.ref), " new file" } end
  return fitting {
    (" %s, where your branch started (%s)"):format(review.ref, review.base:sub(1, 7)),
    (" %s, where your branch started"):format(review.ref),
    (" %s (old version)"):format(review.ref),
  }
end

-- The quickfix window's winbar: the keys, but only while it shows the review's list
function M.winbar()
  if not (review and vim.fn.getqflist({ id = 0 }).id == review.qf_id) then return "" end
  return fitting(hints)
end

local function set_hints(win) vim.wo[win].winbar = "%{%v:lua.require'git_review'.winbar()%}" end

local function forget()
  pcall(vim.api.nvim_del_augroup_by_name, "git_review")
  review = nil
end

-- Open = its file list still exists, and its old version or file list is still on screen. A review you
-- closed by hand (:cclose and :q) counts as closed, so <Leader>gm starts a new one straight away.
function M.is_open()
  if not review then return false end
  if vim.api.nvim_tabpage_is_valid(review.tab) and vim.fn.getqflist({ id = review.qf_id, nr = 0 }).nr ~= 0 then
    if review.old_win and vim.api.nvim_win_is_valid(review.old_win) then return true end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(review.tab)) do
      if vim.fn.win_gettype(win) == "quickfix" then return true end
    end
  end
  -- Closed by hand: just forget it, leaving your tabs and windows as they are. (Closing its old version
  -- already turned diff mode off in the file window: 'diffopt' has "closeoff".)
  forget()
  return false
end

-- Review the repo at `root` (default: the current file's) against `ref`
function M.start(ref, root)
  root = root or vim.fn.FugitiveWorkTree()
  if root == "" then return vim.notify("Not in a git repository", vim.log.levels.WARN) end
  local base, err = git(root, { "merge-base", ref, "HEAD" })
  if not base then return vim.notify("Can't compare with " .. ref .. ": " .. err, vim.log.levels.ERROR) end
  local items, submodules = changed_files(root, vim.trim(base))
  local left_out = #submodules > 0 and (" (changed submodules aren't shown: %s)"):format(table.concat(submodules, ", "))
    or ""
  if #items == 0 then return vim.notify("No changes compared with " .. ref .. left_out) end
  vim.fn.setqflist({}, " ", { title = "Review vs " .. ref, items = items })
  review = {
    ref = ref,
    base = vim.trim(base),
    qf_id = vim.fn.getqflist({ id = 0 }).id,
    tab = vim.api.nvim_get_current_tabpage(),
  }
  review.file_win = normal_win() or vim.api.nvim_get_current_win()
  vim.api.nvim_create_autocmd("FileType", { -- the keys again when the file list is reopened (:copen)
    group = vim.api.nvim_create_augroup("git_review", { clear = true }),
    pattern = "qf",
    callback = function()
      if vim.fn.win_gettype() == "quickfix" then set_hints(vim.api.nvim_get_current_win()) end
    end,
  })
  vim.cmd "botright copen"
  set_hints(vim.api.nvim_get_current_win())
  vim.notify(("Reviewing %d changed files vs %s%s"):format(#items, ref, left_out))
  show(1)
end

-- Next (1) or previous (-1) changed file
function M.move(delta)
  if not M.is_open() then return vim.notify "No review open (<Leader>gm starts one)" end
  -- Another command (e.g. <Leader>gh) may have put a newer list in the quickfix window: show ours again
  local current, ours = vim.fn.getqflist({ nr = 0 }).nr, vim.fn.getqflist({ id = review.qf_id, nr = 0 }).nr
  if ours < current then vim.cmd("silent colder " .. current - ours) end
  if ours > current then vim.cmd("silent cnewer " .. ours - current) end
  local list = vim.fn.getqflist { id = review.qf_id, idx = 0, size = 0 }
  local idx = list.idx + delta
  if idx < 1 or idx > list.size then
    return vim.notify(("%s changed file (%d of %d)"):format(delta > 0 and "Last" or "First", list.idx, list.size))
  end
  show(idx)
end

function M.stop()
  if not review then return end
  if vim.api.nvim_tabpage_is_valid(review.tab) then
    vim.api.nvim_set_current_tabpage(review.tab)
    close_old()
    vim.cmd.cclose()
  end
  forget()
end

return M
