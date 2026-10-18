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

---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    indent = { enabled = false }, -- no indent guide lines
    picker = {
      actions = {
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
        grep = { hidden = true, exclude = { "node_modules" }, on_show = show_folder_in_title, win = up_a_folder },
        grep_word = { on_show = show_folder_in_title, win = up_a_folder },
      },
      win = {
        input = {
          keys = {
            -- Keep <C-u>/<C-d> as normal insert-mode keys in the search box (<C-u> clears it)
            -- instead of scrolling the result list.
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
      },
    },
  },
}
