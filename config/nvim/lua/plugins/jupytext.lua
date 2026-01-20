return {
	{
		"GCBallesteros/jupytext.nvim",
		config = function()
			local jupytext = require("jupytext")
			local original_setup = jupytext.setup

			jupytext.setup = function(opts)
				original_setup(opts)
				local utils = require("jupytext.utils")
				local original_get_metadata = utils.get_ipynb_metadata

				utils.get_ipynb_metadata = function(ipynb_data)
					if not ipynb_data.metadata then
						ipynb_data.metadata = {}
					end

					if not ipynb_data.metadata.kernelspec then
						ipynb_data.metadata.kernelspec = {
							display_name = "Python 3",
							language = "python",
							name = "python3",
						}
					end

					return original_get_metadata(ipynb_data)
				end
			end

			require("jupytext").setup({
				style = "percent",
				output_extension = "auto",
				force_ft = nil,
				custom_language_formatting = {},
			})
		end,
		lazy = false,
	},
	{
		"nvim-lua/plenary.nvim",
		config = function()
			local sync_in_progress = false

			local function jupytext_sync()
				if sync_in_progress then
					return
				end
				sync_in_progress = true

				local file = vim.fn.expand("%:p")
				local is_py = file:match("%.py$")

				vim.fn.jobstart("jupytext --sync " .. vim.fn.shellescape(file), {
					on_exit = function(_, exit_code)
						if exit_code == 0 then
							if not is_py then
								vim.cmd("edit!")
							end
							vim.notify("Synced", vim.log.levels.INFO)
						else
							vim.notify("Sync failed", vim.log.levels.ERROR)
						end
						vim.defer_fn(function()
							sync_in_progress = false
						end, 500)
					end,
				})
			end

			local function jupytext_pair()
				local file = vim.fn.expand("%:p")
				vim.fn.system("jupytext --set-formats ipynb,py:percent " .. vim.fn.shellescape(file))
				vim.notify("Paired with .py file", vim.log.levels.INFO)
			end

			local function jupytext_convert_to_py()
				local file = vim.fn.expand("%:p")
				local output = vim.fn.system("jupytext --to py:percent " .. vim.fn.shellescape(file))
				if vim.v.shell_error == 0 then
					vim.notify("Converted to .py format", vim.log.levels.INFO)
					if file:match("%.ipynb$") then
						local py_file = file:gsub("%.ipynb$", ".py")
						vim.cmd("edit " .. vim.fn.fnameescape(py_file))
					else
						vim.cmd("edit!")
					end
				else
					vim.notify("Conversion failed: " .. output, vim.log.levels.ERROR)
				end
			end

			local function jupytext_convert_to_ipynb()
				local file = vim.fn.expand("%:p")
				local output = vim.fn.system("jupytext --to notebook " .. vim.fn.shellescape(file))
				if vim.v.shell_error == 0 then
					vim.notify("Converted to .ipynb format", vim.log.levels.INFO)
				else
					vim.notify("Conversion failed: " .. output, vim.log.levels.ERROR)
				end
			end

			local function jupytext_execute()
				local file = vim.fn.expand("%:p")
				local ipynb_file = file:gsub("%.py$", ".ipynb")
				vim.notify("Executing notebook...", vim.log.levels.INFO)

				local cmd = string.format(
					"jupytext --sync %s && jupyter nbconvert --to notebook --execute --inplace %s",
					vim.fn.shellescape(file),
					vim.fn.shellescape(ipynb_file)
				)

				vim.fn.jobstart(cmd, {
					on_exit = function(_, exit_code)
						if exit_code == 0 then
							vim.notify("Execution complete", vim.log.levels.INFO)
						else
							vim.notify("Execution failed", vim.log.levels.ERROR)
						end
					end,
				})
			end

			local function jupytext_execute_and_reload()
				local file = vim.fn.expand("%:p")
				local ipynb_file = file:gsub("%.py$", ".ipynb")
				vim.notify("Executing notebook...", vim.log.levels.INFO)

				vim.fn.jobstart(
					string.format(
						"jupytext --sync %s && jupyter nbconvert --execute --to notebook --inplace %s",
						vim.fn.shellescape(file),
						vim.fn.shellescape(ipynb_file)
					),
					{
						on_exit = function(_, exit_code)
							if exit_code == 0 then
								vim.fn.jobstart(string.format("touch %s", vim.fn.shellescape(ipynb_file)))
								vim.notify("Execution complete.", vim.log.levels.INFO)
							else
								vim.notify("Execution failed", vim.log.levels.ERROR)
							end
						end,
					}
				)
			end

			local function jupytext_check_pairing()
				local file = vim.fn.expand("%:p")
				local ipynb_file = file:gsub("%.py$", ".ipynb")

				if vim.fn.filereadable(ipynb_file) == 0 then
					vim.notify("✗ No paired .ipynb found: " .. ipynb_file, vim.log.levels.ERROR)
					return
				end

				local check_cmd = string.format("jupytext --test %s", vim.fn.shellescape(ipynb_file))
				vim.fn.jobstart(check_cmd, {
					on_stdout = function(_, data)
						if data then
							for _, line in ipairs(data) do
								if line ~= "" then
									vim.notify(line, vim.log.levels.INFO)
								end
							end
						end
					end,
					on_exit = function(_, exit_code)
						if exit_code == 0 then
							vim.notify("✓ Pairing is correctly configured!", vim.log.levels.INFO)
						else
							vim.notify("✗ Pairing may not be set up. Run :JupytextPair", vim.log.levels.WARN)
						end
					end,
				})
			end

			vim.keymap.set(
				"n",
				"<leader>jp",
				jupytext_pair,
				{ desc = "Jupytext: Pair with .py file", noremap = true, silent = true }
			)

			vim.keymap.set(
				"n",
				"<leader>js",
				jupytext_sync,
				{ desc = "Jupytext: Sync files", noremap = true, silent = true }
			)

			vim.keymap.set(
				"n",
				"<leader>jc",
				jupytext_convert_to_py,
				{ desc = "Jupytext: Convert to .py", noremap = true, silent = true }
			)

			vim.keymap.set(
				"n",
				"<leader>jn",
				jupytext_convert_to_ipynb,
				{ desc = "Jupytext: Convert to .ipynb", noremap = true, silent = true }
			)

			vim.keymap.set(
				"n",
				"<leader>je",
				jupytext_execute,
				{ desc = "Jupytext: Execute notebook", noremap = true, silent = true }
			)

			vim.keymap.set(
				"n",
				"<leader>jE",
				jupytext_execute_and_reload,
				{ desc = "Jupytext: Execute and reload", noremap = true, silent = true }
			)

			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = "*.py",
				callback = function()
					if sync_in_progress then
						return
					end

					local file = vim.fn.expand("%:p")
					local ipynb_file = file:gsub("%.py$", ".ipynb")

					if vim.fn.filereadable(ipynb_file) == 1 then
						sync_in_progress = true
						vim.fn.jobstart("jupytext --sync " .. vim.fn.shellescape(file), {
							on_exit = function()
								vim.defer_fn(function()
									sync_in_progress = false
								end, 500)
							end,
						})
					end
				end,
			})

			vim.api.nvim_create_user_command(
				"JupytextPair",
				jupytext_pair,
				{ desc = "Pair current file with jupytext" }
			)

			vim.api.nvim_create_user_command(
				"JupytextSync",
				jupytext_sync,
				{ desc = "Sync current file with its pair" }
			)

			vim.api.nvim_create_user_command(
				"JupytextToPy",
				jupytext_convert_to_py,
				{ desc = "Convert to Python format" }
			)

			vim.api.nvim_create_user_command(
				"JupytextToNotebook",
				jupytext_convert_to_ipynb,
				{ desc = "Convert to notebook format" }
			)

			vim.api.nvim_create_user_command("JupytextExecute", jupytext_execute, { desc = "Execute notebook" })

			vim.api.nvim_create_user_command(
				"JupytextExecuteAndReload",
				jupytext_execute_and_reload,
				{ desc = "Execute and trigger reload" }
			)

			vim.api.nvim_create_user_command(
				"JupytextCheckPairing",
				jupytext_check_pairing,
				{ desc = "Check jupytext pairing status" }
			)
		end,
	},
}
