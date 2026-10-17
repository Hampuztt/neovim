-- Tools that Mason installs automatically (names as shown in :Mason).
-- Language servers in this list start on their own when you open a matching file.
-- The community packs (community.lua) add their own tools on top of these.
local tools = {
  -- language servers
  "lua-language-server",
  "basedpyright", -- Python (types, go to definition, hover, rename, ...)
  "ruff", -- Python linting/formatting
  "clangd", -- C / C++

  -- formatters
  "stylua",

  -- other
  "tree-sitter-cli",
}

---@type LazySpec
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = function(_, opts)
    -- Add each tool only once: a tool that's listed twice (stylua is also in the Lua pack)
    -- makes :MasonToolsInstallSync wait forever on a fresh machine.
    opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, tools)
  end,
}
