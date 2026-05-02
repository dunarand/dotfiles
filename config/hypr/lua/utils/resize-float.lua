-- Window resize toggle
--
-- Resizes a floating window based on predefined resolutions. If a floating
-- window doesn't have the same proportions as the aspect ratio of the monitor
-- setting, then it gets resized by taking the shorter side of the float and
-- finding the smallest bigger preset. e.g. if a float has sides 250 and 125,
-- then 125 is used to resize: find the smallest bigger y-value amongst the
-- resolution presets and use both x and y values to resize the float
--
-- If there are no bigger presets, then it cycles back to the start and the
-- float is resized to the smallest values amongst the presets.

local M = {}

local mon = require("resolution")
local sizes = mon.sizes
local wp = require("window-properties")

local mw = tonumber(mon.width)
local mh = tonumber(mon.height)
local mon_ratio = mw / mh

local presets = {
	sizes.forty,
	sizes.sixty,
	sizes.eighty,
}

local function find_next_preset(val, field)
	for _, preset in ipairs(presets) do
		if preset[field] > val then
			return preset
		end
	end
	return presets[1]
end

function M.resize_float()
	if not wp.floating_state() then
		return
	end
	local wsize = wp.get_wsize()
	if not wsize then
		return
	end

	local target
	local win_ratio = wsize.x / wsize.y

	if math.abs(win_ratio - mon_ratio) > 0.01 then
		local smaller = math.min(wsize.x, wsize.y)
		target = find_next_preset(smaller, "y")
	else
		target = find_next_preset(wsize.x, "x")
	end

	hl.dispatch(hl.dsp.window.resize({ x = target.x, y = target.y }))
end

return M
