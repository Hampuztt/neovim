return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"

    opts.statusline = { -- statusline
      hl = { fg = "fg", bg = "bg" },
      status.component.mode(),
      status.component.git_branch(),

      status.component.builder {
        hl = { fg = "fg" },

        provider = function()
          -- print(vim.inspect(require("astroui.status").component.file_info()))

          local filepath = vim.api.nvim_buf_get_name(0)
          local dirpath = vim.fn.fnamemodify(filepath, ":h")
          local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

          if git_root and dirpath:find(git_root, 1, true) == 1 then
            return dirpath:sub(#git_root + 2) -- relative dir from Git root
          else
            return dirpath                    -- full absolute dir
          end
        end,
        padding = { left = 1 },
      },

      status.component.file_info {
        filename = {},
        filetype = false,
      },
      status.component.separated_path(),
      status.component.git_diff(),
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      status.component.diagnostics(),
      status.component.lsp(),
      status.component.virtual_env(),
      status.component.nav(),
    }

    -- opts.statuscolumn = { -- statuscolumn
    --   init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
    --   status.component.foldcolumn(),
    --   status.component.numbercolumn(),
    --   status.component.signcolumn(),
    -- }
  end,
}
