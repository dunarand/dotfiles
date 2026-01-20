return {
	"ray-x/lsp_signature.nvim",
	event = "LspAttach",
	config = function()
		local hint = false
		local float = true
		require("lsp_signature").setup({
			bind = true,
			handler_opts = {
				border = "rounded",
			},
			floating_window = float,
			floating_window_above_cur_line = true,
			floating_window_off_x = 0,
			floating_window_off_y = 0,
			hint_enable = hint,
			hint_prefix = {
				above = "↙ ",
				current = "← ",
				below = "↖ ",
			},
			hint_scheme = "comment",
			hi_parameter = "lspsignatureactiveparameter",
			always_trigger = true,
			auto_close_after = 10,
			extra_trigger_chars = { "(", "," },
			timer_interval = 200,
			max_height = 8,
			max_width = 50,
			wrap = true,
			fix_pos = false,
		})
		vim.keymap.set({ "n", "i" }, "<C-e>", function()
			hint = not hint
			float = not float
			require("lsp_signature").setup({
				hint_enable = hint,
				floating_window = float,
			})
		end, { desc = "lsp: toggle signature hint/floating window" })
	end,
}
