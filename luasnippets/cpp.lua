-- Your own C++ snippets. Type the trigger (e.g. `doxy`) in insert mode and pick it from the
-- completion menu; <Tab> / <S-Tab> jump between the fields.
-- Each <> in a template is a field, filled in order by the list after it.
-- Files in luasnippets/ are loaded automatically: luasnippets/python.lua would hold Python snippets.

local ls = require "luasnip"
local s, i = ls.snippet, ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

local doxygen = [[
/**
 * @brief <>
 *
 * @details <>
 *
 * @param[in] <> <>
 * @param[out] <> <>
 * @param[in,out] <> <>
 *
 * @return <>
 *
 * @retval <> <>
 * @retval <> <>
 *
 * @throws <> <>
 *
 * @tparam <> <>
 *
 * @pre <>
 * @post <>
 *
 * @warning <>
 * @note <>
 * @see <>
 * @bug <>
 * @todo <>
 *
 * @author <>
 * @date <>
 */]]

return {
  s(
    { trig = "doxy", desc = "Full Doxygen comment block" },
    fmta(doxygen, {
      i(1, "Short description of the function"),
      i(2, "Longer description (optional)"),
      i(3, "param1"),
      i(4, "Description of input parameter"),
      i(5, "param2"),
      i(6, "Description of output parameter"),
      i(7, "param3"),
      i(8, "Description if param is modified"),
      i(9, "Return value description"),
      i(10, "0"),
      i(11, "Meaning of return value"),
      i(12, "-1"),
      i(13, "Other meaning"),
      i(14, "std::exception"),
      i(15, "Condition under which it is thrown"),
      i(16, "T"),
      i(17, "Template parameter description"),
      i(18, "Preconditions required"),
      i(19, "Postconditions guaranteed"),
      i(20, "Caveats or risks"),
      i(21, "Additional info"),
      i(22, "Related function/class"),
      i(23, "Known issue"),
      i(24, "To be implemented"),
      i(25, "Your Name"),
      i(26, "YYYY-MM-DD"),
    })
  ),
}
