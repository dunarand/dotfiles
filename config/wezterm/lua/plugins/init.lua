local M = {}

function M.setup(config)
	require("lua.plugins.tabline").apply_to_config(config)
end

return M
