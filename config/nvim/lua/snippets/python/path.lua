local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {

	s("exists", {
		t("Path("),
		i(1, "path"),
		t(").exists()"),
		i(0),
	}),

	s("file", {
		t("is_file()"),
		i(0),
	}),

	s("dir", {
		t("is_dir()"),
		i(0),
	}),

	s("mkdir", {
		t("mkdir(parents="),
		i(1, "True"),
		t(", exist_ok="),
		i(2, "True"),
		t(")"),
		i(0),
	}),

	s("cwd", {
		i(1, "cwd"),
		t(" = Path.cwd()"),
		i(0),
	}),

	s("home", {
		i(1, "home"),
		t(" = Path.home()"),
		i(0),
	}),
}
