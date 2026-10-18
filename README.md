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
| statusline, Harpoon tabs at the top      | `lua/plugins/heirline.lua`             |
| file picker (Snacks) settings            | `lua/plugins/snacks.lua`               |
| language packs (AstroCommunity)          | `lua/community.lua`                    |
| what `<F5>` runs per filetype            | `lua/run_file.lua`                     |
| branch review (`<Leader>gm`)             | `lua/git_review.lua`                   |
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

## Dependencies

Programs this config expects on the system. `:checkhealth astronvim` and `:Mason` show what's
missing. Ubuntu package names are in brackets.

### Required

| What | Why |
| --- | --- |
| Neovim **0.12+** | nvim-treesitter (main branch) needs 0.12; `<Leader>rr` uses `:restart` |
| git | plugin manager, fugitive, gitsigns |
| a [Nerd Font](https://www.nerdfonts.com) in the terminal | icons |
| curl, tar, gzip, unzip | Mason and treesitter downloads |
| a C compiler [`gcc`] | building treesitter parsers |
| ripgrep [`ripgrep`] | `<Leader>fw` grep and the file picker |
| Node.js + npm | about half the language servers Mason installs (html, css, json, yaml, bash, TypeScript, docker compose, ansible, ...) |
| Python 3 with venv + pip [`python3-venv python3-pip`] | Mason installs basedpyright and ansible-lint into Python venvs |

Mason installs the rest itself: lua-language-server, basedpyright, ruff, clangd, stylua,
tree-sitter-cli (treesitter needs 0.26.1+), and the tools of the AstroCommunity packs.

### For specific features

| What | Used by |
| --- | --- |
| tmux + [tpm](https://github.com/tmux-plugins/tpm) with `christoomey/vim-tmux-navigator` in `tmux.conf` | `<C-h/j/k/l>` across tmux panes |
| xclip or xsel (X11), wl-clipboard (Wayland) | `<Leader>y` / `<Leader>p` system clipboard |
| python3 | `<F5>` on Python files |
| g++ | `<F5>` on C++ files |
| `compile_commands.json` | clangd in C++/ROS2 projects. colcon: `colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` (clangd finds `build/compile_commands.json` on its own) |
| lazygit | `<Leader>gg` |
| lazydocker | `<Leader>td` (from the lazydocker community pack) |

### Optional

| What | Used by |
| --- | --- |
| fd [`fd-find`] | faster file picker (ripgrep is used otherwise) |
| gdu, btm | AstroNvim's `<Leader>tu` (disk usage) and `<Leader>tt` (system monitor) |
| `set -g focus-events on` in `tmux.conf` | instant notice when a file changes on disk (otherwise it's noticed within a moment, on the next cursor pause) |

## Tests

`tests/run.sh` tries the features of this config with your real config (about 10 seconds):
editing keys, the find/grep pickers, git history/blame/compare, the branch review (`<Leader>gm`),
undoable discards in the git status window, the CHANGED ON DISK badge, and the Harpoon tabs.

```bash
tests/run.sh               # everything
tests/run.sh review disk   # some groups: editing pickers git review discard disk harpoon
```

Each group runs in its own headless Neovim in throwaway git repos, so your files, repos, clipboard,
recent-files list and Harpoon marks aren't touched. The tests are in `tests/features.lua`. With
the dotfiles repo, `~/dotfiles/tests/check.sh` runs these too, plus Neovim inside a real tmux.

## Updating

- Plugins: `:Lazy update` (run it twice when AstroNvim says pinned versions changed)
- Tools / language servers: `:Mason`
- New AstroNvim major version: change `version = "^6"` in `lua/lazy_setup.lua`, then
  `:Lazy update` twice. Check the [AstroNvim changelog](https://github.com/AstroNvim/AstroNvim/blob/main/CHANGELOG.md) first.
