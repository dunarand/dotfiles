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

		-- ==================== LSP CONFIGURATIONS ====================
		local servers = {
			lua_ls = {
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
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim", "Snacks" },
						},
						workspace = {},
					},
				},
			},

			pyright = {
				cmd = { "pyright-langserver", "--stdio" },
				filetypes = { "python" },
				root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
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
			},

			ruff = {
				cmd = { "ruff", "server" },
				filetypes = { "python" },
				root_markers = { "pyproject.toml", "ruff.toml", ".git" },
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
			},

			bashls = {
				cmd = { "bash-language-server", "start" },
				filetypes = { "sh", "bash" },
				root_markers = { ".git" },
				settings = {
					bashIde = {
						globPattern = "*@(.sh|.inc|.bash|.command)",
					},
				},
			},

			sqlls = {
				cmd = { "sql-language-server", "up", "--method", "stdio" },
				filetypes = { "sql", "mysql" },
				root_markers = { ".git" },
			},

			cssls = {
				cmd = { "vscode-css-language-server", "--stdio" },
				filetypes = { "css", "scss", "less" },
				root_markers = { "package.json", ".git" },
			},

			html = {
				cmd = { "vscode-html-language-server", "--stdio" },
				filetypes = { "html" },
				root_markers = { "package.json", ".git" },
			},

			jsonls = {
				cmd = { "vscode-json-language-server", "--stdio" },
				filetypes = { "json", "jsonc" },
				root_markers = { ".git" },
			},

			taplo = {
				cmd = { "taplo", "lsp", "stdio" },
				filetypes = { "toml" },
				root_markers = { ".git" },
			},

			yamlls = {
				cmd = { "yaml-language-server", "--stdio" },
				filetypes = { "yaml", "yaml.docker-compose" },
				root_markers = { ".git" },
				settings = {
					yaml = {
						schemas = {
							kubernetes = "/*.yaml",
						},
					},
				},
			},

			markdown_oxide = {
				cmd = { "markdown-oxide" },
				filetypes = { "markdown", "markdown.mdx" },
				root_markers = { ".git" },
			},

			texlab = {
				cmd = { "texlab" },
				filetypes = { "tex", "plaintex", "bib" },
				root_markers = { ".latexmkrc", ".git" },
				settings = {
					texlab = {
						build = {
							executable = "latexmk",
							args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
							onSave = false,
							forwardSearchAfter = false,
						},
						auxDirectory = ".",
						forwardSearch = {
							executable = nil,
							args = {},
						},
						chktex = {
							onOpenAndSave = false,
							onEdit = false,
						},
						diagnosticsDelay = 300,
						latexFormatter = "latexindent",
						latexindent = {
							modifyLineBreaks = false,
						},
					},
				},
			},

			ltex = {
				cmd = { "ltex-ls" },
				filetypes = { "markdown", "tex", "plaintex" },
				root_markers = { ".git" },
				settings = {
					ltex = {
						language = "en-US",
						diagnosticSeverity = "information",
						checkFrequency = "save",
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
			},
		}

		for server, config in pairs(servers) do
			config.capabilities = capabilities
			vim.lsp.config[server] = config
			vim.lsp.enable(server)
		end
	end,
}
