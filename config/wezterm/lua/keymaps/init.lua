local M = {}

function M.setup(config)
	require("lua.keymaps.keys").apply_to_config(config)
end

return M
