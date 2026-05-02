-- Close floats or unfocus special workspaces
--
-- Closes floats on regular workspaces and unfocuses from special workspaces.
-- If activated on top of a special workspace with a floating window, it simply
-- unfocuses from special workspace instead of closing the floating window.

local M = {}

local wp = require("window-properties")

function M.close_or_unfocus()
	local special = hl.get_active_special_workspace()
	if special then
		-- special:xyz is returned as active_special_workspace.name but workspace.toggle_special
		-- works only with the special workspace name without the special: prefix
		-- so we take the substring, stripping so that we only get the name of the special ws
		hl.dispatch(hl.dsp.workspace.toggle_special(string.sub(special.name, 9)))
		return
	end
	if wp.floating_state() then
		hl.dispatch(hl.dsp.window.close())
	end
end

return M
