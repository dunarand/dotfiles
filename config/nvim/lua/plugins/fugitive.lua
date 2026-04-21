return {
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "Ghdiffsplit", "Gvdiffsplit", "Ghdiffsplit" },
		keys = {
			{ "<leader>gd", ":Ghdiffsplit<CR>", desc = "Git diff split" },
			{ "<leader>gD", ":Gvdiffsplit<CR>", desc = "Git vertical diff" },
			{ "<leader>gh", ":Ghdiffsplit<CR>", desc = "Git diff against HEAD" },
		},
		config = function()
			vim.opt.diffopt:append("vertical")
			vim.opt.diffopt:append("iwhite")
			vim.opt.diffopt:append("algorithm:histogram")

			vim.keymap.set("n", "<leader>gn", "]c", { desc = "Next diff" })
			vim.keymap.set("n", "<leader>gp", "[c", { desc = "Prev diff" })
			vim.keymap.set("n", "<leader>gq", ":diffoff!<CR>", { desc = "Quit diff mode" })
		end,
	},
}
