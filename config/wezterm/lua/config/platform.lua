local M = {}
local wezterm = require("wezterm")

function M.apply_to_config(config)
	local platform = wezterm.target_triple

	if platform:find("windows") then
		config.default_prog = { "pwsh.exe", "-NoLogo" }
	elseif platform:find("apple") or platform:find("linux") then
		config.enable_wayland = false
		config.default_prog = { "/bin/fish", "--login" }
	end
end

return M
