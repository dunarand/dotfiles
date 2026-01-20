local M = {}
local wezterm = require("wezterm")

function M.apply_to_config(config)
	config.color_scheme = "catppuccin-mocha"

	config.window_background_opacity = 0.9
	config.window_padding = {
		left = 10,
		right = 10,
		top = 10,
		bottom = 10,
	}
	config.window_decorations = "TITLE | RESIZE"

	config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" })
	config.font_size = 10.0

	config.initial_cols = 120
	config.initial_rows = 28

	config.default_cursor_style = "SteadyBar"
	config.force_reverse_video_cursor = true

	config.inactive_pane_hsb = {
		saturation = 0.8,
		brightness = 0.6,
	}

	config.enable_scroll_bar = true

	config.hide_mouse_cursor_when_typing = false
	config.pane_focus_follows_mouse = true
end

return M
