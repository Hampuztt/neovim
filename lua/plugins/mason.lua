-- Tools that Mason installs automatically (names as shown in :Mason).
-- Language servers in this list start on their own when you open a matching file.
-- The community packs (community.lua) add their own tools on top of these.
local tools = {
  -- language servers
  "lua-language-server",
  "basedpyright", -- Python (types, go to definition, hover, rename, ...)
  "ruff", -- Python linting/formatting
  "clangd", -- C / C++
  "make-ls", -- Makefiles (not in Mason's own registry: described in lua/mason-packages/)

  -- formatters
  "stylua",

  -- other
  "tree-sitter-cli",
}

---@type LazySpec
return {
  {
    "mason-org/mason.nvim",
    -- Packages Mason's own registry doesn't have, described in lua/mason-packages/
    opts = function(_, opts)
      opts.registries = require("astrocore").list_insert_unique(opts.registries, { "lua:mason-packages" })
    end,
    config = function(_, opts)
      require("mason").setup(opts)
      -- Load lua/mason-packages/ right away. Until it's loaded, Mason counts it as a registry that
      -- isn't installed, and downloads all of them again on every start (instead of once a day).
      local lua_registry = require "mason-registry.sources.lua"
      for source in require("mason-registry").sources:iterate { include_uninstalled = true } do
        if getmetatable(source) == lua_registry and not source:is_installed() then source:install() end
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      -- Add each tool only once: a tool that's listed twice (stylua is also in the Lua pack)
      -- makes :MasonToolsInstallSync wait forever on a fresh machine.
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, tools)
    end,
  },
}
