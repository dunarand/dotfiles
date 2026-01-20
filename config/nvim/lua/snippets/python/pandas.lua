local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {

	s("csv", {
		t('pd.read_csv("'),
		i(1, "filename"),
		t('.csv")'),
		i(0),
	}),

	s("grp", {
		t('groupby(by="'),
		i(1, "column"),
		t('")'),
		i(0),
	}),

	s("2csv", {
		t('to_csv("'),
		i(1, "outpath"),
		t('", encoding="utf-8", header='),
		i(2, "True"),
		t(", index="),
		i(3, "False"),
		t(")"),
		i(0),
	}),

	s("inf", {
		t("info()"),
		i(0),
	}),

	s("desc", {
		t("describe()"),
		i(0),
	}),

	s("hd", {
		t("head(10)"),
		i(0),
	}),

	s("vc", {
		t("value_counts()"),
		i(0),
	}),

	s("na", {
		t(".isna().sum()"),
		i(0),
	}),

	s("srt", {
		t('sort_values(by="'),
		i(1, "col"),
		t('", ascending='),
		i(2, "True"),
		t(")"),
		i(0),
	}),

	s("rst", {
		t("reset_index(drop="),
		i(1, "True"),
		t(")"),
		i(0),
	}),

	s("corrm", {
		i(1, "corr_matrix"),
		t(" = "),
		i(2, "df"),
		t(".corr(method='pearson')"),
		i(0),
	}),
}
