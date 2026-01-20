local M = {}

local function run_python_file()
	local file = vim.fn.expand("%")

	if vim.fn.expand("%:e") ~= "py" then
		vim.notify("Not a Python file!", vim.log.levels.WARN)
		return
	end

	if vim.bo.modified then
		vim.notify("Please save the file first!", vim.log.levels.WARN)
		return
	end

	vim.cmd("!python3 " .. file)
end

function M.setup()
	vim.api.nvim_create_user_command("RunPython", run_python_file, {})

	vim.keymap.set("n", "<leader>py", run_python_file, {
		desc = "Run Python file",
	})
end

return M
