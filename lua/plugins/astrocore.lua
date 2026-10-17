-- Editor options, autocommands and core AstroNvim features.
-- Keybindings are in keymaps.lua.  Docs: `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- files bigger than this skip treesitter, LSP, ...
      cmp = true, -- autocompletion on at start (<F6> toggles it per buffer)
      highlighturl = true,
      notifications = true,
    },

    diagnostics = {
      virtual_text = true, -- show errors/warnings at the end of the line
    },

    treesitter = {
      -- Installed on top of AstroNvim's defaults (bash, c, lua, markdown, python, vim, ...).
      -- Other languages are installed automatically the first time you open such a file.
      ensure_installed = { "cpp" },
    },

    options = {
      opt = { -- vim.opt.<name>
        number = true,
        relativenumber = true,
        signcolumn = "yes",
        wrap = false,
        spell = false,
        scrolloff = 20, -- keep 20 lines visible above/below the cursor
        clipboard = "", -- y/p stay inside Neovim; use <Leader>y / <Leader>p for the system clipboard
        swapfile = false,
      },
      g = { -- vim.g.<name>
      },
    },

    autocmds = {
      -- Notice when the open file is changed by another program (git, a formatter, ...).
      -- Unmodified buffers then reload on their own (Neovim's `autoread`) and you get a notification.
      -- AstroNvim only checks when the terminal regains focus, which tmux doesn't report by default.
      check_file_changed_on_disk = {
        {
          event = { "BufEnter", "CursorHold" },
          desc = "Check if the file changed on disk",
          callback = function()
            if vim.bo.buftype == "" and vim.fn.getcmdwintype() == "" then vim.cmd "checktime" end
          end,
        },
        {
          event = "FileChangedShellPost",
          desc = "Say when a file was reloaded because it changed on disk",
          callback = function(args)
            vim.notify(vim.fn.fnamemodify(args.file, ":t") .. " changed on disk and was reloaded", vim.log.levels.WARN)
          end,
        },
      },
      -- Hide the cursorline highlight while typing in insert mode.
      cursorline_in_insert_mode = {
        {
          event = "InsertEnter",
          desc = "Hide cursorline in insert mode",
          callback = function()
            vim.w.cursorline_before_insert = vim.wo.cursorline
            vim.wo.cursorline = false
          end,
        },
        {
          event = "InsertLeave",
          desc = "Restore cursorline after insert mode",
          callback = function()
            if vim.w.cursorline_before_insert then vim.wo.cursorline = true end
          end,
        },
      },
    },
  },
}
