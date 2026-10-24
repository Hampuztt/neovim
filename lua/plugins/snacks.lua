-- Snacks: the picker behind <Leader>f..., plus notifications, dashboard and more.  Docs: `:h snacks`

-- File and grep pickers that search somewhere other than Neovim's working folder say where in their
-- title, e.g. "Files in ~/.config/nvim" for <Leader>fa.
local function show_folder_in_title(picker)
  picker.base_title = picker.base_title or picker.title
  local dirs = picker.opts.dirs
  if not (dirs and #dirs > 0) then
    dirs = vim.fs.normalize(picker:cwd()) ~= vim.fs.normalize(vim.fn.getcwd()) and { picker:cwd() } or {}
  end
  local where = table.concat(vim.tbl_map(function(dir) return vim.fn.fnamemodify(dir, ":~") end, dirs), ", ")
  picker.title = picker.base_title .. (where ~= "" and (" in " .. where) or "")
  picker:update_titles()
end

-- <A-u> in file and grep pickers: search one folder further up (handy after <Leader>fi / <Leader>fI)
local up_a_folder = { input = { keys = { ["<A-u>"] = { "parent_folder", mode = { "i", "n" } } } } }

-- <A-t> in grep pickers: only files like the one you started from (*.lua, *.py, ...; for a file without
-- an extension, like Makefile, files with that name). Again: every file. While it's on, the title shows
-- the pattern, like the h for hidden files.
local function same_kind(picker) -- the pattern, or nil when the picker wasn't opened from a file
  if not vim.api.nvim_win_is_valid(picker.main) then return nil end
  local buf = vim.api.nvim_win_get_buf(picker.main)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" or vim.bo[buf].buftype ~= "" then return nil end
  local ext = vim.fn.fnamemodify(name, ":e")
  return ext ~= "" and "*." .. ext or vim.fn.fnamemodify(name, ":t")
end
local grep_win = vim.tbl_deep_extend("force", up_a_folder, {
  input = { keys = { ["<A-t>"] = { "only_this_kind", mode = { "i", "n" } } } },
})

-- Grep pickers: a key legend under the search box, in the style of the title's flags, as much of it as
-- fits. After ` -- `, the rest of what you type goes to ripgrep (-g glob, -t filetype, -w whole words,
-- -s case sensitive). <C-g> stops searching and lets you narrow the results you have by typing, <A-r>
-- searches for the text as is (no regex). (<Esc> ? lists every key.)
local function legend(keys) -- the footer text (highlighted parts) and its width
  local parts, width = { { " ", "SnacksPickerInputBorder" } }, 1
  for _, key in ipairs(keys) do
    local lhs, what = " " .. key[1] .. " ", " " .. key[2] .. "   "
    vim.list_extend(parts, { { lhs, "SnacksPickerToggle" }, { what, "SnacksPickerDesc" } })
    width = width + #lhs + #what
  end
  return parts, width
end
local function show_grep_legend(picker)
  show_folder_in_title(picker)
  local keys, glob = { { "--", "rg flags" } }, same_kind(picker)
  if glob then keys[#keys + 1] = { "<A-t>", "only " .. glob } end
  vim.list_extend(keys, { { "<C-g>", "filter" }, { "<A-r>", "literal" } })
  local win = picker.input.win
  local room = win:size().width - 4 -- minus the border's corners and a bit of line on each side
  local parts, width = legend(keys)
  while width > room and #keys > 1 do -- too narrow: leave out the last key, then the one before it, ...
    table.remove(keys)
    parts, width = legend(keys)
  end
  win.opts.footer = parts
  win:update()
end

-- Keys in every picker (search box and list), on top of Snacks' defaults; `false` removes one of those.
-- tmux takes Ctrl-a (its prefix) before Neovim sees it, so the picker key on it moves. Keys you'd rarely
-- use go, so <Esc> ? (the key list) stays readable.
local picker_keys = {
  ["<A-a>"] = { "select_all", mode = { "i", "n" } }, -- (was <C-a>: tmux's prefix)
  ["<C-a>"] = false,
  ["<A-d>"] = false, -- inspect: dumps an item's data (for debugging pickers)
  ["<A-f>"] = false, -- follow symlinks
  ["<C-w>H"] = false, -- move the picker to a side of the screen
  ["<C-w>J"] = false,
  ["<C-w>K"] = false,
  ["<C-w>L"] = false,
  ["<C-r>#"] = false, -- insert file names into the search (<C-r><C-w>, the word under the cursor, stays)
  ["<C-r>%"] = false,
  ["<C-r><C-f>"] = false,
  ["<C-r><C-p>"] = false,
}

---@type LazySpec
return {
  "folke/snacks.nvim",
  init = function()
    -- The key list (<Esc> ? in a picker) writes Alt keys as <M-x>, Neovim's name for them: show <A-x>,
    -- the name this config uses. (The list is virtual text: one extmark per line.)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "snacks_win_help",
      desc = "Write Alt keys as <A-x> in Snacks' key list",
      callback = function(args)
        vim.schedule(function() -- the text is written just after the window opens
          if not vim.api.nvim_buf_is_valid(args.buf) then return end
          local ns = vim.api.nvim_create_namespace "snacks.win.help"
          for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(args.buf, ns, 0, -1, { details = true })) do
            local id, row, col, details = unpack(mark)
            for _, chunk in ipairs(details.virt_text or {}) do
              chunk[1] = chunk[1]:gsub("<M%-", "<A-")
            end
            vim.api.nvim_buf_set_extmark(
              args.buf,
              ns,
              row,
              col,
              { id = id, virt_text = details.virt_text, virt_text_pos = details.virt_text_pos }
            )
          end
        end)
      end,
    })
  end,
  opts = {
    indent = { enabled = false }, -- no indent guide lines
    picker = {
      actions = {
        only_this_kind = function(picker) -- <A-t> in grep pickers (see same_kind above)
          local glob = same_kind(picker)
          if not glob then return end
          picker.opts.glob = picker.opts.glob ~= glob and glob or nil
          picker.opts.toggles.glob = { icon = glob, value = glob }
          picker.list:set_target()
          picker:find()
        end,
        parent_folder = function(picker)
          local dirs = picker.opts.dirs
          if dirs and #dirs > 0 then -- e.g. <Leader>fa, which searches ~/.config/nvim
            picker.opts.dirs = { vim.fn.fnamemodify(vim.fs.normalize(dirs[1]), ":h") }
          else
            picker:set_cwd(vim.fn.fnamemodify(vim.fs.normalize(picker:cwd()), ":h"))
          end
          show_folder_in_title(picker)
          picker:find()
        end,
      },
      sources = {
        -- include dotfiles (.git is always skipped)
        files = { hidden = true, exclude = { "node_modules" }, on_show = show_folder_in_title, win = up_a_folder },
        -- (toggles.glob: the <A-t> flag in the title; set when pressed, this just gets it a highlight)
        grep = {
          hidden = true,
          exclude = { "node_modules" },
          on_show = show_grep_legend,
          win = grep_win,
          toggles = { glob = false },
        },
        grep_word = { on_show = show_grep_legend, win = grep_win, toggles = { glob = false } },
      },
      -- Commit previews (<Leader>gD, <Leader>gr) as a plain diff: the decorated style frames git's
      -- guess at the enclosing definition like a heading, which misleads in Lua (git has no Lua rule)
      previewers = { diff = { style = "syntax" } },
      win = {
        input = {
          -- Keep <C-u>/<C-d> as normal insert-mode keys in the search box (<C-u> clears it) instead of
          -- scrolling the result list.
          keys = vim.tbl_extend("force", picker_keys, { ["<C-u>"] = false, ["<C-d>"] = false }),
        },
        list = { keys = picker_keys },
      },
    },
  },
}
