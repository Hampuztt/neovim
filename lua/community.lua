-- AstroCommunity: ready-made setups (language support, recipes) maintained by the community.
-- Browse them at https://github.com/AstroNvim/astrocommunity. Delete a line to remove one.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- language packs (language server, formatter, treesitter parser, ...)
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.ansible" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.xml" }, -- lemminx: errors, schema completion (formatting is off: astrolsp.lua)

  -- tools
  { import = "astrocommunity.docker.lazydocker" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  { import = "astrocommunity.recipes.disable-tabline" }, -- no buffer tabs (the top shows Harpoon files, heirline.lua)

  -- worth a look:
  -- { import = "astrocommunity.color.transparent-nvim" },
  -- { import = "astrocommunity.workflow.precognition-nvim" },
  -- { import = "astrocommunity.recipes.diagnostic-virtual-lines-current-line" },
}
