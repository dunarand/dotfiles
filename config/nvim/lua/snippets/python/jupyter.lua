local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {

	s("md", {
		t({ "# %% [markdown]", "" }),
		t("# "),
		i(1, "Markdown"),
		i(0),
	}),

	s("cc", {
		t({ "# %%", "" }),
		i(1, "print('Code cell')"),
		i(0),
	}),

	s("code", {
		t("```"),
		i(1, "language"),
		t({ "", "# " }),
		i(2, "code"),
		t({ "", "# ```" }),
		i(0),
	}),

	s("bd", {
		t("**"),
		i(1, "bold"),
		t("**"),
		i(0),
	}),

	s("it", {
		t("*"),
		i(1, "italic"),
		t("*"),
		i(0),
	}),

	s("st", {
		t("~"),
		i(1, "strike"),
		t("~"),
		i(0),
	}),

	s("h1", {
		t({ "# %% [markdown]", "" }),
		t("# # "),
		i(1, "H1 Header"),
		i(0),
	}),

	s("h2", {
		t({ "# %% [markdown]", "" }),
		t("# ## "),
		i(1, "H2 Header"),
		i(0),
	}),

	s("h3", {
		t({ "# %% [markdown]", "" }),
		t("# ### "),
		i(1, "H3 Header"),
		i(0),
	}),

	s("h4", {
		t({ "# %% [markdown]", "" }),
		t("# #### "),
		i(1, "H4 Header"),
		i(0),
	}),

	s("h5", {
		t("##### "),
		i(1, "H5 Header"),
		i(0),
	}),

	s("id", {
		t('<a name="'),
		i(1, "id"),
		i(0),
		t('"></a>'),
	}),

	s("img", {
		t('<center><div><img src="./resources/'),
		i(1, "img_name"),
		i(0),
		t('" width="500"/></div></center>'),
	}),

	s("defn", {
		t({ '<div class="alert alert-block alert-info">', "#     " }),
		i(1, "Definition: "),
		i(0),
		t({ "", "# </div>" }),
	}),

	s("formula", {
		t({ '<div class="alert alert-block alert-warning">', "# $$", "#     " }),
		i(1, "Formula: "),
		i(0),
		t({ "", "# $$", "# </div>" }),
	}),
}
