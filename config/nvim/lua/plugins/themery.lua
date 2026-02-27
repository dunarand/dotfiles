return {
	"zaldih/themery.nvim",
	dependencies = {
		"catppuccin/nvim",
	},
	lazy = false,
	config = function()
		require("themery").setup({
			themes = {
				{
					name = "catppuccin-latte",
					colorscheme = "catppuccin-latte",
					before = [[
                        vim.opt.background = "light"
                    ]],
				},
				{
					name = "catppuccin-mocha",
					colorscheme = "catppuccin-mocha",
					before = [[
                        vim.opt.background = "dark"
                    ]],
				},
			},
			livePreview = true,
		})
		vim.keymap.set("n", "<leader>cs", "<cmd>Themery<CR>", { desc = "Open Themery theme picker" })
	end,
}
