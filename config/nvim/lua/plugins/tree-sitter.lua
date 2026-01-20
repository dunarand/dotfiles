return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("nvim-treesitter.configs").setup({
			modules = {},
			ignore_install = {},
			ensure_installed = {
				"lua",
				"python",
				"sql",
				"css",
				"html",
				"csv",
				"json",
				"toml",
				"yaml",
                "bash",
			},
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				-- Disable for large files
				disable = function(_, buf)
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
				disable = { "python" },
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<CR>",
					node_incremental = "<CR>",
					scope_incremental = "<C-S-CR>",
					node_decremental = "<BS>",
				},
			},
		})
	end,
}
