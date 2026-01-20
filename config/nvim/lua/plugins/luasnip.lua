return {
	"L3MON4D3/LuaSnip",
	config = function()
		local luasnip = require("luasnip")

		luasnip.config.set_config({
			history = true,
			updateevents = "TextChanged,TextChangedI",
			enable_autosnippets = true,
			ext_opts = {
				[require("luasnip.util.types").choiceNode] = {
					active = {
						virt_text = { { "◆", "GruvboxOrange" } },
					},
				},
			},
		})

		local custom_lua_snippet_path = vim.fn.stdpath("config") .. "/lua/snippets"
		require("luasnip.loaders.from_lua").load({
			paths = custom_lua_snippet_path,
		})

		vim.keymap.set({ "i", "s" }, "<C-f>", function()
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			end
		end, { silent = true, desc = "Expand or jump forward in snippet" })

		vim.keymap.set({ "i", "s" }, "<C-b>", function()
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			end
		end, { silent = true, desc = "Jump backward in snippet" })

		vim.keymap.set({ "i", "s" }, "<C-x>", function()
			if luasnip.choice_active() then
				luasnip.change_choice(1)
			end
		end, { silent = true, desc = "Cycle through snippet choices" })
	end,
}
