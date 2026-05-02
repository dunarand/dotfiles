local M = {}

function M.get()
	local m = hl.get_active_monitor()
	if m then
		local w = m.width
		local h = m.height
		if w and h then
			return w, h
		end
	end
	return 2560, 1440
end

return M
