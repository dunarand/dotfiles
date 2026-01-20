local M = {}

local virtual_text_enabled = true

local config = {
	virtual_text = {

		spacing = 4,
		prefix = "",
	},
	icons = {
		[vim.diagnostic.severity.ERROR] = " ",
		[vim.diagnostic.severity.WARN] = " ",
		[vim.diagnostic.severity.HINT] = " ",
		[vim.diagnostic.severity.INFO] = " ",
	},
}

local function toggle_virtual_text()
	if virtual_text_enabled then
		vim.diagnostic.config({ virtual_text = false })
	else
		vim.diagnostic.config({ virtual_text = config.virtual_text })
	end
	virtual_text_enabled = not virtual_text_enabled
end

local function open_diagnostic_float()
	vim.diagnostic.open_float({ focus = true })
end

function M.setup()
	vim.diagnostic.config({
		signs = {
			text = config.icons,
		},
		virtual_text = config.virtual_text,
		update_in_insert = false,
		underline = true,
		severity_sort = true,
		float = {
			focusable = true,
			style = "minimal",
			border = "rounded",
			source = true,
			header = "Diagnostics",
			prefix = function(diagnostic, i, total)
				return config.icons[diagnostic.severity] or " ",
					"DiagnosticFloating" .. vim.diagnostic.severity[diagnostic.severity]
			end,
		},
	})

	vim.keymap.set("n", "<leader>qt", toggle_virtual_text, {
		desc = "Toggle inline diagnostics",
	})

	vim.keymap.set("n", "<leader>qf", open_diagnostic_float, {
		desc = "Focus diagnostic float",
	})
end

return M
