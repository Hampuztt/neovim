---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- { import = "astrocommunity.color.transparent-nvim" },
  { import = "astrocommunity.recipes.disable-tabline" },
  { import = "astrocommunity.utility.lua-json5" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  { import = "astrocommunity.pack.ansible" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.docker.lazydocker" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.typescript" },
  -- { import = "astrocommunity.workflow.precognition-nvim" },
  -- { import = "astrocommunity.recipes.diagnostic-virtual-lines-current-line" },
  -- import/override with your plugins folder
}
