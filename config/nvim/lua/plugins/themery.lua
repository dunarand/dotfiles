return {
	"zaldih/themery.nvim",
	dependencies = {
		"catppuccin/nvim",
		"olimorris/onedarkpro.nvim",
		"navarasu/onedark.nvim",
		"rose-pine/neovim",
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
				{
					name = "onedarkpro-vaporwave",
					colorscheme = "onedark_vivid",
					before = [[
                        vim.opt.background = "dark"
                        require('onedarkpro').setup({
                            options = {
                                transparency = false,
                            }
                        })
                    ]],
				},
				{
					name = "onedarkpro-dark",
					colorscheme = "onedark_dark",
					before = [[
                        vim.opt.background = 'dark'
                    ]],
				},
				{
					name = "onedark-darker",
					colorscheme = "onedark",
					before = [[
                        vim.opt.background = 'dark'
                        require('onedark').setup({
                            style = 'darker'
                        })
                        require('onedark').load()
                    ]],
				},
				{
					name = "onedark-deep",
					colorscheme = "onedark",
					before = [[
                        vim.opt.background = 'dark'
                        require('onedark').setup({
                            style = 'deep'
                        })
                        require('onedark').load()
                    ]],
				},
				{
					name = "rose-pine",
					colorscheme = "rose-pine",
					before = [[
                        vim.opt.background = 'dark'
                        require('rose-pine').setup({
                            variant = "main"
                        })
                    ]],
				},
				{
					name = "rose-pine-dawn",
					colorscheme = "rose-pine-dawn",
					before = [[
                        vim.opt.background = 'light'
                        require('rose-pine').setup({
                            variant = "dawn"
                        })
                    ]],
				},
			},
			livePreview = true,
		})
		vim.keymap.set("n", "<leader>cs", "<cmd>Themery<CR>", { desc = "Open Themery theme picker" })
	end,
}
