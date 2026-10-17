-- The statusline at the bottom. Each line in `opts.statusline` is one piece, left to right.
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

    opts.statusline = {
      hl = { fg = "fg", bg = "bg" },
      condition = function() return vim.fn.mode() ~= "c" end, -- hidden while typing a : command
      status.component.mode(),
      status.component.git_branch(),
      file_folder,
      status.component.file_info { filename = {}, filetype = false },
      status.component.git_diff(),
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      status.component.diagnostics(),
      status.component.lsp(),
      status.component.virtual_env(),
      status.component.nav(),
    }
  end,
}
