local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {

    s("ttest", {
        t("ttest_ind("),
        i(1, "arr1"),
        t(", "),
        i(2, "arr2"),
        t(", equal_var="),
        i(3, "True"),
        t(")"),
        i(0),
    }),

    s("chi", {
        t("chi2, p, dof, expected = chi2_contingency("),
        i(1, "observed"),
        t(")"),
        i(0)
    }),

    s("corrp", {
        t("r, p = pearsonr("),
        i(1, "x"),
        t(", "),
        i(2, "y"),
        t(")"),
        i(0),
    }),

    s("anova", {
        t("f_stat, p = f_oneway("),
        i(1, "group1"),
        t(", "),
        i(2, "group2"),
        t(", equal_var="),
        i(3, "True"),
        t(", axis="),
        i(4, "0"),
        t(")"),
        i(0),
    }),

    s("normal", {
        t("stat, p = normaltest("),
        i(1, "data"),
        t(")"),
        i(0),
    }),

}
