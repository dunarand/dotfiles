local M = {}

local function insert_list_item()
	local line = vim.api.nvim_get_current_line()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor[1], cursor[2]

	local patterns = {
		"^(#%s*)(%s*)([%-*])%s+",
		"^(#%s*)(%s*)(%d+%.)%s+",
	}

	for _, pattern in ipairs(patterns) do
		local comment_prefix, indent, marker = line:match(pattern)

		if comment_prefix and indent and marker then
			local new_marker = marker
			if marker:match("%d+%.") then
				local num = tonumber(marker:match("%d+"))
				new_marker = (num + 1) .. "."
			end

			local new_line = comment_prefix .. indent .. new_marker .. " "

			vim.api.nvim_buf_set_lines(0, row, row, false, { new_line })

			vim.api.nvim_win_set_cursor(0, { row + 1, #new_line })

			vim.cmd("startinsert!")

			return
		end
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
end

function M.setup()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		callback = function()
			if vim.fn.expand("%:e") == "py" then
				vim.keymap.set("i", "<C-j>", insert_list_item, {
					buffer = true,
					desc = "Insert next list item in Jupytext markdown",
				})
			end
		end,
	})
end

return M
