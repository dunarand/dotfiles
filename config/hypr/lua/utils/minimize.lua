-- Window Minimize Script
--
-- Puts all windows in the active workspace to a special workspace called
-- minimized.

local M = {}

local origins = {}

local function minimize(w)
	origins[w.address] = w.workspace.name
	hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
end

local function unminimize(w)
	local origin = origins[w.address] or "1"
	origins[w.address] = nil
	hl.dispatch(hl.dsp.window.move({ workspace = origin, follow = false }))
end

function M.minimize_toggle()
	local w = hl.get_active_window()
	if w == nil then
		return
	end
	if w.workspace.name == "special:minimized" then
		unminimize(w)
	elseif w.workspace.special then
		return
	else
		minimize(w)
	end
end

return M
