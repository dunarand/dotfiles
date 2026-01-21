local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

-- Common configuration
local molten_config = {
	image_provider = is_windows and "none" or "image.nvim",
	output_win_max_height = 20,
	auto_open_output = false,
	wrap_output = true,
	virt_text_output = true,
	virt_lines_off_by_1 = false,
	output_show_more = true,
	enter_output_behavior = "open_and_enter",
	output_win_style = "minimal",
	use_border_highlights = true,
	virt_text_max_lines = 12,
	cover_empty_lines = false,
	auto_init_behavior = "init",
	output_win_border = {
		{ "╭", "Normal" },
		{ "─", "Normal" },
		{ "╮", "Normal" },
		{ "│", "Normal" },
		{ "╯", "Normal" },
		{ "─", "Normal" },
		{ "╰", "Normal" },
		{ "│", "Normal" },
	},
}

-- Helper functions
local function molten_init_venv()
	local venv_python = vim.env.VIRTUAL_ENV
	if venv_python then
		local kernel_name = is_windows and vim.fn.fnamemodify(venv_python, ":t") or "python3"
		vim.cmd("MoltenInit " .. kernel_name)
		vim.notify("Molten initialized with venv: " .. (venv_python or "python3"), vim.log.levels.INFO)
	else
		vim.cmd("MoltenInit python3")
		vim.notify("Molten initialized with system python3", vim.log.levels.WARN)
	end
end

local function molten_set_cwd()
	local notebook_dir = vim.fn.expand("%:p:h")
	local escaped_dir = is_windows and notebook_dir:gsub("\\", "\\\\") or notebook_dir
	local change_dir_code = string.format("import os; os.chdir(r'%s');", escaped_dir)

	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, current_line, current_line, false, { change_dir_code })
	vim.cmd("normal! j")
	vim.cmd("MoltenEvaluateLine")
	vim.cmd("normal! dd")
end

local function execute_cell()
	if string.find(vim.api.nvim_get_current_line(), "# %%", 1, true) then
		vim.api.nvim_input("j")
	else
		vim.api.nvim_input("?# %%<CR>j")
	end
	vim.api.nvim_input("/# %%<CR>NjVnk:<BS><BS><BS><BS><BS>MoltenEvaluateVisual<CR>")
end

local function setup_keymaps()
	vim.keymap.set("n", "<leader>mi", molten_init_venv, { desc = "Molten: Initialize kernel", silent = true })
	vim.keymap.set("n", "<leader>mw", molten_set_cwd, { desc = "Molten: Set kernel working directory", silent = true })
	vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { desc = "Molten: Evaluate operator", silent = true })
	vim.keymap.set("n", "<leader>ml", ":MoltenEvaluateLine<CR>", { desc = "Molten: Evaluate line", silent = true })
	vim.keymap.set("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Molten: Evaluate visual", silent = true })
	vim.keymap.set("n", "<leader>mc", execute_cell, { desc = "Molten: Execute cell block", silent = true })
	vim.keymap.set("n", "<leader>mo", ":MoltenShowOutput<CR>", { desc = "Molten: Show output window", silent = true })
	vim.keymap.set("n", "<leader>mO", ":noautocmd lua vim.api.nvim_set_current_win(vim.api.nvim_list_wins()[#vim.api.nvim_list_wins()])<CR>", { desc = "Molten: Enter output", silent = true })
	vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", { desc = "Molten: Hide output window", silent = true })
	vim.keymap.set("n", "<leader>mI", ":MoltenInterrupt<CR>", { desc = "Molten: Interrupt execution", silent = true })
	vim.keymap.set("n", "<leader>mR", ":MoltenRestart<CR>", { desc = "Molten: Restart Kernel", silent = true })
	vim.keymap.set("n", "<leader>mD", ":MoltenDeinit<CR>", { desc = "Molten: Deinitialize", silent = true })
	vim.keymap.set("n", "]c", function()
		vim.fn.search("^# %%", "W")
	end, { desc = "Molten: Next cell", silent = true })
	vim.keymap.set("n", "[c", function()
		vim.fn.search("^# %%", "bW")
	end, { desc = "Molten: Previous cell", silent = true })
end

-- Plugin specification
return {
	"benlubas/molten-nvim",
	version = "^1.0.0",
	build = ":UpdateRemotePlugins",
	ft = { "python" },
	dependencies = is_windows and {} or { "3rd/image.nvim" },
	init = function()
		for key, value in pairs(molten_config) do
			vim.g["molten_" .. key] = value
		end
	end,
	config = function()
		setup_keymaps()
	end,
}
