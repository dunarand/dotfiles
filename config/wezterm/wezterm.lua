local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("lua.config").setup(config)
require("lua.keymaps").setup(config)
require("lua.plugins").setup(config)
require("lua.ui").setup(config)

return config
