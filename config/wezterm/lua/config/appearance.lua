local M = {}
local wezterm = require("wezterm")

function M.apply(config)
	config.color_scheme = "Oceanic-Next"
	config.window_background_opacity = 0.9

	config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" })
	config.font_size = 10.0

	config.initial_cols = 120
	config.initial_rows = 28

	config.window_decorations = "RESIZE"
end

return M
