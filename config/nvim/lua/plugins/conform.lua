return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				-- Active formatters
				lua = { "stylua" },
				python = { "ruff_organize_imports", "ruff_format", "ruff_autofix" },
				sql = { "sql_formatter" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				toml = { "taplo" },
				sh = { "shfmt" },
				bash = { "shfmt" },
			},
			formatters = {
				ruff_organize_imports = {
					command = "ruff",
					args = {
						"check",
						"--select",
						"I",
						"--fix",
						"--line-length",
						"80",
						"--stdin-filename",
						"$FILENAME",
						"-",
					},
				},
				ruff_format = {
					command = "ruff",
					args = {
						"format",
						"--line-length",
						"80",
						"--stdin-filename",
						"$FILENAME",
						"-",
					},
				},
				ruff_autofix = {
					command = "ruff",
					args = {
						"check",
						"--select",
						"F,E4,E7,E9,W,UP,B,SIM",
						"--fix",
						"--line-length",
						"80",
						"--stdin-filename",
						"$FILENAME",
						"-",
					},
				},
				sql_formatter = {
					command = "sql-formatter",
					args = { "--language", "sql" },
				},
				shfmt = {
					prepend_args = { "-i", "2", "-bn", "-ci", "-sr" },
				},
				prettier = {
					prepend_args = {
						"--tab-width",
						"2",
						"--use-tabs",
						"false",
						"--single-quote",
						"false",
						"--trailing-comma",
						"es5",
						"--print-width",
						"80",
					},
				},
				taplo = {
					args = {
						"format",
						"--option",
						"indent_string=  ",
						"--option",
						"column_width=80",
						"-",
					},
				},
			},
		})
		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			require("conform").format({
				lsp_fallback = true,
				async = true,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range" })
	end,
}
