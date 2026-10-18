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
      -- Servers that shouldn't format. Lua is formatted by stylua. Delete "lemminx" to format XML.
      -- make_ls removes spaces at line ends, which in a Makefile can be part of a variable's value.
      disabled = { "lua_ls", "lemminx", "make_ls" },
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
      -- Makefiles. nvim-lspconfig doesn't know make-ls, so this says how to start it (Mason installs
      -- it: mason.lua). Included files are only found inside the root, so prefer the git repo.
      make_ls = {
        cmd = { "make-ls" },
        filetypes = { "make" },
        root_markers = { ".git", "Makefile", "makefile", "GNUmakefile" },
      },
      -- XML (formatting is off: see `disabled` above).
      -- All settings: https://github.com/redhat-developer/vscode-xml/blob/main/docs/Preferences.md
      lemminx = {
        settings = {
          xml = {
            -- Most config files have no schema (XSD/DTD); don't put a hint about that on every one.
            validation = { noGrammar = "ignore" },
            -- Every format setting must be here: lemminx turns the ones left out off instead of using
            -- their defaults (with `enabled` left out, formatting breaks and Neovim shows an error).
            -- These are VS Code's defaults, except maxLineWidth.
            format = {
              enabled = true,
              maxLineWidth = 0, -- don't wrap long lines (default 100): that puts line breaks inside text values
              splitAttributes = "preserve", -- attributes stay on one line, or one per line, as you wrote them
              preserveAttributeLineBreaks = true,
              splitAttributesIndentSize = 2,
              closingBracketNewLine = false,
              spaceBeforeEmptyCloseTag = true, -- <tag/> becomes <tag />
              preservedNewlines = 2, -- keep up to 2 blank lines between tags
              emptyElements = "ignore", -- <a></a> and <a/> stay as they are
              enforceQuoteStyle = "ignore",
              joinContentLines = false,
              joinCommentLines = false,
              joinCDATALines = false,
              xsiSchemaLocationSplit = "onPair",
              grammarAwareFormatting = true,
              legacy = false,
              preserveSpace = { -- elements whose whitespace is left alone
                "xsl:text",
                "xsl:comment",
                "xsl:processing-instruction",
                "literallayout",
                "programlisting",
                "screen",
                "synopsis",
                "pre",
                "xd:pre",
                "style",
                "script",
              },
            },
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
