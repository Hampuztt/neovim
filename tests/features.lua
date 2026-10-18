-- Feature tests for this config. Run them with tests/run.sh (every group) or tests/run.sh <group>
-- (the groups are at the bottom of this file).
--
-- Each group runs in its own headless Neovim with your real config, in throwaway git repos in a
-- temp folder. Your files, repos, clipboard and recent-files list aren't touched.

local results = assert(io.open(assert(vim.env.RESULTS, "run this file through tests/run.sh"), "a"))
local failures = 0
local tmp = vim.fn.tempname()
vim.o.undofile = false -- no undo files for the test files (tests/run.sh also turns off the recent-files list)

-- ── Reporting ──────────────────────────────────────────────────────────────────────────────────

local function report(ok, description, detail)
  local mark = ok and "\27[32mPASS\27[0m" or "\27[31mFAIL\27[0m"
  results:write(("  %s %s%s\n"):format(mark, description, (not ok and detail) and (": " .. detail) or ""))
  if not ok then failures = failures + 1 end
end
local function check(description, ok) report(ok and true or false, description) end
local function expect(description, got, wanted)
  report(vim.deep_equal(got, wanted), description, ("got %s, wanted %s"):format(vim.inspect(got), vim.inspect(wanted)))
end

-- ── Helpers ────────────────────────────────────────────────────────────────────────────────────

local function keys(k) vim.api.nvim_feedkeys(vim.keycode(k), "mx", false) end
local function wait(condition, ms) return vim.wait(ms or 5000, condition, 20) end

local function write(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(type(lines) == "table" and lines or { lines }, path)
end
local function read(path) return vim.fn.filereadable(path) == 1 and vim.fn.readfile(path) or nil end
-- Change a file the way another program would, with a newer timestamp so Neovim notices
local function write_outside(path, lines)
  write(path, lines)
  vim.uv.fs_utime(path, os.time() + 5, os.time() + 5)
end

local function git(dir, args, env)
  local cmd = vim.list_extend({ "git", "-c", "user.name=Test", "-c", "user.email=test@example.com" }, args)
  local result = vim.system(cmd, { cwd = dir, text = true, env = env }):wait()
  assert(result.code == 0, "git " .. table.concat(args, " ") .. ": " .. result.stderr)
  return vim.trim(result.stdout)
end
local function new_repo(name)
  local dir = tmp .. "/" .. name
  vim.fn.mkdir(dir, "p")
  git(dir, { "init", "-q", "-b", "master" })
  return dir
end
local function commit(dir, message, date)
  git(dir, { "add", "-A" })
  local stamp = date and (date .. "T12:00:00") or nil
  git(dir, { "commit", "-q", "-m", message }, stamp and { GIT_AUTHOR_DATE = stamp, GIT_COMMITTER_DATE = stamp })
end

local function windows() -- the normal (not floating) windows in this tab
  return vim.tbl_filter(
    function(win) return vim.api.nvim_win_get_config(win).relative == "" end,
    vim.api.nvim_tabpage_list_wins(0)
  )
end
local function window_where(test) -- the first window whose buffer passes test(buf, win)
  for _, win in ipairs(windows()) do
    if test(vim.api.nvim_win_get_buf(win), win) then return win end
  end
end
local function text(buf) return table.concat(vim.api.nvim_buf_get_lines(buf or 0, 0, -1, false), "\n") end
local function fugitive_text() -- the old version fugitive shows next to your file
  local win = window_where(function(buf) return vim.api.nvim_buf_get_name(buf):match "^fugitive://" end)
  return win and text(vim.api.nvim_win_get_buf(win))
end

local function open_picker(k) -- press the keys, then wait until the picker has loaded its list
  keys(k)
  wait(function()
    local picker = Snacks.picker.get()[1]
    return picker ~= nil and not picker:is_active()
  end)
  return Snacks.picker.get()[1]
end
local function search(picker, query) -- type in the picker and wait for the results
  if picker.opts.live then -- grep pickers search as you type: the query goes to git grep / ripgrep
    picker.input:set("", query)
  else
    picker.input:set(query)
  end
  picker:find()
  wait(function() return picker:count() > 0 and not picker:is_active() end)
end
local function close(picker)
  picker:close()
  wait(function() return #Snacks.picker.get() == 0 end)
end
local function alt_u_bound(picker)
  return vim.api.nvim_win_call(picker.input.win.win, function() return vim.fn.maparg("<A-u>", "i") ~= "" end)
end

local function quickfix_files() -- "name (what changed)" for each entry
  return vim.tbl_map(
    function(item) return vim.fn.fnamemodify(vim.fn.bufname(item.bufnr), ":t") .. " (" .. item.text .. ")" end,
    vim.fn.getqflist()
  )
end
local function last_message()
  local history = Snacks.notifier.get_history()
  return history[#history] and history[#history].msg or ""
end
local function no_errors() return vim.fn.execute("messages"):match "E%d+:" == nil end
local function only() -- back to one window (from a normal window: :only refuses to leave just a popup)
  local win = vim.iter(windows()):find(function(w) return vim.fn.win_gettype(w) == "" end)
  if win then vim.api.nvim_set_current_win(win) end
  vim.cmd "silent! only!"
end

local groups = {}

-- ── Editing keys ───────────────────────────────────────────────────────────────────────────────

function groups.editing()
  local file = tmp .. "/edit/join.txt"
  write(file, { "a", "b", "c", "d" })
  vim.cmd.edit(file)
  keys "3J"
  expect("3J joins three lines", vim.fn.getline(1), "a b c")
  expect("J leaves the cursor where it was", vim.api.nvim_win_get_cursor(0), { 1, 0 })

  file = tmp .. "/edit/diff.txt"
  write(file, "one")
  vim.cmd.edit(file)
  vim.fn.setline(1, "changed")
  keys " rd"
  expect("<Leader>rd shows unsaved changes next to the file on disk", #windows(), 2)
  keys " rd"
  expect("<Leader>rd again closes that diff", #windows(), 1)
  keys " rd"
  keys " rd"
  check("<Leader>rd can be used again", no_errors())

  local keymaps = { { "n", " fd" }, { "n", " fD" }, { "n", " fI" }, { "x", " fc" }, { "n", " gB" }, { "n", " gC" } }
  vim.list_extend(keymaps, { { "n", " gm" }, { "n", " gM" }, { "n", "]r" }, { "n", " gh" }, { "x", " gl" } })
  for _, key in ipairs(keymaps) do
    local name = key[2]:gsub("^ ", "<Leader>")
    check(("key %s (%s mode) exists"):format(name, key[1]), vim.fn.maparg(key[2], key[1]) ~= "")
  end
  local lsp = require("astrolsp").config.mappings.n
  check("gI goes to the implementation (in buffers with a language server)", lsp.gI ~= nil)
  check("gi stays Vim's own (continue typing where you stopped)", lsp.gi == nil)
end

-- ── Find / grep pickers ────────────────────────────────────────────────────────────────────────

function groups.pickers()
  local project = tmp .. "/project"
  write(project .. "/sub/deep/file.txt", "needle here")
  write(project .. "/top.txt", "nothing")
  vim.fn.chdir(project)
  vim.cmd.edit(project .. "/sub/deep/file.txt")
  local config = vim.fn.stdpath "config"

  local picker = open_picker " fa"
  expect("<Leader>fa says where it searches", picker.title, "Files in " .. vim.fn.fnamemodify(config, ":~"))
  keys "<A-u>"
  expect("Alt-u searches one folder up", picker.title, "Files in " .. vim.fn.fnamemodify(vim.fs.dirname(config), ":~"))
  close(picker)

  picker = open_picker " ff"
  expect("<Leader>ff in the working folder has a plain title", picker.title, "Files")
  check("Alt-u works in file pickers", alt_u_bound(picker))
  close(picker)

  picker = open_picker " fi"
  expect("<Leader>fi searches this file's folder", picker.title, "Files in " .. project .. "/sub/deep")
  keys "<A-u>"
  expect("Alt-u in <Leader>fi goes one folder up", picker.title, "Files in " .. project .. "/sub")
  close(picker)

  picker = open_picker " fI"
  expect("<Leader>fI greps this file's folder", picker.title, "Grep in " .. project .. "/sub/deep")
  search(picker, "needle")
  expect("<Leader>fI finds text there", picker:count(), 1)
  close(picker)

  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  keys "ve"
  picker = open_picker " fc"
  expect("<Leader>fc in visual mode greps the selection", picker.input.filter.search, "needle")
  close(picker)

  picker = open_picker " fb"
  check("Alt-u is only in file and grep pickers (not in buffers)", not alt_u_bound(picker))
  close(picker)
end

-- ── Git: history, blame, compare, GitHub links (fugitive) ──────────────────────────────────────
-- (Neovim's working folder is this config's own repo while the tests run, so these also check that
-- the git keys use the repo of the file you're in.)

function groups.git()
  local repo = new_repo "git"
  write(repo .. "/f.txt", { "a", "b", "c" })
  commit(repo, "add f", "2025-03-01")
  write(repo .. "/f.txt", { "a", "B", "c" })
  commit(repo, "capitalize b", "2025-11-20")
  write(repo .. "/f.txt", { "a", "BB", "c" })
  commit(repo, "double b", "2026-10-01")
  write(repo .. "/other.txt", "other v1")
  commit(repo, "add other", "2026-10-02")
  write(repo .. "/other.txt", "other v2")
  commit(repo, "touch other only", "2026-10-03")
  git(repo, { "checkout", "-q", "-b", "fix#42" })
  write(repo .. "/f.txt", "f on fix#42")
  commit(repo, "on fix#42")
  git(repo, { "checkout", "-q", "master" })
  git(repo, { "remote", "add", "origin", "git@github.com:someone/project.git" })
  vim.cmd.edit(repo .. "/f.txt")

  check(":0Gclog works right after starting (fugitive loads at start)", pcall(vim.cmd, "0Gclog"))
  expect("history lists start with the date", (vim.fn.getqflist()[1] or {}).text, "2026-10-01 double b")
  vim.cmd "cclose"
  vim.cmd.edit(repo .. "/f.txt")
  keys " gh"
  expect("<Leader>gh: every version of this file", #vim.fn.getqflist(), 3)
  vim.cmd "cclose"
  vim.cmd.edit(repo .. "/f.txt")
  vim.api.nvim_win_set_cursor(0, { 3, 0 })
  keys "V gl"
  expect("<Leader>gl in visual mode: commits that changed those lines", #vim.fn.getqflist(), 1)
  vim.cmd "cclose"
  only()
  vim.cmd.edit(repo .. "/f.txt")

  vim.cmd "doautocmd User AstroGitFile"
  wait(function() return vim.b.gitsigns_status_dict ~= nil end)
  local popup, shown
  for _ = 1, 5 do -- gitsigns ignores the key for about a second after a file opens
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    keys " gl"
    shown = wait(function()
      popup = vim.iter(vim.api.nvim_list_wins()):find(
        function(w)
          return vim.api.nvim_win_get_config(w).relative ~= "" and text(vim.api.nvim_win_get_buf(w)):match "double b"
        end
      )
      return popup ~= nil
    end, 1000)
    if shown then break end
  end
  check("<Leader>gl shows the commit that last changed the line", shown)
  if popup then vim.api.nvim_win_close(popup, true) end

  local picker = open_picker " gB"
  search(picker, "fix#42")
  expect("<Leader>gB lists branches", (picker:current() or {}).branch, "fix#42")
  picker:action "confirm"
  wait(function() return fugitive_text() ~= nil end)
  expect("<Leader>gB shows the file on that branch (even with # in its name)", fugitive_text(), "f on fix#42")
  expect("choosing a branch doesn't check it out", git(repo, { "branch", "--show-current" }), "master")

  only()
  vim.cmd.edit(repo .. "/other.txt")
  picker = open_picker " gC"
  wait(function() return picker:count() > 0 and not picker:is_active() end)
  local messages = vim.tbl_map(function(item) return item.msg end, picker:items())
  expect("<Leader>gC lists only the commits that changed this file", messages, { "touch other only", "add other" })
  close(picker)

  local url
  vim.api.nvim_create_user_command("Browse", function(cmd) url = cmd.args end, { nargs = 1 }) -- instead of a browser
  vim.cmd "GBrowse"
  check(":GBrowse makes a GitHub link (rhubarb)", (url or ""):match "^https://github%.com/someone/project/blob/")

  vim.cmd "Git"
  check("x discards in the status window", (vim.fn.maparg("x", "n", false, true).desc or ""):match "Discard")
end

-- ── Branch review (<Leader>gm, lua/git_review.lua) ─────────────────────────────────────────────

function groups.review()
  local repo = new_repo "review"
  for _, name in ipairs { "a", "b", "c", "d" } do
    write(repo .. "/" .. name .. ".txt", name .. " original")
  end
  local long = {}
  for i = 1, 40 do
    long[i] = "config line " .. i
  end
  write(repo .. "/old_name.lua", long)
  commit(repo, "base")
  git(repo, { "checkout", "-q", "-b", "feature" })
  write(repo .. "/a.txt", "a changed")
  os.remove(repo .. "/d.txt")
  os.rename(repo .. "/old_name.lua", repo .. "/new_name.lua")
  long[7] = "config line 7 EDITED"
  write(repo .. "/new_name.lua", long)
  write(repo .. "/new.txt", "brand new")
  commit(repo, "feature work")
  git(repo, { "checkout", "-q", "master" })
  write(repo .. "/c.txt", "c changed on master later")
  commit(repo, "master moved on")
  git(repo, { "checkout", "-q", "feature" })
  write(repo .. "/b.txt", "b uncommitted")
  write(repo .. "/u.txt", "not added yet")
  local review = require "git_review"
  vim.o.columns = 200 -- wide enough for the full labels (narrow windows get shorter ones)

  local function start(k, query)
    vim.cmd.edit(repo .. "/a.txt")
    local picker = open_picker(k)
    search(picker, query)
    picker:action "confirm"
    wait(function() return review.is_open() end)
  end
  local function review_old_win()
    return window_where(function(_, w) return vim.wo[w].winbar:match "git_review'%.label" end)
  end
  local function winbar(win)
    return vim.api.nvim_eval_statusline(vim.wo[win].winbar, { winid = win, use_winbar = true }).str
  end
  local function old_side() -- text and label of the old version
    local win = window_where(function(_, w) return vim.wo[w].winbar:match "git_review'%.label" end)
    return win and { text(vim.api.nvim_win_get_buf(win)), vim.trim(winbar(win)) }
  end

  start(" gm", "master")
  expect("<Leader>gm lists every file the branch changed (from where it split off master)", quickfix_files(), {
    "a.txt (modified)",
    "b.txt (modified)",
    "d.txt (deleted)",
    "new.txt (added)",
    "new_name.lua (renamed from old_name.lua)",
    "u.txt (new, not added to git yet)",
  })
  local label = "master, where your branch started (" .. git(repo, { "merge-base", "master", "HEAD" }):sub(1, 7) .. ")"
  expect("a changed file is shown next to its old version", old_side(), { "a original", label })
  keys "]r"
  expect("]r: next file (uncommitted change)", old_side(), { "b original", label })
  keys "]r"
  expect("a deleted file shows what it was", old_side(), { "d original", label })
  keys "]r"
  expect("an added file is compared with nothing", old_side(), { "", "new file, not in master" })
  keys "]r"
  local old = old_side() or { "" }
  expect("a renamed file is compared with its old name", #vim.split(old[1], "\n"), 40)
  local changed = 0
  for lnum = 1, 40 do
    if vim.fn.diff_hlID(lnum, 1) > 0 then changed = changed + 1 end
  end
  expect("... and only its edited line shows as changed", changed, 1)
  keys "]r"
  expect("an untracked file is compared with nothing", old_side(), { "", "new file, not in master" })
  keys "]r"
  expect("]r on the last file says so", last_message(), "Last changed file (6 of 6)")
  keys "[r"
  expect("[r: previous file", vim.fn.expand "%:t", "new_name.lua")

  vim.cmd "vert Git"
  local status = vim.api.nvim_get_current_win()
  vim.cmd "wincmd p"
  keys "[r"
  check("[r leaves a fugitive status window alone", vim.api.nvim_win_is_valid(status))
  vim.cmd "botright split | terminal"
  local terminal = vim.api.nvim_get_current_win()
  vim.cmd "stopinsert"
  keys "[r"
  check(
    "[r pressed in a terminal doesn't open the file there",
    vim.bo[vim.api.nvim_win_get_buf(terminal)].buftype == "terminal"
  )

  check("the key reminder shows above the file list", review.winbar():match "%]r %[r" ~= nil)
  local list_win = window_where(function(_, w) return vim.fn.win_gettype(w) == "quickfix" end)
  vim.o.columns = 60
  expect(
    "in a narrow window the key reminder is shortened, keeping ]r [r",
    vim.trim(winbar(list_win)),
    "]r [r  next/prev file  ·  <Leader>gm  close"
  )
  vim.o.columns = 200
  local old_win = review_old_win()
  vim.api.nvim_win_set_width(old_win, 25)
  expect("... and so is the old version's label", vim.trim(winbar(old_win)), "master (old version)")
  vim.api.nvim_win_set_width(old_win, 4)
  expect("... cut from the end when even that doesn't fit", vim.trim(winbar(old_win)), "mas")
  vim.cmd "wincmd ="
  vim.cmd "0Gclog"
  expect("... but not while the list window shows something else", review.winbar(), "")
  keys "]r"
  check("]r brings the review's list back", review.winbar():match "%]r %[r" ~= nil)

  keys " gm"
  check("<Leader>gm again closes the review", not review.is_open())
  check("... and only the review's windows", vim.api.nvim_win_is_valid(status) and vim.api.nvim_win_is_valid(terminal))

  only()
  start(" gM", "base")
  expect("<Leader>gM reviews everything since a commit", #vim.fn.getqflist(), 6)
  vim.cmd "cclose" -- close the review by hand: the file list, then the old version
  local old_win = window_where(function(buf) return vim.api.nvim_buf_get_name(buf):match "^fugitive://" end)
  if old_win then vim.api.nvim_win_close(old_win, true) end
  local picker = open_picker " gm"
  check("a review closed by hand doesn't need <Leader>gm twice", picker ~= nil)
  if picker then close(picker) end

  local clean = new_repo "clean"
  write(clean .. "/x.txt", "x")
  commit(clean, "only commit")
  vim.cmd.edit(clean .. "/x.txt")
  picker = open_picker " gm"
  search(picker, "master")
  picker:action "confirm"
  wait(function() return last_message():match "No changes" end)
  expect("nothing to review: says so", last_message(), "No changes compared with master")
  check(
    "... and leaves no empty list window",
    window_where(function(_, w) return vim.fn.win_gettype(w) == "quickfix" end) == nil
  )
  check("no errors", no_errors())
end

-- ── Discarding in the status window, and getting it back with u ────────────────────────────────

function groups.discard()
  local repo = new_repo "discard"
  local numbers = {}
  for i = 1, 20 do
    numbers[i] = tostring(i)
  end
  write(repo .. "/f.txt", numbers)
  write(repo .. "/h.txt", "h original")
  commit(repo, "base")
  vim.fn.chdir(repo) -- :Git in an empty buffer uses the working folder's repo
  local function reset()
    git(repo, { "checkout", "-q", "--", "." })
    local edited = vim.deepcopy(numbers)
    edited[3], edited[17] = "3 EDIT", "17 EDIT"
    write(repo .. "/f.txt", edited)
    write(repo .. "/h.txt", "h edited")
    write(repo .. "/u.txt", "untracked notes")
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_name(buf):find(repo, 1, true) then vim.api.nvim_buf_delete(buf, { force = true }) end
    end
    vim.cmd "silent! only! | enew! | Git"
    wait(function() return vim.bo.filetype == "fugitive" end)
  end
  local function get_back(file) -- open the file, u, :w
    vim.api.nvim_buf_call(vim.fn.bufnr(repo .. "/" .. file), function() vim.cmd "silent undo | silent write" end)
  end

  reset()
  vim.fn.search "^M f.txt"
  keys "x"
  check("x on a file discards its changes", not vim.tbl_contains(read(repo .. "/f.txt"), "3 EDIT"))
  get_back "f.txt"
  check("u (then :w) in the file gets them back", vim.tbl_contains(read(repo .. "/f.txt"), "3 EDIT"))

  reset()
  vim.fn.search "^? u.txt"
  keys "X"
  expect("X on an untracked file deletes it", read(repo .. "/u.txt"), nil)
  get_back "u.txt"
  expect("u then :w brings it back", read(repo .. "/u.txt"), { "untracked notes" })

  reset()
  vim.fn.search "^M f.txt"
  keys "Vjx"
  expect("x on a selection discards each file", read(repo .. "/h.txt"), { "h original" })
  get_back "h.txt"
  expect("u gets each one back", read(repo .. "/h.txt"), { "h edited" })

  reset()
  vim.fn.search "^M f.txt"
  keys "="
  vim.fn.search "^+3 EDIT"
  keys "x"
  local f = read(repo .. "/f.txt")
  expect("x on one hunk (after =) discards only that hunk", { f[3], f[17] }, { "3", "17 EDIT" })
  get_back "f.txt"
  f = read(repo .. "/f.txt")
  expect("u gets that hunk back", { f[3], f[17] }, { "3 EDIT", "17 EDIT" })

  reset()
  local buf = vim.fn.bufadd(repo .. "/h.txt")
  vim.fn.bufload(buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "unsaved edit" })
  vim.fn.search "^M h.txt"
  keys "x"
  expect("x refuses when the file has unsaved changes", read(repo .. "/h.txt"), { "h edited" })
  check("no errors", no_errors())
end

-- ── File changed on disk while you edit it (statusline badge) ──────────────────────────────────

function groups.disk()
  local dir = tmp .. "/disk"
  local function badge() return vim.api.nvim_eval_statusline(vim.o.statusline, {}).str:match "[A-Z]+ ON DISK" or "none" end
  local function open(name, edit)
    write(dir .. "/" .. name, "v1")
    vim.cmd.edit(dir .. "/" .. name)
    if edit then vim.fn.setline(1, "my edit") end
  end
  local function changed_outside(name)
    write_outside(dir .. "/" .. name, "from outside")
    vim.cmd "checktime"
  end

  open "a.txt"
  changed_outside "a.txt"
  expect("no unsaved changes: the file just reloads", { vim.fn.getline(1), badge() }, { "from outside", "none" })

  open("b.txt", true)
  local before = #Snacks.notifier.get_history()
  changed_outside "b.txt"
  expect(
    "unsaved changes: yours are kept and the statusline says so",
    { vim.fn.getline(1), badge() },
    { "my edit", "CHANGED ON DISK" }
  )
  vim.cmd "checktime | checktime"
  expect("... with one popup, not one per check", #Snacks.notifier.get_history() - before, 1)
  keys " rd"
  expect("<Leader>rd shows your version next to the one on disk", #windows(), 2)
  keys " rd"
  vim.cmd "write!"
  expect(":w! keeps yours and clears the badge", { read(dir .. "/b.txt")[1], badge() }, { "my edit", "none" })

  open("c.txt", true)
  changed_outside "c.txt"
  vim.cmd "edit!"
  expect(":e! takes the one on disk and clears the badge", { vim.fn.getline(1), badge() }, { "from outside", "none" })

  open "d.txt"
  os.remove(dir .. "/d.txt")
  vim.cmd "checktime"
  expect("a deleted file is marked", badge(), "DELETED ON DISK")
  vim.cmd "write"
  expect(":w writes it back and clears the badge", { vim.fn.filereadable(dir .. "/d.txt"), badge() }, { 1, "none" })

  open("e.txt", true)
  changed_outside "e.txt"
  vim.cmd.edit(dir .. "/a.txt")
  expect("the badge belongs to its file (not shown for others)", badge(), "none")
  vim.cmd.buffer(dir .. "/e.txt")
  expect("... and is back when you return to it", badge(), "CHANGED ON DISK")
  check("no errors", no_errors())
end

-- ── Run the group named in $GROUP ──────────────────────────────────────────────────────────────

vim.wait(1000) -- let plugins that load after startup finish
local ok, err = xpcall(assert(groups[vim.env.GROUP], "unknown group " .. tostring(vim.env.GROUP)), debug.traceback)
if not ok then report(false, "the test itself crashed", err) end
results:close()
vim.cmd(failures == 0 and "qa!" or "cquit")
