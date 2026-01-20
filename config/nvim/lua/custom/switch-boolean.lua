local M = {}

local boolean_patterns = {
	-- Lua, JavaScript, TypeScript, C, C++, Java, etc.
	{ pattern = "%f[%w]true%f[%W]", replacement = "false" },
	{ pattern = "%f[%w]false%f[%W]", replacement = "true" },

	-- Python, Ruby
	{ pattern = "%f[%w]True%f[%W]", replacement = "False" },
	{ pattern = "%f[%w]False%f[%W]", replacement = "True" },

	-- C#, some others
	{ pattern = "%f[%w]TRUE%f[%W]", replacement = "FALSE" },
	{ pattern = "%f[%w]FALSE%f[%W]", replacement = "TRUE" },

	-- Switch between 0 and 1
	{ pattern = "%f[%d]0%f[%D]", replacement = "1" },
	{ pattern = "%f[%d]1%f[%D]", replacement = "0" },
}

function M.toggle()
	local line = vim.api.nvim_get_current_line()
	local modified = false
	local new_line = line

	for _, bool in ipairs(boolean_patterns) do
		local count
		new_line, count = new_line:gsub(bool.pattern, bool.replacement)
		if count > 0 then
			modified = true
			break
		end
	end

	if modified then
		vim.api.nvim_set_current_line(new_line)
	end
end

function M.setup()
	vim.keymap.set("n", "gb", M.toggle, {
		desc = "Toggle boolean (true/false, True/False, TRUE/FALSE)",
		silent = true,
	})
end

return M
