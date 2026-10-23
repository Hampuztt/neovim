-- ╭────────────────────────────────────────────────────────────────────────────╮
-- │ ALL of your keybindings live in this file.                                 │
-- ╰────────────────────────────────────────────────────────────────────────────╯
--
--   general   keys that work everywhere
--   lsp       keys that only exist in buffers with a language server (Python, Lua, C++, ...)
--   disabled  AstroNvim / Neovim default keys you don't want. Delete a line to get that key back.
--
-- A key looks like:   ["<Leader>x"] = { <action>, desc = "What it does" },
--   <action> is a command ("<Cmd>Oil<CR>"), keys to press ('"+p'), or a Lua function.
--   desc is the text which-key shows when you press <Leader> and wait.
-- Modes: n = normal, x = visual, i = insert, t = terminal.  <Leader> is Space.
--
-- Your keys always win over AstroNvim's defaults for the same key.
-- To see every key that is active right now: <Leader>fk

local function harpoon() return require "harpoon" end

-- <Leader>x: run the current Lua/Vim file. Other files would be read as Vim commands and fail.
local function source_this_file()
  if vim.bo.filetype ~= "lua" and vim.bo.filetype ~= "vim" then
    vim.notify("<Leader>x only sources Lua and Vim files", vim.log.levels.WARN)
    return
  end
  vim.cmd "source %"
end

-- <Leader>rf: reopen the file from disk (asks first if you'd lose unsaved changes).
local function reload_file()
  if vim.bo.modified and vim.fn.confirm("Discard unsaved changes and reload from disk?", "&Yes\n&No", 2) ~= 1 then
    return
  end
  vim.cmd "edit!"
end

-- <Leader>rd: your unsaved changes as a side-by-side diff against the file on disk.
-- q in the diff, or <Leader>rd again, closes it.
local function diff_unsaved()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do -- already open: close it (only one at a time)
    if vim.b[buf].on_disk_diff then return vim.api.nvim_buf_delete(buf, { force = true }) end
  end
  if not vim.bo.modified then return vim.notify("No unsaved changes", vim.log.levels.INFO) end
  local file_win, filetype, name = vim.api.nvim_get_current_win(), vim.bo.filetype, vim.fn.expand "%:t"
  vim.cmd "diffthis | vertical new | setlocal buftype=nofile bufhidden=wipe noswapfile"
  vim.cmd "read ++edit # | 0delete _ | diffthis"
  local disk_buf = vim.api.nvim_get_current_buf()
  vim.b[disk_buf].on_disk_diff = true
  vim.api.nvim_buf_set_name(disk_buf, "[on disk] " .. name)
  vim.bo.filetype, vim.bo.modifiable = filetype, false
  vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = disk_buf, desc = "Close the diff" })
  vim.api.nvim_create_autocmd("BufWipeout", { -- turn diff mode off again in your file's window
    buffer = disk_buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(file_win) then vim.api.nvim_win_call(file_win, vim.cmd.diffoff) end
    end,
  })
end

-- <Leader>fi / <Leader>fI: search the current file's folder (or the folder open in Oil) instead of
-- the whole project. The picker's title says which folder; <A-u> moves one folder up (see snacks.lua).
local function in_this_files_folder(picker)
  local dir = vim.bo.filetype == "oil" and require("oil").get_current_dir() or vim.fn.expand "%:p:h"
  require("snacks").picker[picker] { cwd = dir }
end

-- The branch you'd usually compare with: the default branch (main / master), or its remote version
-- (origin/main) while you're on it, to see what you haven't pushed. Named like the branch picker does.
local function usual_branch(root)
  local function git(...)
    local result = vim.system({ "git", "-C", root, ... }, { text = true }):wait()
    return result.code == 0 and vim.trim(result.stdout) or nil
  end
  local remote = git("symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD") -- e.g. "origin/main"
  local name = remote and remote:match "^origin/(.+)$"
    or (git("rev-parse", "--verify", "--quiet", "refs/heads/main") and "main")
    or "master"
  local is_local = git("rev-parse", "--verify", "--quiet", "refs/heads/" .. name) ~= nil
  if remote and (not is_local or git("branch", "--show-current") == name) then return "remotes/" .. remote end
  return name
end

-- Pick what to compare with, typing to search names / commit messages, and pass it to on_pick: the
-- usual branch first so <CR> is enough, then the other branches (remote ones too), then the commits
-- (only those that changed the current file when `this_file`). (Instead of the pickers' `git checkout`.)
local function pick_git_ref(title, this_file, on_pick)
  -- The current file's repo, which isn't always the one Neovim's working folder is in
  local root = vim.fn.FugitiveWorkTree()
  if root == "" then return vim.notify("Not in a git repository", vim.log.levels.WARN) end
  local usual = usual_branch(root)
  require("snacks").picker.pick {
    title = title,
    cwd = root,
    multi = { { source = "git_branches", all = true }, this_file and "git_log_file" or "git_log" },
    -- Sorted even before you type (sort_empty), by score: the usual branch gets extra, the rest ties
    -- and stays in the order it came (idx: branches, then commits)
    transform = function(item)
      if item.branch == usual then item.score_add = 1 end
    end,
    matcher = { sort_empty = true },
    sort = { fields = { "score:desc", "idx" } },
    confirm = function(picker, item)
      picker:close()
      if item then on_pick(item.branch and item.branch:gsub("^remotes/", "") or item.commit, root) end
    end,
  }
end

-- <Leader>gD: this file next to its version on a branch / at a commit (fugitive's :Gvdiffsplit), the
-- old version on the left like in the review. :q in the old version closes it.
local function compare_file_with(ref) vim.cmd("leftabove Gvdiffsplit " .. vim.fn.fnameescape(ref)) end

-- <Leader>gr: go through every file this branch changed (lua/git_review.lua), in a tab of its own.
-- With a review open it takes you back to it, and pressed in the review's tab it closes it.
local function review_key()
  local review = require "git_review"
  if not review.is_open() then return pick_git_ref("Review changes vs", false, review.start) end
  if review.in_review_tab() then return review.stop() end
  review.focus()
end

-- J: join lines, keeping the cursor where it is. A count joins that many lines (3J joins three).
local function join_lines()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd("normal! " .. vim.v.count1 .. "J")
  vim.api.nvim_win_set_cursor(0, cursor)
end

local general = {
  n = {
    -- Group names which-key shows for a prefix (a key with only a `desc`)
    ["<Leader>b"] = { desc = "Buffers & tabs" },
    ["<Leader>c"] = { desc = "Code" },
    ["<Leader>r"] = { desc = "Reload" },

    -- Files & windows
    ["<Leader>o"] = { "<Cmd>Oil<CR>", desc = "File explorer (Oil)" },
    ["<Leader>q"] = { "<Cmd>q<CR>", desc = "Quit window" },
    ["<Leader>bn"] = { "<Cmd>tabnew<CR>", desc = "New tab" },
    ["<Leader>bd"] = {
      function()
        require("snacks").picker.buffers {
          title = "Close buffer",
          confirm = function(picker, item)
            picker:close()
            if item then require("snacks").bufdelete(item.buf) end
          end,
        }
      end,
      desc = "Pick buffer to close",
    },

    -- Move between Neovim splits and tmux panes (vim-tmux-navigator)
    ["<C-h>"] = { "<Cmd>TmuxNavigateLeft<CR>", desc = "Go to left split/pane" },
    ["<C-j>"] = { "<Cmd>TmuxNavigateDown<CR>", desc = "Go to split/pane below" },
    ["<C-k>"] = { "<Cmd>TmuxNavigateUp<CR>", desc = "Go to split/pane above" },
    ["<C-l>"] = { "<Cmd>TmuxNavigateRight<CR>", desc = "Go to right split/pane" },
    ["<C-\\>"] = { "<Cmd>TmuxNavigatePrevious<CR>", desc = "Go to previous split/pane" },

    -- Find things (Snacks picker). Hidden files are included, see snacks.lua.
    ["<Leader>ff"] = { function() require("snacks").picker.files() end, desc = "Find files" },
    ["<Leader>fi"] = {
      function() in_this_files_folder "files" end,
      desc = "Find files in this file's folder",
    },
    ["<Leader>fw"] = { function() require("snacks").picker.grep() end, desc = "Find words (grep)" },
    ["<Leader>fI"] = { function() in_this_files_folder "grep" end, desc = "Find words in this file's folder" },
    ["<Leader>fd"] = {
      function() require("snacks").picker.diagnostics_buffer() end,
      desc = "Find diagnostics (this file)",
    },
    ["<Leader>fD"] = { function() require("snacks").picker.diagnostics() end, desc = "Find diagnostics (project)" },
    ["<Leader>fb"] = { function() require("snacks").picker.buffers() end, desc = "Find buffers" },
    ["<Leader>fh"] = { function() require("snacks").picker.help() end, desc = "Find help" },

    -- Harpoon: mark files and jump straight to them
    ["<Leader>a"] = { function() harpoon():list():add() end, desc = "Harpoon: add file" },
    ["<Leader><Tab>"] = { function() harpoon().ui:toggle_quick_menu(harpoon():list()) end, desc = "Harpoon: menu" },
    ["<Leader>1"] = { function() harpoon():list():select(1) end, desc = "Harpoon: file 1" },
    ["<Leader>2"] = { function() harpoon():list():select(2) end, desc = "Harpoon: file 2" },
    ["<Leader>3"] = { function() harpoon():list():select(3) end, desc = "Harpoon: file 3" },
    ["<Leader>4"] = { function() harpoon():list():select(4) end, desc = "Harpoon: file 4" },
    ["<Leader>5"] = { function() harpoon():list():select(5) end, desc = "Harpoon: file 5" },
    ["<Leader>6"] = { function() harpoon():list():select(6) end, desc = "Harpoon: file 6" },

    -- Git (vim-fugitive, see git.lua). In the status window: - stages/unstages, = shows the diff,
    -- x or X discards, cc commits, g? lists every key.
    ["<Leader>gs"] = { "<Cmd>vert Git<CR>", desc = "Git status (vertical split)" },
    ["<Leader>gS"] = { "<Cmd>Git<CR>", desc = "Git status (horizontal split)" },
    ["<Leader>gd"] = { "<Cmd>Gvdiffsplit<CR>", desc = "Diff this file vs its staged / committed version" },
    ["<Leader>gD"] = {
      function() pick_git_ref("Compare this file with", true, compare_file_with) end,
      desc = "Diff this file vs a branch or commit",
    },
    -- Review a branch: the changed files are listed at the bottom, the keys are shown above that list.
    -- In the list: <CR> shows the file under the cursor, q closes the review.
    ["<Leader>gr"] = { review_key, desc = "Review every file changed vs a branch/commit (in it: close)" },
    ["]e"] = { function() require("git_review").change(1) end, desc = "Next change (review: on to next file)" },
    ["[e"] = { function() require("git_review").change(-1) end, desc = "Previous change (review: back a file)" },
    ["]r"] = { function() require("git_review").move(1) end, desc = "Review: next changed file" },
    ["[r"] = { function() require("git_review").move(-1) end, desc = "Review: previous changed file" },
    -- Blame. In <Leader>gb's window: <CR> on a line opens the commit that changed it, - shows the
    -- blame as it was in that commit (step back in time), gq closes it.
    ["<Leader>gb"] = { "<Cmd>Git blame<CR>", desc = "Git blame (whole file)" },
    ["<Leader>gl"] = { -- the popup comes from gitsigns
      function() require("gitsigns").blame_line { full = true } end,
      desc = "Last change to this line: commit, author, date, message",
    },
    ["<Leader>gh"] = { "<Cmd>0Gclog<CR>", desc = "History: every version of this file (]q / [q step through)" },
    ["<Leader>gL"] = { "<Cmd>Git log<CR>", desc = "Git log" },

    -- System clipboard (normal yank/paste stays inside Neovim, see `clipboard` in astrocore.lua)
    ["<Leader>y"] = { '"+y', desc = "Yank to system clipboard" },
    ["<Leader>Y"] = { '"+Y', desc = "Yank line to system clipboard" },
    ["<Leader>p"] = { '"+p', desc = "Paste from system clipboard" },
    ["<Leader>P"] = { '"+P', desc = "Paste from system clipboard (before cursor)" },
    ["<Leader>D"] = { '"+D', desc = "Delete to end of line into system clipboard" },
    -- Delete without overwriting your last yank:
    -- ["<Leader>d"] = { '"_d', desc = "Delete without overwriting your last yank" },

    -- Editing
    ["<Leader>s"] = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], desc = "Replace word under cursor" },
    ["J"] = { function() join_lines() end, desc = "Join lines (cursor stays put)" },
    ["<C-d>"] = { "<C-d>zz", desc = "Half page down (centered)" },
    ["<C-u>"] = { "<C-u>zz", desc = "Half page up (centered)" },
    ["n"] = { "nzzzv", desc = "Next match (centered)" },
    ["N"] = { "Nzzzv", desc = "Previous match (centered)" },
    ["Q"] = { "<Nop>", desc = "Nothing (no Ex mode)" },
    ["<Leader>cd"] = { "<Cmd>Neogen<CR>", desc = "Generate doc comment" },

    -- Language servers (these work even when no server is attached, e.g. after a crash)
    ["<Leader>ll"] = {
      function()
        vim.cmd.tabnew(vim.lsp.log.get_filename())
        vim.cmd "normal! G" -- newest lines are at the bottom
        vim.keymap.set("n", "q", "<Cmd>tabclose<CR>", { buffer = true, desc = "Close LSP log" })
      end,
      desc = "LSP log (q closes)",
    },
    ["<Leader>lr"] = { "<Cmd>lsp restart<CR>", desc = "Restart language servers (this buffer)" },
    ["<Leader>li"] = { "<Cmd>checkhealth vim.lsp<CR>", desc = "LSP info (attached servers, config)" },

    -- Run / reload
    ["<F5>"] = { function() require "run_file"() end, desc = "Run this file (Python / C++)" },
    ["<F6>"] = { function() require("astrocore.toggles").buffer_cmp() end, desc = "Toggle autocompletion (buffer)" },
    ["<Leader>x"] = { function() source_this_file() end, desc = "Source this file (Lua / Vim)" },
    ["<Leader><Leader>x"] = { function() source_this_file() end, desc = "Source this file (Lua / Vim)" },
    ["<Leader>rf"] = { function() reload_file() end, desc = "Reload file from disk" },
    ["<Leader>rd"] = { function() diff_unsaved() end, desc = "Diff unsaved changes vs file on disk (toggle)" },
    ["<Leader>rr"] = { "<Cmd>restart<CR>", desc = "Restart Neovim (reloads config, keeps open files)" },
  },

  x = {
    ["J"] = { ":m '>+1<CR>gv=gv", desc = "Move selection down" },
    ["K"] = { ":m '<-2<CR>gv=gv", desc = "Move selection up" },
    ["<Leader>s"] = { ":sort<CR>", desc = "Sort selected lines" },
    ["<Leader>x"] = { ":lua<CR>", desc = "Run selected Lua" },
    ["<Leader>fc"] = { function() require("snacks").picker.grep_word() end, desc = "Find selected text (grep)" },
    ["<Leader>gl"] = { ":Gclog<CR>", desc = "History: every commit that changed these lines (]q / [q)" },
    ["<Leader>y"] = { '"+y', desc = "Yank to system clipboard" },
    ["<Leader>p"] = { '"+p', desc = "Paste from system clipboard" },
    ["<Leader>P"] = { '"+P', desc = "Paste from system clipboard (before cursor)" },
    -- ["<Leader>d"] = { '"_d', desc = "Delete without overwriting your last yank" },
  },

  t = { -- in terminals (e.g. the <F5> output), the same split/pane keys as in normal mode
    ["<C-h>"] = { "<Cmd>TmuxNavigateLeft<CR>", desc = "Go to left split/pane" },
    ["<C-j>"] = { "<Cmd>TmuxNavigateDown<CR>", desc = "Go to split/pane below" },
    ["<C-k>"] = { "<Cmd>TmuxNavigateUp<CR>", desc = "Go to split/pane above" },
    ["<C-l>"] = { "<Cmd>TmuxNavigateRight<CR>", desc = "Go to right split/pane" },
  },

  -- Insert mode: jj, jk and kk leave insert mode. That's set in better-escape.lua, not here,
  -- so that typing a single j or k doesn't lag.
}

local lsp = {
  n = {
    -- gd / gI / gy jump straight there when there's one result, and show a picker when there are several
    ["gd"] = { function() require("snacks").picker.lsp_definitions() end, desc = "Go to definition" },
    ["gD"] = {
      function() vim.lsp.buf.declaration() end,
      desc = "Go to declaration",
      cond = "textDocument/declaration",
    },
    ["gI"] = { -- capital I: Vim's own gi (continue typing where you last stopped) keeps working
      function() require("snacks").picker.lsp_implementations() end,
      desc = "Go to implementation",
      cond = "textDocument/implementation",
    },
    ["gy"] = { function() require("snacks").picker.lsp_type_definitions() end, desc = "Go to type definition" },
    ["gr"] = { function() require("snacks").picker.lsp_references() end, desc = "Show references" },
    ["gh"] = {
      "<Cmd>LspClangdSwitchSourceHeader<CR>",
      desc = "Switch source/header (C++)",
      cond = function(client) return client.name == "clangd" end,
    },
    ["<Leader>lw"] = {
      "<Cmd>LspClangdSwitchSourceHeader<CR>",
      desc = "Switch source/header (C++)",
      cond = function(client) return client.name == "clangd" end,
    },
    ["K"] = { function() vim.lsp.buf.hover() end, desc = "Hover documentation" },
    ["<F2>"] = { function() vim.lsp.buf.rename() end, desc = "Rename symbol" },
    ["<Leader>ca"] = { function() vim.lsp.buf.code_action() end, desc = "Code actions" },
    ["<Leader>="] = { -- uses the `formatting` settings in astrolsp.lua
      function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
      desc = "Format file",
    },
    ["<Leader>fs"] = { function() require("snacks").picker.lsp_symbols() end, desc = "Find symbols in this file" },
    ["<Leader>fS"] = {
      function() require("snacks").picker.lsp_workspace_symbols() end,
      desc = "Find symbols in the project",
      cond = "workspace/symbol",
    },
  },
}

local disabled = {
  n = {
    "<Leader>h", -- dashboard
    "<Leader>c", -- close buffer (you use <Leader>ca / <Leader>cd)
    "<Leader>C", -- force close buffer
    "<Leader>fs", -- smart file picker (<Leader>fs is "symbols" in LSP buffers)
    "<Leader>pa", -- plugin/package manager keys (<Leader>p is your paste; use :Lazy and :Mason)
    "<Leader>pi",
    "<Leader>pm",
    "<Leader>pM",
    "<Leader>ps",
    "<Leader>pS",
    "<Leader>pu",
    "<Leader>pU",
    "<Leader>xq", -- quickfix/location list (<Leader>x is your "source file")
    "<Leader>xl",
    "<Leader>la", -- AstroNvim's <Leader>l... LSP keys (you have your own above)
    "<Leader>lA",
    "<Leader>ld",
    "<Leader>lD",
    "<Leader>lf",
    "<Leader>lG",
    "<Leader>lh",
    "<Leader>lI",
    "<Leader>li", -- AstroNvim's versions of your <Leader>li / ll / lr (theirs would win in code files)
    "<Leader>ll",
    "<Leader>lL",
    "<Leader>lr",
    "<Leader>lR",
    "<Leader>ls",
    "<Leader>lS",
    "gl", -- line diagnostics
    "]w", -- next/previous warning (]e / [e are your next/previous change)
    "[w",
    "gra", -- Neovim's LSP keys (they would make your `gr` wait for more keys)
    "grn",
    "grr",
    "gri",
    "grt",
    "grx",
    "gO", -- Neovim's document symbols
    "<C-w>d", -- Neovim's line diagnostics
    "<C-w><C-d>",
    -- ]y / [y (next/previous symbol) are switched off at the bottom of this file.
  },
  x = {
    "gra",
    "<Leader>la",
  },
  v = {
    "<Leader>lf",
  },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Plumbing that hands the tables above to AstroNvim. You shouldn't need to edit below.
-- ─────────────────────────────────────────────────────────────────────────────

-- "<C-h>" and "<C-H>", or "<leader>" and "<Leader>", are the same key. Remove any spelling of it.
local function remove_key(maps, lhs)
  local code = vim.keycode(lhs)
  for existing in pairs(maps) do
    if vim.keycode(existing) == code then maps[existing] = nil end
  end
end

-- Merge your keys into AstroNvim's mapping table: disabled keys become `false`, yours replace defaults.
local function apply(maps, mine)
  for mode, keys in pairs(disabled) do
    maps[mode] = maps[mode] or {}
    for _, lhs in ipairs(keys) do
      remove_key(maps[mode], lhs)
      maps[mode][lhs] = false
    end
  end
  for mode, keys in pairs(mine) do
    maps[mode] = maps[mode] or {}
    for lhs, map in pairs(keys) do
      remove_key(maps[mode], lhs)
      maps[mode][lhs] = map
    end
  end
end

-- AstroCore stores <C-j> as <NL> (and <C-i> as <Tab>, ...), which some terminals send as a
-- different key. Set those of your keys directly instead.
local function set_renamed_keys_directly(maps)
  for mode, keys in pairs(general) do
    for lhs, map in pairs(keys) do
      local stored_as = vim.fn.keytrans(vim.keycode(lhs))
      if stored_as:upper() ~= lhs:upper() and vim.tbl_contains({ "<NL>", "<Tab>", "<CR>", "<Esc>" }, stored_as) then
        maps[mode][lhs] = nil
        local keymap_opts = vim.tbl_extend("force", {}, map)
        keymap_opts[1] = nil
        vim.keymap.set(mode, lhs, map[1], keymap_opts)
      end
    end
  end
end

return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      apply(opts.mappings, general)
      set_renamed_keys_directly(opts.mappings)
      -- Some disabled keys are Neovim built-ins rather than AstroNvim keys; remove those directly.
      for mode, keys in pairs(disabled) do
        for _, lhs in ipairs(keys) do
          pcall(vim.keymap.del, mode, lhs)
        end
      end
    end,
  },
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts) apply(opts.mappings, lsp) end,
  },
  -- AstroNvim lets aerial (the symbol breadcrumbs at the top) add ]y/[y/]Y/[Y to every buffer. Stop that.
  { "stevearc/aerial.nvim", optional = true, opts = { on_attach = function() end } },
}
