local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>ch", function()
		local file = vim.fn.expand("%")
		if file == "" then
			vim.notify("No file open", vim.log.levels.WARN)
			return
		end
		local result = vim.fn.system("chmod +x " .. vim.fn.shellescape(file))
		if vim.v.shell_error ~= 0 then
			vim.notify("chmod failed: " .. result, vim.log.levels.ERROR)
		else
			vim.notify("chmod +x applied to " .. file, vim.log.levels.INFO)
		end
	end, { desc = "chmod +x current file" })
end

return M
