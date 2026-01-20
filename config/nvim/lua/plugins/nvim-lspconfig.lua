return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				vim.keymap.set(
					"n",
					";",
					vim.lsp.buf.hover,
					{ buffer = 0, desc = "Show documentation in hover window." }
				)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0, desc = "Jump to definition." })
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = 0, desc = "Jump to declaration." })
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = 0, desc = "Jump to implementation." })
				vim.keymap.set(
					"n",
					"go",
					vim.lsp.buf.type_definition,
					{ buffer = 0, desc = "Jump to type definition." }
				)
				vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, { buffer = 0, desc = "Jump to signature help." })
				vim.keymap.set(
					"n",
					"<leader>rn",
					vim.lsp.buf.rename,
					{ buffer = 0, desc = "Rename symbol under cursor." }
				)
				vim.keymap.set(
					"n",
					"gr",
					require("telescope.builtin").lsp_references,
					{ buffer = 0, desc = "Show references in a Telescope window." }
				)

				-- Diagnostics
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = 0, desc = "Jump to next diagnostic." })
				vim.keymap.set(
					"n",
					"[d",
					vim.diagnostic.goto_prev,
					{ buffer = 0, desc = "Jump to previous diagnostic." }
				)
				vim.keymap.set(
					"n",
					"gl",
					vim.diagnostic.open_float,
					{ buffer = 0, desc = "Show diagnostic information in hover." }
				)

				-- Code actions
				if vim.lsp.buf.range_code_action then
					vim.keymap.set(
						"x",
						"<leader>la",
						vim.lsp.buf.range_code_action,
						{ buffer = 0, desc = "Range code action." }
					)
				else
					vim.keymap.set("x", "<leader>la", vim.lsp.buf.code_action, { buffer = 0, desc = "Code action." })
				end
			end,
		})

		-- ==================== ACTIVE LSPs ====================

		-- Lua LSP
		vim.lsp.config.lua_ls = {
			cmd = { "lua-language-server" },
			filetypes = { "lua" },
			root_markers = {
				".luarc.json",
				".luarc.jsonc",
				".luacheckrc",
				".stylua.toml",
				"stylua.toml",
				".git",
			},
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim", "Snacks" },
					},
					workspace = {},
				},
			},
		}

		-- Python LSP (Pyright for type checking)
		vim.lsp.config.pyright = {
			cmd = { "pyright-langserver", "--stdio" },
			filetypes = { "python" },
			root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
			capabilities = capabilities,
			settings = {
				pyright = {
					disableOrganizeImports = true,
				},
				python = {
					analysis = {
						typeCheckingMode = "basic",
						diagnosticMode = "workspace",
						reportUnusedImport = "none",
						reportDuplicateImport = "none",
					},
				},
			},
		}

		-- Ruff LSP (formatting only)
		vim.lsp.config.ruff = {
			cmd = { "ruff", "server" },
			filetypes = { "python" },
			root_markers = { "pyproject.toml", "ruff.toml", ".git" },
			capabilities = capabilities,
			init_options = {
				settings = {
					lint = {
						enable = true,
						select = { "F", "E", "W", "I", "N", "UP", "B", "SIM" },
					},
					format = {
						enable = false,
					},
					lineLength = 80,
				},
			},
		}

		-- SQL LSP
		vim.lsp.config.sqlls = {
			cmd = { "sql-language-server", "up", "--method", "stdio" },
			filetypes = { "sql", "mysql" },
			root_markers = { ".git" },
			capabilities = capabilities,
		}

		-- CSS LSP
		vim.lsp.config.cssls = {
			cmd = { "vscode-css-language-server", "--stdio" },
			filetypes = { "css", "scss", "less" },
			root_markers = { "package.json", ".git" },
			capabilities = capabilities,
		}

		-- HTML LSP
		vim.lsp.config.html = {
			cmd = { "vscode-html-language-server", "--stdio" },
			filetypes = { "html" },
			root_markers = { "package.json", ".git" },
			capabilities = capabilities,
		}

		-- JSON LSP
		vim.lsp.config.jsonls = {
			cmd = { "vscode-json-language-server", "--stdio" },
			filetypes = { "json", "jsonc" },
			root_markers = { ".git" },
			capabilities = capabilities,
		}

		-- TOML LSP
		vim.lsp.config.taplo = {
			cmd = { "taplo", "lsp", "stdio" },
			filetypes = { "toml" },
			root_markers = { ".git" },
			capabilities = capabilities,
		}

		-- YAML LSP
		vim.lsp.config.yamlls = {
			cmd = { "yaml-language-server", "--stdio" },
			filetypes = { "yaml", "yaml.docker-compose" },
			root_markers = { ".git" },
			capabilities = capabilities,
			settings = {
				yaml = {
					schemas = {
						kubernetes = "/*.yaml",
					},
				},
			},
		}

		-- Markdown LSP
		vim.lsp.config.markdown_oxide = {
			cmd = { "markdown-oxide" },
			filetypes = { "markdown", "markdown.mdx" },
			root_markers = { ".git" },
			capabilities = capabilities,
			settings = {},
		}

		-- LaTeX LSP
		vim.lsp.config.texlab = {
			cmd = { "texlab" },
			filetypes = { "tex", "plaintex", "bib" },
			root_markers = { ".latexmkrc", ".git" },
			capabilities = capabilities,
			settings = {
				texlab = {
					build = {
						executable = "latexmk",
						args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
						onSave = false, -- Set to true if you want auto-build on save
						forwardSearchAfter = false,
					},
					auxDirectory = ".",
					forwardSearch = {
						executable = nil, -- Set your PDF viewer here (e.g., "zathura", "okular")
						args = {},
					},
					chktex = {
						onOpenAndSave = false, -- Disable chktex linting
						onEdit = false,
					},
					diagnosticsDelay = 300,
					latexFormatter = "latexindent",
					latexindent = {
						modifyLineBreaks = false,
					},
				},
			},
		}

		-- LTeX LSP (Grammar & Spell Checking for Markdown and LaTeX)
		vim.lsp.config.ltex = {
			cmd = { "ltex-ls" },
			filetypes = { "markdown", "tex", "plaintex" },
			root_markers = { ".git" },
			capabilities = capabilities,
			settings = {
				ltex = {
					language = "en-US",
					diagnosticSeverity = "information",
					checkFrequency = "save", -- Options: "edit", "save"
					enabled = true,
					dictionary = {
						["en-US"] = {},
					},
					disabledRules = {
						["en-US"] = {},
					},
					additionalRules = {
						enablePickyRules = false,
						motherTongue = "",
					},
				},
			},
		}

		vim.lsp.enable("lua_ls")
		vim.lsp.enable("pyright")
		vim.lsp.enable("ruff")
		vim.lsp.enable("sqlls")
		vim.lsp.enable("cssls")
		vim.lsp.enable("html")
		vim.lsp.enable("jsonls")
		vim.lsp.enable("taplo")
		vim.lsp.enable("yamlls")
		vim.lsp.enable("markdown_oxide")
		vim.lsp.enable("texlab")
		vim.lsp.enable("ltex")
	end,
}
