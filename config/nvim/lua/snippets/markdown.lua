local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function copy(index)
	return f(function(args)
		return args[1][1]
	end, { index })
end

return {

	s("c", {
		t("```"),
		i(1, "language"),
		t({ "", "" }),
		i(2, "code"),
		t({ "", "```" }),
		i(0),
	}),

	s("py", {
		t({ "```python", "" }),
		i(1, "print()"),
		t({ "", "```" }),
		i(0),
	}),

	s("bash", {
		t({ "```bash", "" }),
		i(1, "mkdir"),
		t({ "", "```" }),
		i(0),
	}),

	s("b", {
		t("**"),
		i(1, "bold text"),
		t("**"),
		i(0),
	}),

	s("i", {
		t("*"),
		i(1, "italic text"),
		t("*"),
		i(0),
	}),

	s("s", {
		t("~"),
		i(1, "strikethrough"),
		t("~"),
		i(0),
	}),

	s("img", {
		t("!["),
		i(1, "alt text"),
		t("]("),
		i(2, "img_path.png"),
		t(")"),
		i(0),
	}),

	s("l", {
		t("["),
		i(1, "text"),
		t("]("),
		i(2, "url"),
		t(")"),
		i(0),
	}),

	s("h1", {
		t("# "),
		i(1, "Header1"),
		t({ "", "", "" }),
		i(2, ""),
		i(0),
	}),

	s("h2", {
		t("## "),
		i(1, "Header2"),
		t({ "", "", "" }),
		i(2, ""),
		i(0),
	}),

	s("h3", {
		t("### "),
		i(1, "Header3"),
		t({ "", "", "" }),
		i(2, ""),
		i(0),
	}),
}
