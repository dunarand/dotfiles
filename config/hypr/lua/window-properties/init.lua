local M = {}

local function get_window()
	return hl.get_active_window()
end

function M.get_wsize()
	local w = get_window()
	if not w then
		return nil
	end
	return { x = w.size.x, y = w.size.y }
end

function M.floating_state()
	local w = get_window()
	if not w then
		return nil
	end
	return w.floating
end

function M.fullscreen_state()
    local w = get_window()
    if not w then
        return nil
    end
    return w.fullscreen
end

function M.get_class()
	local w = get_window()
	if not w then
		return nil
	end
	return w.class
end

function M.get_initial_class()
	local w = get_window()
	if not w then
		return nil
	end
	return w.initial_class
end

function M.get_title()
	local w = get_window()
	if not w then
		return nil
	end
	return w.title
end

function M.get_initial_title()
	local w = get_window()
	if not w then
		return nil
	end
	return w.initial_title
end

return M
