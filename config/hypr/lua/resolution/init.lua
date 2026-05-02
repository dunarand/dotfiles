local w, h = require("resolution.monitor-resolution").get()
local fractions = require("resolution.sizes")

local M = {}

M.width = w
M.height = h

M.sizes = {}
for name, frac in pairs(fractions) do
    M.sizes[name] = {
        x = math.floor(w * frac),
        y = math.floor(h * frac),
    }
end

function M.as_array(size)
    return { size.x, size.y }
end

return M
