return {
	description = "Python package with virtualenv setup",
	dirs = {
		"src/{{PROJECT_NAME}}",
		"src/{{PROJECT_NAME}}/core",
		"src/{{PROJECT_NAME}}/logging",
		"src/{{PROJECT_NAME}}/config",
		"src/{{PROJECT_NAME}}/cli",
		"tests",
		"docs",
	},
	files = {
		["README.md"] = "# {{PROJECT_NAME}}",
		["LICENSE"] = "",
		["src/{{PROJECT_NAME}}/__init__.py"] = "",
		["src/{{PROJECT_NAME}}/__main__.py"] = "",
		["src/{{PROJECT_NAME}}/core/__init__.py"] = "",
		["src/{{PROJECT_NAME}}/core/__main__.py"] = "",
		["src/{{PROJECT_NAME}}/logging/__init__.py"] = "",
		["src/{{PROJECT_NAME}}/logging/__main__.py"] = "",
		["src/{{PROJECT_NAME}}/config/__init__.py"] = "",
		["src/{{PROJECT_NAME}}/config/__main__.py"] = "",
		["src/{{PROJECT_NAME}}/cli/__init__.py"] = "",
		["src/{{PROJECT_NAME}}/cli/__main__.py"] = "",
		["setup.py"] = [[
from setuptools import setup, find_packages

setup(
    name="{{PROJECT_NAME}}",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
)
]],
		[".gitignore"] = [[
__pycache__/
.venv/
build/
dist/
*.egg_info
*.pyc
]],
		["requirements.txt"] = "",
	},
}
