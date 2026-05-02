-- Window float toggle
--
-- Toggle's a window's float state. When a window is toggled to a float, the
-- script resizes the window to a predetermined resolution and centers it.

local M = {}

local wp = require("window-properties")
local fifty = require("resolution").sizes.fifty

function M.toggle_float()
	if not wp.floating_state() then
		hl.dispatch(hl.dsp.window.float({ action = "set" }))
		hl.dispatch(hl.dsp.window.resize({ x = fifty.x, y = fifty.y }))
		hl.dispatch(hl.dsp.window.center())
	else
		hl.dispatch(hl.dsp.window.float({ action = "unset" }))
	end
end

return M
