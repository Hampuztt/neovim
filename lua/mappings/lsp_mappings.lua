return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          -- second key is the lefthand side of the map
          -- mappings seen under group name "Buffer"
          ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
          ["<Leader>bD"] = {
            function()
              require("astroui.status").heirline.buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Pick to close",
          },

          -- ["<Leader>o"] = {
          --   function() vim.cmd.Ex() end,
          --   desc = "Open file explorer",
          -- },
          -- vim.keymap.set("n", "<leader>o", vim.cmd.Ex)
          -- tables with just a `desc` key will be registered with which-key if it's installed
          -- this is useful for naming menus
          ["<Leader>b"] = { desc = "Buffers" },
          -- quick save
          -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
        },
        t = {
          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      mappings = {
        n = {

          gh = {
            "<cmd>ClangdSwitchSourceHeader<CR>",
            desc = "Switch between source/header (Clangd)",
          },
          gD = {
            function() vim.lsp.buf.declaration() end,
            desc = "Go to declaration",
            cond = "textDocument/declaration",
          },
          gd = {
            function() vim.lsp.buf.definition() end,
            desc = "Go to definition",
          },
          K = {
            function() vim.lsp.buf.hover() end,
            desc = "Hover documentation",
          },
          gi = {
            function() vim.lsp.buf.implementation() end,
            desc = "Go to implementation",
          },
          gr = {
            function() require("snacks.picker").lsp_references() end,
            desc = "Show references (Snacks)",
          },
          ["<leader>ca"] = {
            function() vim.lsp.buf.code_action() end,
            desc = "Code actions",
          },
          ["<F2>"] = {
            function() vim.lsp.buf.rename() end,
            desc = "Rename symbol",
          },
          ["<leader>D"] = {
            function() vim.lsp.buf.incoming_calls() end,
            desc = "Go to type definition",
          },
          ["<leader>e"] = {
            function() vim.diagnostic.open_float() end,
            desc = "Show diagnostics (float)",
          },
          ["<leader>fs"] = {
            function() require("snacks.picker").lsp_symbols() end,
            desc = "Find workspace symbols",
          },
          ["<leader>fd"] = {
            function() require("snacks.picker").lsp_definitions() end,
            desc = "Search document symbols",
          },
          ["<leader>="] = {
            function() vim.lsp.buf.format() end,
            desc = "Format document",
          },
        },
      },
    },
  },
}
