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
        -- WSL: use win32yank.exe for the system clipboard. It turns Windows line endings into
        -- Linux ones when you paste (no ^M), and back when you copy. Only if it's installed.
        clipboard = (vim.fn.has "wsl" == 1 and vim.fn.executable "win32yank.exe" == 1) and "win32yank" or nil,
      },
    },

    autocmds = {
      -- Notice when the open file is changed by another program (git, a formatter, ...).
      -- Without unsaved changes it just reloads, quietly. With unsaved changes, or if the file
      -- was deleted, your version is kept and the statusline says CHANGED / DELETED ON DISK until you
      -- :w! (keep yours) or :e! (take the one on disk). <Leader>rd shows the difference.
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
          event = "FileChangedShell",
          desc = "Reload a file changed on disk, or mark it if you have unsaved changes in it",
          callback = function(args)
            local name, reason = vim.fn.fnamemodify(args.file, ":t"), vim.v.fcs_reason
            if reason == "changed" then -- no unsaved changes (only seen with 'autoread' off: it reloads itself)
              vim.v.fcs_choice = "reload"
            elseif reason == "conflict" or reason == "deleted" then
              vim.b[args.buf].changed_on_disk = reason == "conflict" and "CHANGED ON DISK" or "DELETED ON DISK"
              vim.notify(
                reason == "conflict"
                    and (name .. " changed on disk, but you have unsaved changes: kept yours. <Leader>rd shows the difference, :w! keeps yours, :e! takes the one on disk")
                  or (name .. " was deleted on disk. :w writes it back"),
                vim.log.levels.WARN
              )
            end -- "mode" / "time" (only permissions or the timestamp changed): nothing to do
          end,
        },
        {
          event = { "BufReadPost", "BufWritePost" },
          desc = "Remove the CHANGED ON DISK mark once the buffer and the file match again",
          callback = function(args) vim.b[args.buf].changed_on_disk = nil end,
        },
      },
      -- Neovim (0.12.6) can crash when one side of a side-by-side diff closes (:q, :only, :tabclose,
      -- the review moving on) while a markdown file is in it: render-markdown reacts to the diff being
      -- updated halfway through the close. Closing one of two diff windows ends the diff anyway
      -- ('diffopt' has "closeoff"), so end it first, on both sides, before the window goes.
      end_diff_before_closing = {
        {
          event = "WinClosed",
          desc = "End a diff before one of its two windows closes (avoids a crash)",
          callback = function(args)
            local win = tonumber(args.match)
            if not (win and vim.api.nvim_win_is_valid(win) and vim.wo[win].diff) then return end
            local others = vim.tbl_filter(
              function(other) return other ~= win and vim.wo[other].diff end,
              vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(win))
            )
            if #others ~= 1 then return end
            for _, side in ipairs { win, others[1] } do
              vim.api.nvim_win_call(side, vim.cmd.diffoff)
            end
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
