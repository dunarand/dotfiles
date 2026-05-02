-- Window property capturing
--
-- Captures a window's properties and creates a window rule snippet

local M = {}

local wp = require("window-properties")

function M.generate_windowrule()
	local template = string.format(
		[[
hl.window_rule({
    name = "",
    match = { class = "%s", title = "%s", initial_class = "%s", initial_title = "%s" },
    center = true,
    float = %s,
    fullscreen = %s,
    size = {"%s", "%s"},
})
        ]],
		wp.get_class(),
		wp.get_title(),
		wp.get_initial_class(),
		wp.get_initial_title(),
		wp.floating_state(),
		wp.fullscreen_state(),
		wp.get_wsize().x,
		wp.get_wsize().y
	)
	hl.dsp.exec_cmd("echo " .. string.format("%q", template) .. " | wl-copy")()
end

return M
