local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {

	s("tts", {
		t("X_train, X_test, y_train, y_test = train_test_split(X, y"),
		t(", test_size = "),
		i(1, "0.20"),
		t(")"),
		i(0),
	}),

	s("fit", {
		t("fit("),
		i(1, "X_train"),
		t(", "),
		i(2, "y_train"),
		t(")"),
		i(0),
	}),

	s("pred", {
		t("predict("),
		i(1, "X_test"),
		t(")"),
		i(0),
	}),

	s("acc", {
		t("accuracy_score("),
		i(1, "y_true"),
		t(", "),
		i(2, "y_pred"),
		t(")"),
		i(0),
	}),

	s("pre", {
		t("precision_score("),
		i(1, "y_true"),
		t(", "),
		i(2, "y_pred"),
		t(")"),
		i(0),
	}),

	s("rec", {
		t("recall_score("),
		i(1, "y_true"),
		t(", "),
		i(2, "y_pred"),
		t(")"),
		i(0),
	}),

	s("f1", {
		t("f1_score("),
		i(1, "y_true"),
		t(", "),
		i(2, "y_pred"),
		t(")"),
		i(0),
	}),

	s("mse", {
		t("mean_squared_error("),
		i(1, "y_true"),
		t(", "),
		i(2, "y_pred"),
		t(")"),
		i(0),
	}),

	s("mae", {
		t("mean_absolute_error("),
		i(1, "y_true"),
		t(", "),
		i(2, "y_pred"),
		t(")"),
		i(0),
	}),

	s("r2", {
		t("r2_score("),
		i(1, "y_true"),
		t(", "),
		i(2, "y_pred"),
		t(")"),
		i(0),
	}),

	s("dt", {
		i(1, "dt"),
		t(" = DecisionTreeClassifier("),
		i(2, "args"),
		t(")"),
		i(0),
	}),

	s("rf", {
		i(1, "rf"),
		t(" = RandomForestClassifier("),
		i(2, "args"),
		t(")"),
		i(0),
	}),

	s("lr", {
		i(1, "lr"),
		t(" = LinearRegression("),
		i(2, "args"),
		t(")"),
		i(0),
	}),

	s("log", {
		i(1, "lr"),
		t(" = LogisticRegression("),
		i(2, "args"),
		t(")"),
		i(0),
	}),

	s("knn", {
		i(1, "knn"),
		t(" = KNeighborsClassifier("),
		i(2, "args"),
		t(")"),
		i(0),
	}),
}
