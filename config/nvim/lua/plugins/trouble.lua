return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		follow = true,
		auto_open = false,
		auto_jump = false,
		focus = true,
		use_diagnostic_signs = true,
		indent_lines = true,
		padding = true,
		auto_preview = false,
	},
	cmd = "Trouble",
	keys = {
		{
			"<leader>qw",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Trouble: Workspace diagnostics",
		},
		{
			"<leader>qd",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Trouble: Buffer diagnostics",
		},
		{
			"<leader>ql",
			"<cmd>Trouble loclist toggle<cr>",
			desc = "Trouble: Location List",
		},
		{
			"<leader>qq",
			"<cmd>Trouble quickfix toggle<cr>",
			desc = "Trouble: Quickfix List",
		},
	},
}
