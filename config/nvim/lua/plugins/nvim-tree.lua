local yellow = "#f3e790"
local orange = "#ff964f"
local red = "#ff6961"
local blue = "#4f7292"
local green = "#b2fba5"
local grey = "#717382"
local white = "#dcdcdc"

return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "NvimTreeToggle", "NvimTreeFocus" },
	keys = {
		{
			"<C-n>",
			function()
				local view = require("nvim-tree.view")
				if view.is_visible() then
					require("nvim-tree.api").tree.close()
				else
					require("nvim-tree.api").tree.open()
				end
			end,
			desc = "Toggle nvim-tree",
		},
	},
	config = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
		vim.opt.termguicolors = true

		local function on_attach(bufnr)
			local api = require("nvim-tree.api")
			local function opts(desc)
				return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end

			vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
			vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
			vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
			vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
			vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
			vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
			vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
			vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
			vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))

			vim.keymap.set("n", "a", function()
				api.fs.create()
				vim.defer_fn(function()
					api.tree.reload()
				end, 50)
			end, opts("Create"))

			vim.keymap.set("n", "d", function()
				api.fs.remove()
				vim.defer_fn(function()
					api.tree.reload()
				end, 50)
			end, opts("Delete"))

			vim.keymap.set("n", "r", function()
				api.fs.rename()
				vim.defer_fn(function()
					api.tree.reload()
				end, 50)
			end, opts("Rename"))
			vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
			vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
			vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
			vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
			vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
			vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
			vim.keymap.set("n", "f", api.tree.find_file, opts("Find File"))
			vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
			vim.keymap.set("n", "q", api.tree.close, opts("Close"))
		end

		local tree = require("nvim-tree")
		tree.setup({
			sort = {
				sorter = "case_sensitive",
			},
			view = {
				width = 30,
				side = "left",
				preserve_window_proportions = false,
				number = false,
				relativenumber = false,
				signcolumn = "yes",
				float = {
					enable = false,
				},
			},
			renderer = {
				group_empty = true,
				highlight_git = true,
				icons = {
					show = {
						git = true,
					},
					glyphs = {
						git = {
							unstaged = " ",
							staged = " ",
							unmerged = " ",
							renamed = " ",
							untracked = " ",
							deleted = " ",
							ignored = " ",
						},
					},
					git_placement = "signcolumn",
				},
			},
			filters = {
				dotfiles = false,
			},
			git = {
				enable = true,
				ignore = false,
				show_on_dirs = true,
				show_on_open_dirs = true,
				disable_for_dirs = {},
				timeout = 400,
			},
			on_attach = on_attach,
			update_focused_file = {
				enable = true,
				update_root = false,
			},
		})
		local function set_tree_colors()
			vim.api.nvim_set_hl(0, "NvimTreeGitDirtyIcon", { fg = orange })
			vim.api.nvim_set_hl(0, "NvimTreeGitStagedIcon", { fg = yellow })
			vim.api.nvim_set_hl(0, "NvimTreeGitMergeIcon", { fg = white })
			vim.api.nvim_set_hl(0, "NvimTreeGitRenamedIcon", { fg = blue })
			vim.api.nvim_set_hl(0, "NvimTreeGitNewIcon", { fg = green })
			vim.api.nvim_set_hl(0, "NvimTreeGitDeletedIcon", { fg = red })
			vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredIcon", { fg = grey })
		end

		set_tree_colors()

		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = set_tree_colors,
		})
		vim.keymap.set("n", "<C-n>", function()
			require("nvim-tree.api").tree.toggle()
		end, { desc = "Toggle nvim-tree", silent = true })
		-- Auto-focus on file when buffer changes (for harpoon)
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("NvimTreeAutoFocus", { clear = true }),
			callback = function()
				if require("nvim-tree.view").is_visible() then
					require("nvim-tree.api").tree.find_file({ open = false, focus = false })
				end
			end,
		})
	end,
}
