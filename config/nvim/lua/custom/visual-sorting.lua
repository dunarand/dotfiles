--- Visual mode alphanumeric line sorting. Keybinds: go (case-insensitive), gO (case-sensitive).
--- Ignores special characters
--- eg. require("custom.visual-sorting").setup() is converted to requirecustomvisualsortingsetup
--- and then it is sorted.

local M = {}

local function get_sortable_string(str)
	return str:gsub("[^%w]", "")
end

local function sort_visual_selection(case_sensitive)
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")

	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	table.sort(lines, function(a, b)
		local a_clean = get_sortable_string(a)
		local b_clean = get_sortable_string(b)

		if case_sensitive then
			return a_clean < b_clean
		else
			return a_clean:lower() < b_clean:lower()
		end
	end)

	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

function M.setup(opts)
	opts = opts or {}

	vim.keymap.set("v", "go", function()
		sort_visual_selection(false)
	end, {
		desc = "Sort selected lines alphanumerically (case-insensitive)",
		noremap = true,
		silent = true,
	})

	vim.keymap.set("v", "gO", function()
		sort_visual_selection(true)
	end, {
		desc = "Sort selected lines alphanumerically (case-sensitive)",
		noremap = true,
		silent = true,
	})
end

return M
