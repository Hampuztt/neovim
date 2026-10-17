-- Tools that Mason installs automatically (names as shown in :Mason).
-- Language servers in this list start on their own when you open a matching file.

---@type LazySpec
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = {
    ensure_installed = {
      -- language servers
      "lua-language-server",
      "basedpyright", -- Python (types, go to definition, hover, rename, ...)
      "ruff", -- Python linting/formatting
      "clangd", -- C / C++

      -- formatters
      "stylua",

      -- other
      "tree-sitter-cli",
    },
  },
}
