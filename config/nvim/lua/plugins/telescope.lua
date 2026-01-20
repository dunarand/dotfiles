return {
	"nvim-telescope/telescope.nvim",
	tag = "v0.1.9",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				entry_prefix = "",
				prompt_prefix = " ",
				selection_caret = " ",
				file_sorter = require("telescope.sorters").get_fuzzy_file,
				generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				layout_config = {
					horizontal = {
						preview_width = 0.55,
						results_width = 0.8,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				file_ignore_patterns = {
					"node_modules",
					".git/",
					"dist/",
					"build/",
					"*.lock",
				},
			},
			pickers = {
				find_files = {
					hidden = true,
					previewer = false,
					find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
				},
				buffers = {
					show_all_buffers = true,
					sort_lastused = true,
					previewer = false,
					mappings = {
						i = {
							["<C-d>"] = actions.delete_buffer,
						},
						n = {
							["dd"] = actions.delete_buffer,
						},
					},
				},
			},
		})

		vim.keymap.set(
		    "n",
		    "<leader>tf",
		    builtin.find_files,
		    { desc = "Telescope find files" }
		)
		vim.keymap.set(
		    "n",
		    "<C-p>",
		    builtin.git_files,
		    { desc = "Telescope git files" }
		)
		vim.keymap.set(
		    "n",
		    "<leader>tb",
		    builtin.buffers,
		    { desc = "Telescope find buffers" }
		)
		vim.keymap.set(
		    "n",
		    "<leader>tg",
		    builtin.live_grep,
		    { desc = "Telescope live grep" }
		)
		vim.keymap.set(
		    "n",
		    "<leader>th",
		    builtin.help_tags,
		    { desc = "Telescope help tags" }
		)
		vim.keymap.set(
		    "n",
		    "<leader>td",
		    builtin.diagnostics,
		    { desc = "Telescope diagnostics" }
		)
		vim.keymap.set(
		    "n",
		    "<leader>tr",
		    builtin.oldfiles,
		    { desc = "Telescope recent files" }
		)
		vim.keymap.set(
		    "n",
		    "<leader>/",
		    builtin.current_buffer_fuzzy_find,
		    { desc = "Telescope search in buffer" }
		)
		vim.keymap.set(
		    "n",
		    "<leader>tc",
		    builtin.git_commits,
		    { desc = "Telescope git commits" }
		)
		vim.keymap.set(
		    "n",
		    "<leader>ts",
		    builtin.git_status,
		    { desc = "Telescope git status" }
		)
	end,
}
