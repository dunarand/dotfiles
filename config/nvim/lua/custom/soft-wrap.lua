local M = {}

local function toggle_wrap()
	local current_wrap = vim.opt.wrap:get()
	local new_state = not current_wrap

	vim.opt.wrap = new_state
	vim.opt.linebreak = new_state
	vim.opt.breakindent = new_state

	if new_state then
		vim.notify("Soft Wrap Enabled", vim.log.levels.INFO, { title = "Neovim" })
	else
		vim.notify("Soft Wrap Disabled", vim.log.levels.INFO, { title = "Neovim" })
	end
end

function M.setup()
	vim.opt.textwidth = 0
	vim.opt.wrapmargin = 0
	vim.opt.wrap = true
	vim.opt.linebreak = true
	vim.opt.breakindent = true

	-- Set up toggle keybinding
	vim.keymap.set("n", "<leader>w", toggle_wrap, {
		desc = "Toggle Soft Wrap",
	})
end

return M
