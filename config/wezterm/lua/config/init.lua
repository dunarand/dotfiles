local M = {}

function M.setup(config)
    require("lua.config.platform").apply_to_config(config)
end

return M
