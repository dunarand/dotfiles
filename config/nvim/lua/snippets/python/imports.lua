local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {

	s("os", {
		t({ "import os", "" }),
		i(0),
	}),

	s("path", {
		t({ "from pathlib import Path", "" }),
		i(0),
	}),

    s("np", {
        t({ "import numpy as np", "" }),
        i(0),
    }),

    s("pd", {
        t({ "import pandas as pd", "" }),
        i(0),
    }),

	s("plt", {
		t({ "import matplotlib.pyplot as plt", "" }),
		i(0),
	}),

	s("sns", {
		t({ "import seaborn as sns", "" }),
		i(0),
	}),

	s("stats", {
		t({ "from scipy import stats", "" }),
		i(0),
	}),

	s("px", {
		t({ "import plotly.express as px", "" }),
		i(0),
	}),

	s("go", {
		t({ "import plotly.graph_objects as go", "" }),
		i(0),
	}),

	s("sm", {
		t({ "import statsmodels.api as sm", "" }),
		i(0),
	}),

	s("sk", {
		t("from sklearn."),
		i(1, "module"),
		t(" import "),
		i(2, "func"),
		i(0),
	}),

	s("idt", {
		t({ "from sklearn.tree import DecisionTreeClassifier", "" }),
		i(0),
	}),

	s("irf", {
		t({ "from sklearn.ensemble import RandomForestClassifier", "" }),
		i(0),
	}),

	s("igb", {
		t({ "from sklearn.ensemble import GradientBoostingClassifier", "" }),
		i(0),
	}),

	s("ilr", {
		t({ "from sklearn.linear_model import LinearRegression", "" }),
		i(0),
	}),

	s("ilog", {
		t({ "from sklearn.linear_model import LogisticRegression", "" }),
		i(0),
	}),

	s("iknn", {
		t({ "from sklearn.neighbors import KNeighborsClassifier", "" }),
		i(0),
	}),

	s("ispl", {
		t({ "from sklearn.model_selection import train_test_split", "" }),
		i(0),
	}),

	s("imt", {
		t({ "from sklearn.metrics import (", "" }),
		t({ "    accuracy_score, recall_score, precision_score,", "" }),
		t({ "    f1_score, roc_auc_score, confusion_matrix,", "" }),
		t({ "    mean_squared_error, mean_absolute_error,", "" }),
		t({ "    r2_score", ")", "" }),
		i(0),
	}),

	s("iscl", {
		t({ "from sklearn.preprocessing import StandardScaler", "" }),
		i(0),
	}),

	s("imin", {
		t({ "from sklearn.preprocessing import MinMaxScaler", "" }),
		i(0),
	}),

	s("iohe", {
		t({ "from sklearn.preprocessing import OneHotEncoder", "" }),
		i(0),
	}),

	s("ile", {
		t({ "from sklearn.preprocessing import LabelEncoder", "" }),
		i(0),
	}),
}
