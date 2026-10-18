-- The statusline at the bottom (each line in `opts.statusline` is one piece, left to right), and the
-- tabline at the top, which shows your Harpoon files.
-- Available pieces: `:h astroui` (search for "status.component").

---@type LazySpec
return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"

    -- Folder of the current file, relative to its git repo (full path outside a repo).
    local file_folder = status.component.builder {
      provider = function()
        local file = vim.api.nvim_buf_get_name(0)
        if file == "" or vim.bo.buftype ~= "" then return "" end
        local folder = vim.fs.dirname(file)
        local repo = vim.fs.root(file, ".git")
        if repo and folder:find(repo, 1, true) == 1 then return folder:sub(#repo + 2) end
        return folder
      end,
      update = { "BufEnter", "BufFilePost", "DirChanged" }, -- only recompute when the file changes
      hl = { fg = "fg" },
      padding = { left = 1 },
    }

    -- A red CHANGED ON DISK / DELETED ON DISK while the file no longer matches what you're editing
    -- (set by the check_file_changed_on_disk autocommands in astrocore.lua)
    local changed_on_disk = status.component.builder {
      condition = function() return vim.b.changed_on_disk ~= nil end,
      provider = function() return " " .. vim.b.changed_on_disk .. " " end,
      hl = { fg = "bg", bg = "diag_ERROR", bold = true },
      padding = { left = 1 },
    }

    opts.statusline = {
      hl = { fg = "fg", bg = "bg" },
      condition = function() return vim.fn.mode() ~= "c" end, -- hidden while typing a : command
      status.component.mode(),
      status.component.git_branch(),
      file_folder,
      status.component.file_info { filename = {}, filetype = false },
      changed_on_disk,
      status.component.git_diff(),
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      status.component.diagnostics(),
      status.component.lsp(),
      status.component.virtual_env(),
      status.component.nav(),
    }

    -- Tabline: one tab per file you added with <Leader>a, in Harpoon's order (reorder them in the
    -- <Leader><Tab> menu), numbered like <Leader>1 ... <Leader>6. The file you're in is highlighted and
    -- clicking a tab opens its file. Other files you open (gd, the file picker, ...) don't get a tab.
    -- harpoon.lua hides the tabline while there are no Harpoon files.

    -- This folder's Harpoon files: { number = its <Leader> number, name = shown in the tab, current = you're in it }
    local function harpoon_files()
      local list, current = require("harpoon"):list(), vim.api.nvim_buf_get_name(0)
      local files = {}
      for number = 1, list:length() do
        local item = list:get(number) -- nil for an empty line in the menu
        if item then
          local path = vim.fn.fnamemodify(item.value, ":p")
          table.insert(files, { number = number, path = path, current = path == current })
        end
      end
      for _, file in ipairs(files) do -- two files with the same name (init.lua, ...) also show their folder
        local name = vim.fs.basename(file.path)
        local same_name = vim.tbl_filter(function(other) return vim.fs.basename(other.path) == name end, files)
        file.name = #same_name > 1 and vim.fs.basename(vim.fs.dirname(file.path)) .. "/" .. name or name
      end
      return files
    end

    local harpoon_tab = {
      provider = function(self) return (" %d %s "):format(self.file.number, self.file.name) end,
      hl = function(self) return status.hl.get_attributes(self.file.current and "buffer_active" or "buffer", true) end,
      on_click = {
        callback = function(_, number) require("harpoon"):list():select(number) end,
        minwid = function(self) return self.file.number end,
        name = "heirline_harpoon_tab",
      },
    }

    opts.tabline = {
      { -- one harpoon_tab per file
        init = function(self)
          local files = harpoon_files()
          for i, file in ipairs(files) do
            -- rawget: self[i] would look in the parent when there's no tab i yet
            self[i] = rawget(self, i) or self:new(harpoon_tab, i)
            self[i].file = file
          end
          for i = #self, #files + 1, -1 do
            self[i] = nil
          end
        end,
      },
      status.component.fill { hl = { bg = "tabline_bg" } },
      { -- Neovim's own tabs (e.g. <Leader>ll's LSP log) on the right, only while more than one is open
        condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
        status.heirline.make_tablist {
          provider = status.provider.tabnr(),
          hl = function(self) return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true) end,
        },
      },
    }
  end,
}
