return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		dashboard = {
			enabled = true,
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{
					section = "terminal",
					title = "Git Status",
					enabled = function()
						return Snacks.git.get_root() ~= nil
					end,
					cmd = "git status --short --branch --renames",
					height = 5,
					padding = 1,
					ttl = 5 * 60,
					indent = 3,
				},
				{ section = "startup" },
			},
			preset = {
				keys = {
					{
						icon = "󰈞 ",
						key = "f",
						desc = "Find File",
						action = ":lua Snacks.dashboard.pick('files')",
					},
					{
						icon = "󱎸 ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{
						icon = " ",
						key = "n",
						desc = "New File",
						action = ":ene | startinsert",
					},
					{
						icon = " ",
						key = "p",
						desc = "New Project",
						action = ":ProjectNew",
					},
					{
						icon = "󰦛 ",
						key = "s",
						desc = "Restore Session",
						section = "session",
					},
					{
						icon = "󰒋 ",
						key = "M",
						desc = "Mason",
						action = ":Mason",
					},
					{
						icon = "󰒲 ",
						key = "L",
						desc = "Lazy",
						action = ":Lazy",
					},
					{
						icon = "󰈆 ",
						key = "q",
						desc = "Quit",
						action = ":qa",
					},
				},
				header = [[
███████╗ ██╗   ██╗███╗   ██╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
██╔═══██╗██║   ██║████╗  ██║██╔═══██╗██║   ██║██║████╗ ████║
██║   ██║██║   ██║██╔██╗ ██║████████║██║   ██║██║██╔████╔██║
██║   ██║██║   ██║██║╚██╗██║██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
███████╔╝╚██████╔╝██║ ╚████║██║   ██║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚══════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
			},
		},
	},
}
