---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      -- Configure core features of AstroNvim
      features = {
        large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
        -- autopairs = true, -- enable autopairs at start
        cmp = true, -- enable completion at start
        highlighturl = true, -- highlight URLs at start
        notifications = true, -- enable notifications at start
      },
      -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
      diagnostics = {
        virtual_text = true,
      },
      -- passed to `vim.filetype.add`
      filetypes = {
        -- see `:h vim.filetype.add` for usage
        extension = {
          foo = "fooscript",
        },
        filename = {
          [".foorc"] = "fooscript",
        },
        pattern = {
          [".*/etc/foo/.*"] = "fooscript",
        },
      },
      -- vim options can be configured here
      options = {
        opt = { -- vim.opt.<key>
          relativenumber = true, -- sets vim.opt.relativenumber
          number = true, -- sets vim.opt.number
          spell = false, -- sets vim.opt.spell
          signcolumn = "yes", -- sets vim.opt.signcolumn to yes
          wrap = false, -- sets vim.opt.wrap
          clipboard = "",
          scrolloff = 20,

          --   opt = {
          --      showtabline =0,
          --while      },
        },
        g = { -- vim.g.<key>

          -- configure global vim variables (vim.g)
          -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
          -- This can be found in the `lua/lazy_setup.lua` file
        },
      },
      -- Mappings can be configured through AstroCore as well.
      -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
      mappings = {
        -- first key is the mode
        n = {
          ["<Leader>fs"] = false,
          -- ["<Leader>p"] = false,
          --          ["<leader>p"] = false,      -- remove <leader>p group and all nested bindings
          ["<Leader>h"] = false,
          ["<Leader>pi"] = false,
          ["<Leader>ps"] = false,
          ["<Leader>pa"] = false,
          ["<Leader>pS"] = false,
          ["<Leader>pu"] = false,
          ["<Leader>pU"] = false,
          ["<Leader>pM"] = false,
          ["<Leader>pm"] = false,
          ["<Leader>c"] = false,
          ["<Leader>C"] = false,
          ["<Leader>lD"] = false,

          ["<Leader>lI"] = false, -- None-ls Info
          ["K"] = false, -- Hover Document
          ["<Leader>lf"] = false, -- Format Document
          ["<Leader>lS"] = false, -- Symbols Outline
          ["gl"] = false, -- Line Diagnostics
          ["<Leader>ld"] = false,
          ["<C-w>d"] = false,
          ["gra"] = false, -- Code Actions
          ["<Leader>la"] = false,
          ["<Leader>lA"] = false, -- Source Code Actions
          ["<Leader>lh"] = false, -- Signature Help
          ["grn"] = false, -- Rename
          ["<Leader>lr"] = false,
          ["<Leader>ls"] = false, -- Document Symbols
          ["<Leader>lG"] = false, -- Workspace Symbols
          ["]d"] = false, -- Diagnostic Next
          ["[d"] = false, -- Diagnostic Previous
          ["]e"] = false, -- Diagnostic Error Next
          ["[e"] = false, -- Diagnostic Error Previous
          ["]w"] = false, -- Diagnostic Warning Next
          ["[w"] = false, -- Diagnostic Warning Previous
          ["]y"] = false, -- Document Symbol Next
          ["[y"] = false, -- Document Symbol Previous
          ["gO"] = false, -- Document Symbol
          ["gy"] = false, -- Type Definition
          ["gd"] = false, -- Definition
          ["gri"] = false, -- Implementation
          ["grr"] = false, -- References
          ["<Leader>lR"] = false,

          ["<leader>p"] = { '"+p', desc = "Paste from system clipboard" },
          ["<leader>P"] = { '"+P', desc = "Paste from system clipboard" },

          -- second key is the lefthand side of the map

          -- navigate buffer tabs
          ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

          -- mappings seen under group name "Buffer"
          ["<Leader>bd"] = {
            function()
              require("astroui.status.heirline").buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Close buffer from tabline",
          },

          -- tables with just a `desc` key will be registered with which-key if it's installed
          -- this is useful for naming menus
          -- ["<Leader>b"] = { desc = "Buffers" },

          -- setting a mapping to false will disable it
          -- ["<C-S>"] = false,
          -- ["<Leader>ll"] = {
          --   cond = function()
          --     return false
          --   end,
          -- },
        },
        v = {
          ["<Leader>s"] = { "<cmd>'<,'>sort<CR>", desc = "Sort marked lines" }, -- change description but the same command
        },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
    opts = {
      window = {
        position = "current",
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_current",
      },
      name = { trailing_slash = false },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function() end, -- disables all default mappings
    },
  },
  -- lazy.nvim
  {
    "folke/snacks.nvim",
    opts = {
      indent = {
        enabled = false,
        only_scope = true, -- only show indent guides of the scope
        only_current = true, -- only show indent guides in the current window
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      -- type false | "classic" | "modern" | "helix"
      ["<leader>gl"] = {},
      win = {
        -- don't allow the popup to overlap with the cursor
        no_overlap = true,
        -- width = 1,
        -- height = { min = 4, max = 25 },
        -- col = 0,
        -- row = 0,
        -- col = vim.o.columns,
        -- anchor = "NE", -- optional: anchor top-right corner
        -- anchor = "NE",  -- optional: anchor top-right corner
        -- row = math.huge,
        -- border = "none",
        padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
        title = true,
        title_pos = "center",
        zindex = 500,
        -- Additional vim.wo and vim.bo options
        bo = {},
        wo = {
          -- winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
        },
      },
      --     name = "+group gitlab",
      --     desc = "meow",
      --     r = { name = "+review" },
      --     m = { name = "+merge requests" },
      --     c = { name = "+comments" },
      --     d = { name = "+discussion" },
      --     l = { name = "+labels" },
      --     R = { name = "+reviewers" },
      --     a = { name = "+assignees" },
      --     s = { name = "+settings/debug" },
      --     p = { name = "+pipeline" },
      --   },
      -- },
    },
  },
}
