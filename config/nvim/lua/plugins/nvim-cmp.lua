return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lsp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		luasnip.config.set_config({
			history = true,
			update_events = "TextChanged,TextChangedI",
		})
		cmp.setup({
			completion = {
				keyword_length = 2,
				keyword_pattern = [[\k\+]],
			},
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-Tab>"] = cmp.mapping.complete({ desc = "CMP: Trigger completion" }),
				["<C-e>"] = cmp.mapping.abort({ desc = "CMP: Abort completion" }),
				["<Esc>"] = cmp.mapping.close({ desc = "CMP: Close completion menu" }),
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
					desc = "CMP: Confirm completion",
				}),

				-- Close auto-cmp window on insert mode navigation with arrow keys
				["<Up>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.close()
					end
					fallback()
				end, { "i" }),
				["<Down>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.close()
					end
					fallback()
				end, { "i" }),
				["<Left>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.close()
					end
					fallback()
				end, { "i" }),
				["<Right>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.close()
					end
					fallback()
				end, { "i" }),

				-- Completion navigation
				["<C-n>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					else
						fallback()
					end
				end, { "i", "s" }, { desc = "CMP: Next item" }),
				["<C-p>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					else
						fallback()
					end
				end, { "i", "s" }, { desc = "CMP: Previous item" }),
				["<C-h>"] = cmp.mapping(function()
					if cmp.visible() then
						cmp.close()
					elseif not cmp.visible() then
						cmp.complete()
					end
				end, { "i", "s" }, { desc = "CMP: Toggle completion window" }),
				["<C-l>"] = cmp.mapping(function()
					if cmp.visible_docs() then
						cmp.close_docs()
					else
						cmp.open_docs()
					end
				end, { "i", "s" }, { desc = "CMP: Toggle documentation" }),
				["<C-d>"] = cmp.mapping.scroll_docs(4, { desc = "CMP: Scroll docs down" }),
				["<C-u>"] = cmp.mapping.scroll_docs(-4, { desc = "CMP: Scroll docs up" }),

				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.locally_jumpable(1) then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { "i", "s" }, { desc = "Select next item or jump snippet" }),

				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }, { desc = "Select previous item or jump backward in snippet" }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
			}),

			formatting = {
				format = function(entry, vim_item)
					vim_item.menu = ({
						nvim_lsp = "[LSP]",
						luasnip = "[Snip]",
						buffer = "[Buf]",
						path = "[Path]",
					})[entry.source.name]
					return vim_item
				end,
			},
			window = {
				completion = cmp.config.window.bordered({
					max_height = 10,
					max_width = 60,
				}),
				documentation = cmp.config.window.bordered({
					max_height = 15,
					max_width = 70,
				}),
			},
			view = {
				docs = {
					auto_open = false,
				},
			},
		})
	end,
}
