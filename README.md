# Neovim config

[AstroNvim](https://astronvim.com) v6 on Neovim 0.12 (tested with 0.12.6).

## Where things are

| I want to change...                      | File                                   |
| ---------------------------------------- | -------------------------------------- |
| **any keybinding**                       | `lua/plugins/keymaps.lua`              |
| editor options, autocommands, treesitter | `lua/plugins/astrocore.lua`            |
| language servers, formatting             | `lua/plugins/astrolsp.lua`             |
| tools Mason installs                     | `lua/plugins/mason.lua`                |
| colorscheme                              | `lua/plugins/astroui.lua`              |
| statusline                               | `lua/plugins/heirline.lua`             |
| file picker (Snacks) settings            | `lua/plugins/snacks.lua`               |
| language packs (AstroCommunity)          | `lua/community.lua`                    |
| what `<F5>` runs per filetype            | `lua/run_file.lua`                     |
| my own snippets                          | `luasnippets/<filetype>.lua`           |
| AstroNvim version                        | `lua/lazy_setup.lua`                   |

Every other file in `lua/plugins/` sets up one plugin (Oil, Harpoon, git, ...)
and starts with a comment saying what it does. (`dap.lua` just turns the debugger off.)

## Keybindings

All keys are in `lua/plugins/keymaps.lua`, in three tables:

- `general`: work everywhere
- `lsp`: only in buffers with a language server
- `disabled`: AstroNvim/Neovim defaults that are turned off (delete a line to get one back)

Your keys always win over AstroNvim's defaults. `<Leader>` is Space; press it and wait to
see what's available, or use `<Leader>fk` to search all keys.

## Updating

- Plugins: `:Lazy update` (run it twice when AstroNvim says pinned versions changed)
- Tools / language servers: `:Mason`
- New AstroNvim major version: change `version = "^6"` in `lua/lazy_setup.lua`, then
  `:Lazy update` twice. Check the [AstroNvim changelog](https://github.com/AstroNvim/AstroNvim/blob/main/CHANGELOG.md) first.
