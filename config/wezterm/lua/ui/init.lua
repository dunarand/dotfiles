local wezterm = require("wezterm")
local M = {}

function M.setup(config)
	require("lua.ui.appearance").apply_to_config(config)
    require("lua.ui.tabbar").apply_to_config(config)
end

return M
