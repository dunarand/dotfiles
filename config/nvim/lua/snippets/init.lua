local ls = require("luasnip")
local python_snippets = {}

local function merge_snippets(...)
	local result = {}
	for _, tbl in ipairs({ ... }) do
		for _, snippet in ipairs(tbl) do
			table.insert(result, snippet)
		end
	end
	return result
end

local core = require("snippets.python.core")
local imports = require("snippets.python.imports")
local sklearn = require("snippets.python.sklearn")
local pandas = require("snippets.python.pandas")
local plotting = require("snippets.python.plotting")
local jupyter = require("snippets.python.jupyter")

python_snippets = merge_snippets(core, imports, sklearn, pandas, plotting, jupyter)

local markdown = require("snippets.markdown")

ls.add_snippets("python", python_snippets)
ls.add_snippets("markdown", markdown)
