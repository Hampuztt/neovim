return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')

        cmp.setup {
            experimental = {
                ghost_text = false,
            },
        }

        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            vim.keymap.set("n", "<space>=", function() vim.lsp.buf.format() end),

            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "clangd",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities,
                        on_attach = function(client, bufnr)
                            local opts = { noremap = true, silent = true, buffer = bufnr }
                            local keymap = vim.keymap.set
                            keymap("n", "gD", vim.lsp.buf.declaration, opts)                                            -- Go to declaration
                            keymap("n", "gd", vim.lsp.buf.definition, opts)                                             -- Go to definition
                            keymap("n", "K", vim.lsp.buf.hover, opts)                                                   -- Hover documentation
                            keymap("n", "gi", vim.lsp.buf.implementation, opts)                                         -- Go to implementation
                            keymap("n", "gr", vim.lsp.buf.references, opts)                                             -- Show references
                            keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)                                    -- Code actions
                            keymap("n", "<F2>", vim.lsp.buf.rename, opts)                                               -- Rename symbol
                            keymap("n", "<leader>D", vim.lsp.buf.type_definition, opts)                                 -- Go to type definition
                            keymap("n", "[d", vim.diagnostic.goto_prev, opts)                                           -- Go to previous diagnostic
                            keymap("n", "]d", vim.diagnostic.goto_next, opts)                                           -- Go to next diagnostic
                            keymap("n", "<leader>e", vim.diagnostic.open_float, opts)                                   -- Show diagnostics in float
                            keymap("n", "<leader>q", vim.diagnostic.setloclist, opts)                                   -- Add diagnostics to loclist
                            keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)                                    -- Show code actions
                            keymap("n", "<leader>fs", require('telescope.builtin').lsp_dynamic_workspace_symbols, opts) -- Find all workspace symbols dynamically
                            keymap("n", "<leader>fd", require('telescope.builtin').lsp_document_symbols, opts)          -- Search document symbols
                            keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)                           -- Add workspace folder
                            keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)                        -- Remove workspace folder
                            keymap("n", "<leader>wl", function()
                                local folders = vim.lsp.buf.list_workspace_folders()
                                vim.api.nvim_echo({ { table.concat(folders, "\n"), "Normal" } }, false, {})
                            end, opts)
                            keymap("n", "gh", ":ClangdSwitchSourceHeader<CR>", opts)
                        end,
                    }
                end,


                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }


        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<Tab>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
