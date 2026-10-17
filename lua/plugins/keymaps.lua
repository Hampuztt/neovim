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
      function()
        local dir = vim.bo.filetype == "oil" and require("oil").get_current_dir() or vim.fn.expand "%:p:h"
        require("snacks").picker.files { cwd = dir }
      end,
      desc = "Find files in this file's folder",
    },
    ["<Leader>fw"] = { function() require("snacks").picker.grep() end, desc = "Find words (grep)" },
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

    -- Git (vim-fugitive)
    ["<Leader>gs"] = { "<Cmd>vert Git<CR>", desc = "Git status (vertical split)" },
    ["<Leader>gS"] = { "<Cmd>Git<CR>", desc = "Git status (horizontal split)" },
    ["<Leader>gd"] = { "<Cmd>Gvdiffsplit<CR>", desc = "Git diff split" },
    ["<Leader>gb"] = { "<Cmd>Git blame<CR>", desc = "Git blame" },
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
    ["J"] = { "mzJ`z", desc = "Join lines (cursor stays put)" },
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
    ["<Leader>x"] = { "<Cmd>source %<CR>", desc = "Source this file" },
    ["<Leader><Leader>x"] = { "<Cmd>source %<CR>", desc = "Source this file" },
    ["<Leader>rr"] = { "<Cmd>AstroReload<CR>", desc = "Reload config (experimental, restart if a key acts up)" },
  },

  x = {
    ["J"] = { ":m '>+1<CR>gv=gv", desc = "Move selection down" },
    ["K"] = { ":m '<-2<CR>gv=gv", desc = "Move selection up" },
    ["<Leader>s"] = { ":sort<CR>", desc = "Sort selected lines" },
    ["<Leader>x"] = { ":lua<CR>", desc = "Run selected Lua" },
    ["<Leader>y"] = { '"+y', desc = "Yank to system clipboard" },
    ["<Leader>p"] = { '"+p', desc = "Paste from system clipboard" },
    ["<Leader>P"] = { '"+P', desc = "Paste from system clipboard (before cursor)" },
    -- ["<Leader>d"] = { '"_d', desc = "Delete without overwriting your last yank" },
  },

  -- Insert mode: jj, jk and kk leave insert mode. That's set in better-escape.lua, not here,
  -- so that typing a single j or k doesn't lag.
}

local lsp = {
  n = {
    ["gd"] = { function() vim.lsp.buf.definition() end, desc = "Go to definition" },
    ["gD"] = {
      function() vim.lsp.buf.declaration() end,
      desc = "Go to declaration",
      cond = "textDocument/declaration",
    },
    ["gi"] = { function() vim.lsp.buf.implementation() end, desc = "Go to implementation" },
    ["gy"] = { function() vim.lsp.buf.type_definition() end, desc = "Go to type definition" },
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
    ["<Leader>="] = { function() vim.lsp.buf.format() end, desc = "Format file" },
    ["<Leader>fs"] = { function() require("snacks").picker.lsp_symbols() end, desc = "Find symbols in this file" },
    ["<Leader>fd"] = { function() require("snacks").picker.lsp_definitions() end, desc = "Find definitions" },
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
    "]e", -- next/previous error and warning
    "[e",
    "]w",
    "[w",
    "]d", -- Neovim's next/previous diagnostic
    "[d",
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
