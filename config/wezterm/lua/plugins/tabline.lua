local M = {}

local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

function M.apply_to_config(config)
	tabline.setup({
		options = {
			icons_enabled = true,
			theme = "Catppuccin Mocha",
			section_separators = { left = "", right = "" },
			component_separators = { left = "|", right = "|" },
			tab_separators = { left = "", right = "" },
		},
		sections = {
			tabline_a = { "mode" },
			tabline_b = { "workspace" },
			tabline_c = { " " },
			tab_active = {
				"index",
				{ "parent", padding = 0 },
				"/",
				{ "cwd", padding = { left = 0, right = 1 } },
				{ "zoomed", padding = 0 },
			},
			tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
			tabline_x = { "ram", "cpu" },
			tabline_y = { "datetime" },
			tabline_z = { "hostname" },
		},
		extensions = {},
	})

	tabline.apply_to_config(config)
end

return M
