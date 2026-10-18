-- make-ls: language server for Makefiles (hover, go to definition, completion, warnings, ...).
-- Its settings for Neovim are in astrolsp.lua (`make_ls`).
-- To update it, change the version in `id` (releases: https://github.com/owenrumney/make-ls/releases),
-- restart Neovim (<Leader>rr: Mason only reads this file at startup), then update it in :Mason.

return {
  name = "make-ls",
  description = "Language server for Makefiles.",
  homepage = "https://github.com/owenrumney/make-ls",
  licenses = { "MIT" },
  languages = { "Makefile" },
  categories = { "LSP" },
  source = {
    id = "pkg:github/owenrumney/make-ls@v0.1.25",
    asset = {
      { target = "linux_x64", file = "make-ls_linux_amd64.tar.gz", bin = "make-ls" },
      { target = "linux_arm64", file = "make-ls_linux_arm64.tar.gz", bin = "make-ls" },
      { target = "darwin_x64", file = "make-ls_darwin_amd64.tar.gz", bin = "make-ls" },
      { target = "darwin_arm64", file = "make-ls_darwin_arm64.tar.gz", bin = "make-ls" },
    },
  },
  bin = { ["make-ls"] = "{{source.asset.bin}}" },
  neovim = { lspconfig = "make_ls" }, -- installing it starts the `make_ls` server in Makefiles
}
