return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local expanded = true

		local function toggle_lualine()
			expanded = not expanded
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "auto",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = {},
						winbar = {},
					},
					ignore_focus = {},
					always_divide_middle = true,
					always_show_tabline = true,
					globalstatus = true,
					refresh = {
						statusline = 1000,
						tabline = 1000,
						winbar = 1000,
						refresh_time = 16,
						events = {
							"WinEnter",
							"BufEnter",
							"BufWritePost",
							"SessionLoadPost",
							"FileChangedShellPost",
							"VimResized",
							"Filetype",
							"CursorMoved",
							"CursorMovedI",
							"ModeChanged",
						},
					},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						{
							"branch",
							color = { gui = "bold" },
						},
						{
							"diff",
							colored = true,
						},
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							symbols = {
								error = " ",
								warn = " ",
								info = " ",
								hint = " ",
							},
						},
					},
					lualine_c = expanded and {
						{
							"filename",
							path = 1,
							symbols = {

								modified = " ",
								readonly = " ",
								unnamed = " ",
								newfile = " ",
							},
						},
					} or {
						{
							"filename",
							path = 0,
							symbols = {
								modified = " ",
								readonly = " ",
								unnamed = " ",
								newfile = " ",
							},
						},
					},
					lualine_x = {
						{
							function()
								local clients = vim.lsp.get_clients({ bufnr = 0 })
								if next(clients) == nil then
									return ""
								end

								local client_names = {}
								for _, client in pairs(clients) do
									table.insert(client_names, client.name)
								end

								return "󰒋 [" .. table.concat(client_names, ", ") .. "]"
							end,
						},
					},
					lualine_y = expanded and {
						"encoding",
						{
							function()
								local size = vim.fn.getfsize(vim.fn.expand("%:p"))
								if size < 0 then
									return ""
								end
								if size < 1024 then
									return string.format(" %dB", size)
								elseif size < 1024 * 1024 then
									return string.format(" %.1fKB", size / 1024)
								else
									return string.format(" %.1fMB", size / (1024 * 1024))
								end
							end,
						},
						"filetype",
					} or { "filetype" },
					lualine_z = expanded and {
						{
							function()
								local mem = vim.loop.resident_set_memory() or vim.uv.resident_set_memory()
								return string.format(" %.0fMB", mem / 1024 / 1024)
							end,
						},
						"location",
					} or { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				winbar = {},
				inactive_winbar = {},
				extensions = {},
			})
		end

		toggle_lualine()

		vim.keymap.set("n", "<leader>lt", toggle_lualine, { desc = "Toggle lualine statusline info" })
	end,
}
