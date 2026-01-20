return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls", -- Lua
				"pyright", -- Python
				"sqlls", -- SQL
				"cssls", -- CSS
				"html", -- HTML
				"jsonls", -- JSON
				"taplo", -- TOML
				"yamlls", -- YAML
				"markdown_oxide", -- Markdown
				"texlab", -- LaTeX
				"ltex", -- Grammar/spell checking (Markdown & LaTeX)
			},
			automatic_installation = true,
		})

		local mason_registry = require("mason-registry")
		local formatters = {
			"stylua", -- Lua
			"ruff", -- Python
			"sql-formatter", -- SQL
			"prettier", -- JS/TS/CSS/HTML/JSON/YAML/Markdown
			"latexindent", -- LaTeX
		}

		for _, formatter in ipairs(formatters) do
			if not mason_registry.is_installed(formatter) then
				vim.cmd("MasonInstall " .. formatter)
			end
		end
	end,
}
