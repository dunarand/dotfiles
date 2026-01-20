local f = require("luasnip").function_node

local M = {}

M.copy = function(index)
	return f(function(args)
		return args[1][1]
	end, { index })
end

return M
