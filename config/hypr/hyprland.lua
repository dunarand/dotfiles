local hypr_dir = os.getenv("HOME") .. "/.config/hypr"

package.path = hypr_dir .. "/lua/?.lua;"
            .. hypr_dir .. "/lua/?/init.lua;"
            .. hypr_dir .. "/hyprconf/?.lua;"
            .. hypr_dir .. "/hyprconf/?/init.lua;"
            .. package.path

-- Max Priority
require("core.env-vars")
require("core.monitors")
require("autostart.services")

-- Medium Priority
require("core.input")
require("keybinds")

-- Low Priority
require("autostart.applications")
require("core.groups")
require("core.looks")
require("theme")
require("core.plugins")
require("windowrules")
require("core.workspaces")
require("core.permissions")
