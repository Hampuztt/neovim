-- Neogen: writes a doc comment for the function under the cursor (<Leader>cd).
-- In C++ files, typing `doxy` and expanding the snippet inserts your full Doxygen template
-- instead (it lives in luasnippets/cpp.lua).

---@type LazySpec
return {
  "danymat/neogen",
  cmd = "Neogen",
  opts = {
    snippet_engine = "luasnip", -- lets you <Tab> through the generated fields
    languages = {
      cpp = { template = { annotation_convention = "doxygen" } },
    },
  },
}
