return {
	description = "Data Science project with Jupyter Notebooks",
	dirs = {
		"assets",
		"data",
		"data/raw",
		"data/modified",
		"html",
		"models",
		"notebooks",
		"scripts",
	},
	files = {
		[".gitignore"] = [[
.venv/
__pycache/
.ipynb_checkpoints/
notebooks/.ipynb_checkpoints/
]],
		["LICENSE"] = "",
		["requirements.txt"] = [[
numpy
pandas
matplotlib
seaborn
scikit-learn
scipy
notebook
jupytext
]],
		["README.md"] = [[
# {{PROJECT_NAME}}

# Installation

You can clone the repository and work on your local machine.

## Requirements

- Python version >= 3.11.9 (older versions not tested)
- Python packages in `requirements.txt` (older versions not tested)

## Installation Steps

You can clone the repository to explore the notebooks on your own.

```bash
git clone https://github.com/dunarand/Kaggle-Titanic-Competition
cd Kaggle-Titanic-Competition
```

Then, create a Python virtual environment.

```bash
python3 -m venv ./.venv
```

Activate the Python environment. On Windows, run the following command in
PowerShell

```PowerShell
.\.venv\Scripts\Activate.ps1
```

*(If you encounter execution errors, try running
`Set-ExecutionPolicy RemoteSigned -Scope Process` first.)*

On Linux/macOS, run

```bash
source .venv/bin/activate
```

Then, install the required packages:

```bash
pip3 install -r requirements.txt
```

**Note:** This repository was created using
[neovim](https://github.com/neovim/neovim) for a better editing experience, and
[jupytext](https://github.com/mwouts/jupytext) for a better version control
system. If you plan to work with the same tools, I highly suggest the
[jupytext.nvim plugin](https://github.com/GCBallesteros/jupytext.nvim).
If you want to work on the `ipynb` Jupyter Notebooks with your choice of IDE or
text editor, you will not need the `jupytext` installation in
`requirements.txt`, so you can remove the respective line.


Next, launch a local Jupyter server:

```bash
jupyter notebook
```

You can now work with the notebooks on your local machine.
]],
		["notebooks/{{PROJECT_NAME}}.py"] = [[
# %% [markdown]
# # {{PROJECT_NAME}}
]],
		["notebooks/{{PROJECT_NAME}}.ipynb"] = "",
		["notebooks/1 - Understanding & Planning.py"] = [[
# %% [markdown]
# # 1 - Understanding & Planning
]],
		["notebooks/1 - Understanding & Planning.ipynb"] = "",
		["notebooks/2 - Data Wrangling.py"] = [[
# %% [markdown]
# # 2 - Data Wrangling
]],
		["notebooks/2 - Data Wrangling.ipynb"] = "",
		["notebooks/3 - Exploratory Data Analysis.py"] = [[
# %% [markdown]
# # 3 - Exploratory Data Analysis
]],
		["notebooks/3 - Exploratory Data Analysis.ipynb"] = "",
		["notebooks/4 - Model Building.py"] = [[
# %% [markdown]
# # 4 - Model Building
]],
		["notebooks/4 - Model Building.ipynb"] = "",
		["notebooks/5 - Model Evaluation & Results.py"] = [[
# %% [markdown]
# # 5 - Model Evaluation & Results
]],
		["notebooks/5 - Model Evaluation & Results.ipynb"] = "",
	},
}
