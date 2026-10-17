-- Language servers and formatting. LSP keybindings are in keymaps.lua.  Docs: `:h astrolsp`
--
-- Language servers you install with :Mason start automatically (add them to mason.lua so a new
-- machine gets them too). Per-server settings go in `config` below.

-- LSP log (view it with <Leader>ll). "WARN" records errors, crashes and server error output.
-- Use "DEBUG" to see every message between Neovim and the servers (the log gets big fast).
vim.lsp.log.set_level "WARN"

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false, -- <Leader>uH toggles them
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = { enabled = false }, -- format by hand with <Leader>=
      timeout_ms = 3000,
      disabled = { "lua_ls" }, -- servers that shouldn't format (Lua is formatted by stylua)
    },
    -- Settings passed to `vim.lsp.config` for each server (see `:h vim.lsp.Config`)
    config = {
      -- "*" applies to every server. Python files get two servers (basedpyright + ruff); make them
      -- count characters the same way so positions (rename, references, ...) always line up.
      ["*"] = { capabilities = { general = { positionEncodings = { "utf-16" } } } },
      basedpyright = {
        settings = {
          basedpyright = {
            -- "standard" = normal type errors. basedpyright's default ("recommended") is much stricter.
            analysis = { typeCheckingMode = "standard" },
          },
        },
      },
    },
    -- Turn a server off even though Mason has it installed: `name = false`
    handlers = {
      pyrefly = false, -- was buggy; delete this line (and add it to mason.lua) to use it again
      stylua = false, -- stylua already runs through none-ls (lua pack); don't start it twice
    },
  },
}
