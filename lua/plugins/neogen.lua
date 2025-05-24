return {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
        require("neogen").setup({
            snippet_engine = "luasnip",
            languages = {
                cpp = {
                    template = {
                        annotation_convention = "doxygen",
                        func = function()
                            local ls = require("luasnip")
                            local t = ls.text_node
                            local i = ls.insert_node

                            return {
                                t({ "/**",
                                    " * @brief " }), i(1, "Short description of the function"),
                                t({ "",
                                    " *",
                                    " * @details" }), i(2, "Longer description (optional)"),
                                t({ "",
                                    " *",
                                    " * @param[in] " }), i(3, "param1"), t { " " }, i(4, "Description of input parameter"),
                                t({ "",
                                    " * @param[out] " }), i(5, "param2"), t { " " }, i(6,
                                "Description of output parameter"),
                                t({ "",
                                    " * @param[in,out] " }), i(7, "param3"), t { " " }, i(8,
                                "Description if param is modified"),
                                t({ "",
                                    " *",
                                    " * @return " }), i(9, "Return value description"),
                                t({ "",
                                    " *",
                                    " * @retval " }), i(10, "0"), t { " " }, i(11, "Meaning of return value"),
                                t({ "",
                                    " * @retval " }), i(12, "-1"), t { " " }, i(13, "Other meaning"),
                                t({ "",
                                    " *",
                                    " * @throws " }), i(14, "std::exception"), t { " " }, i(15,
                                "Condition under which it is thrown"),
                                t({ "",
                                    " *",
                                    " * @tparam " }), i(16, "T"), t { " " }, i(17, "Template parameter description"),
                                t({ "",
                                    " *",
                                    " * @pre " }), i(18, "Preconditions required"),
                                t({ "",
                                    " * @post " }), i(19, "Postconditions guaranteed"),
                                t({ "",
                                    " *",
                                    " * @warning " }), i(20, "Caveats or risks"),
                                t({ "",
                                    " * @note " }), i(21, "Additional info"),
                                t({ "",
                                    " * @see " }), i(22, "Related function/class"),
                                t({ "",
                                    " * @bug " }), i(23, "Known issue"),
                                t({ "",
                                    " * @todo " }), i(24, "To be implemented"),
                                t({ "",
                                    " *",
                                    " * @author " }), i(25, "Your Name"),
                                t({ "",
                                    " * @date " }), i(26, "YYYY-MM-DD"),
                                t({ "",
                                    " */" }),
                                i(0)
                            }
                        end
                    }
                }
            }
        })
    end,
    keys = {
        { "<leader>cd", function() require("neogen").generate() end, desc = "Generate doc comment" }
    }
}
