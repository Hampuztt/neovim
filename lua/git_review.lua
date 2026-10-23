-- Review everything your branch changed compared with another branch or commit (<Leader>gr, see
-- plugins/keymaps.lua). The review opens in its own tab: the changed files are listed at the bottom, and
-- the current one is shown with its version at the point where your branch split off (git merge-base)
-- on the left. That way, changes made on the other branch after you branched don't show up as if you
-- had undone them.
-- Uncommitted changes and new files you haven't `git add`ed yet are included. Changed submodules aren't
-- (they can't be shown side by side): the message when the review starts names them.
-- Closing the review closes its tab, and the files it opened that you didn't change or have open already.

local M = {}
-- While a review is open: { ref, base, root, qf_id, tab, from_tab, file_win, old_win, old_is_new,
-- current = the file shown { path, text, idx, size }, keep = buffers that were open before the review }
local review

-- The keys, shown at the top of the changed-files list: the longest of these that fits the window
local hints = {
  " ]e [e  next/prev change  ·  ]r [r  next/prev file  ·  do  take the old version  ·  <Leader>gr  close",
  " ]e [e  next/prev change  ·  ]r [r  next/prev file  ·  <Leader>gr  close",
  " ]e [e  next/prev change  ·  ]r [r  next/prev file",
  " ]e [e  next/prev change",
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

-- Close the old version and end the diff. If its window is the only one left in the review's tab (you
-- closed the others by hand), closing it would close the tab: it becomes the file window instead.
local function close_old()
  local old = review.old_win
  review.old_win = nil
  if old and vim.api.nvim_win_is_valid(old) then
    if vim.fn.winlayout()[1] == "leaf" then
      review.file_win = old
    else
      vim.api.nvim_win_close(old, true)
    end
  end
  if vim.api.nvim_win_is_valid(review.file_win) then vim.api.nvim_win_call(review.file_win, vim.cmd.diffoff) end
end

-- Put the cursor on the first change in the file ("first") or the last one ("last"). A ]c or [c that
-- finds nothing leaves the cursor where it is, so these also work with one change, or none.
local function land(where)
  if where == "first" then
    vim.cmd "normal! gg"
    vim.cmd "normal! ]c" -- skips a change on line 1 ...
    vim.cmd "normal! [c" -- ... so step back to it
  else
    vim.cmd "normal! G"
    vim.cmd "normal! [c"
    vim.cmd "normal! ]c"
  end
end

-- Show changed file number `idx` next to its old version, in the review's own windows, with the cursor
-- on its first change (`where` = "last": on its last change).
local function show(idx, where)
  vim.api.nvim_set_current_tabpage(review.tab)
  close_old()
  if
    not (vim.api.nvim_win_is_valid(review.file_win) and vim.api.nvim_win_get_tabpage(review.file_win) == review.tab)
  then
    review.file_win = normal_win()
    if not review.file_win then -- you closed every file window in the review's tab: a new one above the list
      vim.cmd "topleft new | setlocal bufhidden=wipe"
      review.file_win = vim.api.nvim_get_current_win()
    end
  end
  vim.api.nvim_set_current_win(review.file_win)
  vim.fn.setqflist({}, "a", { id = review.qf_id, idx = idx })
  local list = vim.fn.getqflist { id = review.qf_id, items = 0, size = 0 }
  local item = list.items[idx]
  vim.cmd.buffer(item.bufnr)
  local name = vim.api.nvim_buf_get_name(item.bufnr)
  local path = vim.fs.relpath(review.root, name) or vim.fn.fnamemodify(name, ":~:.")
  review.current = { path = path, text = item.text, idx = idx, size = list.size }
  local before = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    before[win] = true
  end
  local old = type(item.user_data) == "table" and item.user_data.old or nil
  if old then
    vim.cmd("leftabove Gvdiffsplit " .. vim.fn.fnameescape(review.base .. ":" .. old))
  else -- a new file: compare with an empty buffer
    vim.cmd "diffthis | leftabove vnew | setlocal buftype=nofile bufhidden=wipe noswapfile | diffthis"
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not before[win] then review.old_win = win end
  end
  review.old_is_new = old == nil
  if review.old_win then vim.wo[review.old_win].winbar = "%{%v:lua.require'git_review'.label()%}" end
  -- A label above your version too, which also keeps the lines of both sides level with each other
  vim.wo[review.file_win].winbar = "%{%v:lua.require'git_review'.file_label()%}"
  vim.api.nvim_set_current_win(review.file_win)
  land(where or "first")
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

-- Your version's winbar: which file, what happened to it, and how far into the review you are.
-- (While a winbar's %{} is worked out, its window is the current one.)
function M.file_label()
  local current = review and review.current
  if not current or vim.api.nvim_get_current_win() ~= review.file_win then return "" end
  local count = ("file %d of %d"):format(current.idx, current.size)
  return fitting {
    (" %s  ·  %s  ·  %s"):format(current.path, current.text, count),
    (" %s  ·  %s"):format(current.path, count),
    " " .. count,
  }
end

-- The quickfix window's winbar: the keys, but only while it shows the review's list
local function showing_ours() return review ~= nil and vim.fn.getqflist({ id = 0 }).id == review.qf_id end
function M.winbar() return showing_ours() and fitting(hints) or "" end

-- The changed-files window: the keys at the top, <CR> shows the file under the cursor, q closes the
-- review. (The quickfix window is used by other lists too: there, <CR> and q do what they always do.)
local function set_up_list(win)
  vim.wo[win].winbar = "%{%v:lua.require'git_review'.winbar()%}"
  local buf = vim.api.nvim_win_get_buf(win)
  vim.keymap.set("n", "<CR>", function()
    if not showing_ours() then return vim.api.nvim_feedkeys(vim.keycode "<CR>", "n", false) end
    show(vim.fn.line ".")
  end, { buffer = buf, desc = "Review: show this file" })
  vim.keymap.set("n", "q", function()
    if not showing_ours() then return vim.cmd.close() end
    M.stop()
  end, { buffer = buf, nowait = true, desc = "Review: close" })
end

local function forget()
  pcall(vim.api.nvim_del_augroup_by_name, "git_review")
  review = nil
end

-- Close the files the review opened, unless you changed them, had them open before, or have them open
-- in another tab
local function close_files(closed)
  for _, item in ipairs(vim.fn.getqflist({ id = closed.qf_id, items = 0 }).items) do
    local buf = item.bufnr
    if vim.api.nvim_buf_is_loaded(buf) and not closed.keep[buf] and not vim.bo[buf].modified then
      if #vim.fn.win_findbuf(buf) == 0 then vim.cmd.bdelete(buf) end
    end
  end
end

-- Open = its file list still exists, and its old version or file list is still on screen. A review you
-- closed by hand (:cclose and :q) counts as closed, so <Leader>gr starts a new one straight away.
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

-- Whether you're in the open review's tab
function M.in_review_tab() return M.is_open() and vim.api.nvim_get_current_tabpage() == review.tab end

-- Back to the open review's tab, in its file window
function M.focus()
  vim.api.nvim_set_current_tabpage(review.tab)
  if vim.api.nvim_win_is_valid(review.file_win) then vim.api.nvim_set_current_win(review.file_win) end
end

-- Review the repo at `root` (default: the current file's) against `ref`, in a new tab
function M.start(ref, root)
  root = root or vim.fn.FugitiveWorkTree()
  if root == "" then return vim.notify("Not in a git repository", vim.log.levels.WARN) end
  local base, err = git(root, { "merge-base", ref, "HEAD" })
  if not base then return vim.notify("Can't compare with " .. ref .. ": " .. err, vim.log.levels.ERROR) end
  local items, submodules = changed_files(root, vim.trim(base))
  local left_out = #submodules > 0 and (" (changed submodules aren't shown: %s)"):format(table.concat(submodules, ", "))
    or ""
  if #items == 0 then return vim.notify("No changes compared with " .. ref .. left_out) end
  if M.is_open() then M.stop() end
  vim.fn.setqflist({}, " ", { title = "Review vs " .. ref, items = items })
  local qf_id, keep = vim.fn.getqflist({ id = 0 }).id, {}
  for _, item in ipairs(vim.fn.getqflist({ id = qf_id, items = 0 }).items) do
    keep[item.bufnr] = vim.api.nvim_buf_is_loaded(item.bufnr)
  end
  local from_tab = vim.api.nvim_get_current_tabpage()
  vim.cmd "tabnew | setlocal bufhidden=wipe"
  review = {
    ref = ref,
    base = vim.trim(base),
    root = root,
    qf_id = qf_id,
    tab = vim.api.nvim_get_current_tabpage(),
    from_tab = from_tab,
    file_win = vim.api.nvim_get_current_win(),
    keep = keep,
  }
  local group = vim.api.nvim_create_augroup("git_review", { clear = true })
  vim.api.nvim_create_autocmd("FileType", { -- the keys again when the file list is reopened (:copen)
    group = group,
    pattern = "qf",
    callback = function()
      if vim.fn.win_gettype() == "quickfix" then set_up_list(vim.api.nvim_get_current_win()) end
    end,
  })
  vim.api.nvim_create_autocmd("TabClosed", { -- you closed the review's tab yourself (:tabclose, :q, ...)
    group = group,
    callback = function()
      if review and not vim.api.nvim_tabpage_is_valid(review.tab) then
        local closed = review
        forget()
        close_files(closed)
      end
    end,
  })
  vim.cmd "botright copen"
  set_up_list(vim.api.nvim_get_current_win())
  vim.notify(("Reviewing %d changed files vs %s%s"):format(#items, ref, left_out))
  show(1)
end

-- Next (1) or previous (-1) changed file, with the cursor on its first change (`where` = "last": on
-- its last change)
function M.move(delta, where)
  if not M.is_open() then return vim.notify "No review open (<Leader>gr starts one)" end
  -- Another command (e.g. <Leader>gh) may have put a newer list in the quickfix window: show ours again
  local current, ours = vim.fn.getqflist({ nr = 0 }).nr, vim.fn.getqflist({ id = review.qf_id, nr = 0 }).nr
  if ours < current then vim.cmd("silent colder " .. current - ours) end
  if ours > current then vim.cmd("silent cnewer " .. ours - current) end
  local list = vim.fn.getqflist { id = review.qf_id, idx = 0, size = 0 }
  local idx = list.idx + delta
  if idx < 1 or idx > list.size then
    return vim.notify(("%s changed file (%d of %d)"):format(delta > 0 and "Last" or "First", list.idx, list.size))
  end
  show(idx, where)
end

-- Next (1) or previous (-1) change. In the review's tab, after the last change in a file comes the
-- first one in the next file. Elsewhere: the next change in a diff, or else the next git change
-- (gitsigns hunk) in this file.
function M.change(delta)
  local key = delta > 0 and "]c" or "[c"
  if not M.in_review_tab() then
    if vim.wo.diff then return vim.cmd("normal! " .. key) end
    return require("gitsigns").nav_hunk(delta > 0 and "next" or "prev")
  end
  local win = vim.api.nvim_get_current_win()
  if win ~= review.old_win and win ~= review.file_win and vim.api.nvim_win_is_valid(review.file_win) then
    vim.api.nvim_set_current_win(review.file_win) -- e.g. pressed in the file list
  end
  local before = vim.api.nvim_win_get_cursor(0)
  if vim.wo.diff then vim.cmd("normal! " .. key) end
  if vim.deep_equal(vim.api.nvim_win_get_cursor(0), before) then M.move(delta, delta > 0 and "first" or "last") end
end

function M.stop()
  if not review then return end
  local closing = review
  if vim.api.nvim_tabpage_is_valid(closing.tab) then
    vim.api.nvim_set_current_tabpage(closing.tab)
    close_old()
    forget() -- first, so closing the tab doesn't also run the TabClosed cleanup
    if #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd.tabclose()
    else -- the review's tab is the only one left: keep it, without the list and labels
      vim.cmd.cclose()
      if vim.api.nvim_win_is_valid(closing.file_win) then vim.wo[closing.file_win].winbar = "" end
    end
  end
  forget()
  if vim.api.nvim_tabpage_is_valid(closing.from_tab) then vim.api.nvim_set_current_tabpage(closing.from_tab) end
  close_files(closing)
end

return M
