return {
	"akinsho/toggleterm.nvim",
	version = "*",
	event = "VeryLazy",
	config = function()
		local sysname = vim.loop.os_uname().sysname
		local default_shell

		if sysname == "Windows_NT" then
			default_shell = "pwsh"
		else
			default_shell = vim.o.shell
		end

		require("toggleterm").setup({
			-- Size of the terminal
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,

			-- Open mapping (set to false if you want custom keymaps only)
			open_mapping = [[<C-\>]],

			hide_numbers = true,
			shade_terminals = true,
			shading_factor = 2, -- 1-3, higher = darker
			start_in_insert = true,
			close_on_exit = true,
			shell = default_shell,
			auto_scroll = true,
			direction = "horizontal",
			winbar = {
				enabled = false,
				name_formatter = function(term)
					return term.name
				end,
			},
			on_create = function(term)
				vim.wo[term.window].winfixheight = true
			end,
		})

		function _G.set_terminal_keymaps()
			local opts = { buffer = 0 }
			vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
			vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
			vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
			vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
			vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
			vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			vim.keymap.set("t", "<C-w>", [[<C-\><C-n><Cmd>close<CR>]], opts)
		end

		vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

		local Terminal = require("toggleterm.terminal").Terminal

		vim.keymap.set(
			"n",
			"<leader>`h",
			"<Cmd>ToggleTerm direction=horizontal<CR>",
			{ desc = "Toggle horizontal terminal" }
		)

		vim.keymap.set(
			"n",
			"<leader>`v",
			"<Cmd>ToggleTerm direction=vertical<CR>",
			{ desc = "Toggle vertical terminal" }
		)

		vim.keymap.set("n", "<leader>`t", "<Cmd>ToggleTerm direction=tab<CR>", { desc = "Toggle tab terminal" })
		vim.keymap.set("n", "<leader>`a", "<Cmd>ToggleTermToggleAll<CR>", { desc = "Toggle all terminals" })
		vim.keymap.set("n", "<leader>`T", function()
			vim.cmd("Trouble diagnostics toggle focus=false win.position=bottom")
			vim.defer_fn(function()
				local trouble_win = vim.api.nvim_get_current_win()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					local ft = vim.api.nvim_buf_get_option(buf, "filetype")
					if ft == "trouble" then
						vim.api.nvim_set_current_win(win)
						break
					end
				end
				vim.cmd("vsplit")
				vim.cmd("terminal")
				vim.cmd("startinsert")
				vim.cmd("wincmd =")
			end, 100)
		end, { desc = "Toggle terminal + Trouble side-by-side" })

		local lazygit = Terminal:new({
			cmd = "lazygit",
			dir = "git_dir",
			direction = "tab",
			on_open = function(term)
				vim.cmd("startinsert!")
				vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
			end,
		})

		function _LAZYGIT_TOGGLE()
			lazygit:toggle()
		end

		vim.keymap.set("n", "<leader>`g", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", { desc = "Toggle Lazygit" })

		local python = Terminal:new({
			cmd = "python3",
			direction = "horizontal",
			close_on_exit = false,
		})

		function _PYTHON_TOGGLE()
			python:toggle()
		end

		vim.keymap.set("n", "<leader>`p", "<cmd>lua _PYTHON_TOGGLE()<CR>", { desc = "Toggle Python REPL" })

		local bottom = Terminal:new({
			cmd = "btm",
			direction = "tab",
		})

		function _BOTTOM_TOGGLE()
			bottom:toggle()
		end

		vim.keymap.set("n", "<leader>`b", "<cmd>lua _BOTTOM_TOGGLE()<CR>", { desc = "Toggle Bottom" })

		function _G.send_line_to_terminal()
			local line = vim.api.nvim_get_current_line()
			require("toggleterm").exec(line, 1)
		end

		function _G.send_selection_to_terminal()
			local start_line = vim.fn.line("'<")
			local end_line = vim.fn.line("'>")
			local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
			local text = table.concat(lines, "\n")
			require("toggleterm").exec(text, 1)
		end

		vim.keymap.set("n", "<leader>`s", "<cmd>lua send_line_to_terminal()<CR>", { desc = "Send line to terminal" })
		vim.keymap.set(
			"v",
			"<leader>`s",
			"<cmd>lua send_selection_to_terminal()<CR>",
			{ desc = "Send selection to terminal" }
		)
	end,
}
