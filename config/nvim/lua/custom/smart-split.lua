local M = {}

local function find_bracket_pair(line, cursor_col)
	local bracket_pairs = {
		["("] = ")",
		["["] = "]",
		["{"] = "}",
		[")"] = "(",
		["]"] = "[",
		["}"] = "{",
	}

	local function is_opening(char)
		return char == "(" or char == "[" or char == "{"
	end

	local function is_closing(char)
		return char == ")" or char == "]" or char == "}"
	end

	local function matches(open_char, close_char)
		return bracket_pairs[open_char] == close_char
	end

	local open_pos = nil
	local open_char = nil
	local stack = {}

	for i = cursor_col, 1, -1 do
		local char = line:sub(i, i)

		if is_closing(char) then
			table.insert(stack, char)
		elseif is_opening(char) then
			if #stack > 0 and matches(char, stack[#stack]) then
				table.remove(stack)
			else
				open_pos = i
				open_char = char
				break
			end
		end
	end

	if not open_pos then
		return nil, nil, nil, nil
	end

	local close_pos = nil
	local close_char = bracket_pairs[open_char]
	stack = {}

	for i = open_pos, #line do
		local char = line:sub(i, i)

		if is_opening(char) then
			table.insert(stack, char)
		elseif is_closing(char) then
			if #stack > 0 and matches(stack[#stack], char) then
				table.remove(stack)
				if #stack == 0 then
					close_pos = i
					break
				end
			end
		end
	end

	if close_pos then
		return open_pos, close_pos, open_char, close_char
	end

	return nil, nil, nil, nil
end

function M.split_brackets()
	local line = vim.api.nvim_get_current_line()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1

	local open_pos, close_pos, open_char, close_char = find_bracket_pair(line, col)

	if not open_pos then
		print("No bracket pair found around cursor")
		return
	end

	local content = line:sub(open_pos + 1, close_pos - 1)
	local prefix = line:sub(1, open_pos)
	local suffix = line:sub(close_pos)

	if vim.trim(content) == "" then
		print("No content to split")
		return
	end

	local items = {}
	local current_item = ""
	local depth = 0
	local in_string = false
	local string_char = nil

	for i = 1, #content do
		local char = content:sub(i, i)

		if (char == '"' or char == "'") and (i == 1 or content:sub(i - 1, i - 1) ~= "\\") then
			if not in_string then
				in_string = true
				string_char = char
			elseif char == string_char then
				in_string = false
				string_char = nil
			end
			current_item = current_item .. char
		elseif not in_string and (char == "(" or char == "[" or char == "{") then
			depth = depth + 1
			current_item = current_item .. char
		elseif not in_string and (char == ")" or char == "]" or char == "}") then
			depth = depth - 1
			current_item = current_item .. char
		elseif not in_string and char == "," and depth == 0 then
			local trimmed = vim.trim(current_item)
			if trimmed ~= "" then
				table.insert(items, trimmed)
			end
			current_item = ""
		else
			current_item = current_item .. char
		end
	end

	local trimmed = vim.trim(current_item)
	if trimmed ~= "" then
		table.insert(items, trimmed)
	end

	if #items <= 1 then
		print("No commas found to split on")
		return
	end

	local indent = line:match("^%s*") or ""
	local shiftwidth = vim.bo.shiftwidth
	local item_indent = indent .. string.rep(" ", shiftwidth)

	local new_lines = { prefix }
	for i, item in ipairs(items) do
		if i < #items then
			table.insert(new_lines, item_indent .. item .. ",")
		else
			table.insert(new_lines, item_indent .. item)
		end
	end
	table.insert(new_lines, indent .. suffix)

	vim.api.nvim_buf_set_lines(0, row - 1, row, false, new_lines)

	vim.api.nvim_win_set_cursor(0, { row + 1, #item_indent })
end

function M.setup()
	vim.keymap.set("n", "<S-k>", M.split_brackets, {
		noremap = true,
		silent = true,
		desc = "Split bracket content onto separate lines",
	})
end

return M
