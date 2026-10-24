-- todo-comments: TODO:, FIXME:, NOTE:, HACK:, ... in comments get highlighted, and <Leader>fT lists them.
-- The default paints each keyword as a bold block of its own color (red, blue, ...) and tints the rest
-- of the comment. Here the keyword is just the comment color in bold, so you see it when you look,
-- and it doesn't pull your eye when you don't. The gutter sign gets the same grey.

---@type LazySpec
return {
  "folke/todo-comments.nvim",
  opts = {
    highlight = {
      keyword = "fg", -- color the keyword's text (default "wide": a block of color around it)
      after = "", -- the text after it stays a normal comment (default "fg": colored too)
    },
    -- Every category takes its color from the Comment highlight group (works with any colorscheme)
    colors = {
      error = { "Comment" },
      warning = { "Comment" },
      info = { "Comment" },
      hint = { "Comment" },
      default = { "Comment" },
      test = { "Comment" },
    },
    gui_style = { fg = "BOLD", bg = "BOLD" }, -- bold is what makes it stand out at all
  },
}
