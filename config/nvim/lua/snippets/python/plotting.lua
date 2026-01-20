local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {

	-- Matplotlib

	s("xlbl", {
		t('plt.xlabel("'),
		i(1, "label"),
		t('")'),
		i(0),
	}),

	s("xlim", {
		t("plt.xlim(["),
		i(1, "left"),
		t(", "),
		i(2, "right"),
		t("])"),
		i(0),
	}),

	s("ylbl", {
		t('plt.ylabel("'),
		i(1, "label"),
		t('")'),
		i(0),
	}),

	s("ylim", {
		t("plt.ylim(["),
		i(1, "down"),
		t(", "),
		i(2, "up"),
		t("])"),
		i(0),
	}),

	s("ttl", {
		t('plt.title("'),
		i(1, "title"),
		t('")'),
		i(0),
	}),

	s("fig", {
		t("fig, ax = plt.figure(figsize=("),
		i(1, "width"),
		t(", "),
		i(2, "height"),
		t(")"),
		i(0),
	}),

	s("sub", {
		t("fig, ax = plt.subplots(nrows="),
		i(1, "rows"),
		t(", ncols="),
		i(2, "cols"),
		t({ ")", "", "fig.suptitle(" }),
		i(3, "title"),
		t({ '")', "" }),
		i(0),
	}),

	s("axv", {
		t("plt.axvline(x="),
		i(1, "value"),
		t(", color='"),
		i(2, "r"),
		t("', linestyle='--')"),
		i(0),
	}),

	s("axh", {
		t("plt.axhline(y="),
		i(1, "value"),
		t(", color='"),
		i(2, "r"),
		t("', linestyle='--')"),
		i(0),
	}),

	-- Seaborn

	s("box", {
		t("sns.boxplot(data="),
		i(1, "df"),
		t(', x="'),
		i(2, "col1"),
		t('", y="'),
		i(3, "col2"),
		i(0),
	}),

	s("hist", {
		t("sns.histplot(data="),
		i(1, "df"),
		t(', x="'),
		i(2, "col1"),
		t('", y="'),
		i(3, "col2"),
		t('")'),
		i(0),
	}),

	s("scat", {
		t("sns.scatterplot(data="),
		i(1, "df"),
		t(', x="'),
		i(2, "col1"),
		t('", y="'),
		i(3, "col2"),
		t('", hue="'),
		i(4, "col3"),
		t('")'),
		i(0),
	}),

	s("lin", {
		t("sns.lineplot(data="),
		i(1, "df"),
		t(', x="'),
		i(2, "col1"),
		t('", y="'),
		i(3, "col2"),
		t('")'),
		i(0),
	}),

	s("bar", {
		t("sns.barplot(data="),
		i(1, "df"),
		t(', x="'),
		i(2, "col1"),
		t('", y="'),
		i(3, "col2"),
		t('")'),
		i(0),
	}),

	s("cnt", {
		t("sns.countplot(data="),
		i(1, "df"),
		t(', x="'),
		i(2, "col"),
		t('")'),
		i(0),
	}),

	s("heat", {
		t("sns.heatmap("),
		i(1, "df.corr()"),
		t(", annot="),
		i(2, "True"),
		t(", cmap='"),
		i(3, "coolwarm"),
		t("')"),
		i(0),
	}),

	s("pair", {
		t("sns.pairplot("),
		i(1, "df"),
		t(', hue="'),
		i(2, "target"),
		t('")'),
		i(0),
	}),

	s("dist", {
		t("sns.histplot(data="),
		i(1, "df"),
		t(', x="'),
		i(2, "col"),
		t('", kde='),
		i(3, "True"),
		t(")"),
		i(0),
	}),

	s("cat", {
		t("sns.catplot(data="),
		i(1, "df"),
		t(', x="'),
		i(2, "col1"),
		t('", y="'),
		i(3, "col2"),
		t('", kind="'),
		i(4, "box"),
		t('")'),
		i(0),
	}),

	s("reg", {
		t("sns.regplot(data="),
		i(1, "df"),
		t(', x="'),
		i(2, "col1"),
		t('", y="'),
		i(3, "col2"),
		t('")'),
		i(0),
	}),
}
