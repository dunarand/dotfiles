local M = {}
local wezterm = require("wezterm")
local act = wezterm.action

function M.apply_to_config(config)
	config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }

	local keys = {
		-- ===============
		-- PANE MANAGEMENT
		-- ===============

		{ key = "RightArrow", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "DownArrow", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "LeftArrow", mods = "ALT", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "UpArrow", mods = "ALT", action = act.TogglePaneZoomState },

		-- ==========
		-- NAVIGATION
		-- ==========

		{ key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
		{ key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
		{ key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
		{ key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
	}

	-- ==============
	-- TAB NAVIGATION
	-- ==============

	for i = 1, 9 do
		table.insert(keys, {
			key = tostring(i),
			mods = "CTRL",
			action = act.ActivateTab(i - 1),
		})
	end

	config.keys = keys
end

return M
