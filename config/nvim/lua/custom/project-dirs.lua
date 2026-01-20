local M = {}

M.templates = {}

local function load_templates()
	local template_path = vim.fn.stdpath("config") .. "/lua/custom/templates"
	local files = vim.fn.globpath(template_path, "*.lua", false, true)

	for _, file in ipairs(files) do
		local name = vim.fn.fnamemodify(file, ":t:r")
		local ok, template = pcall(require, "custom.templates." .. name)
		if ok then
			M.templates[name] = template
		else
			vim.notify("Failed to load template: " .. name, vim.log.levels.ERROR)
		end
	end
end

local function process_content(content, vars)
	for key, value in pairs(vars) do
		content = content:gsub("{{" .. key .. "}}", value)
	end
	return content
end

function M.create_project(project_name, template_name)
	load_templates()

	local template = M.templates[template_name]
	if not template then
		vim.notify("Template '" .. template_name .. "' not found!", vim.log.levels.ERROR)
		return
	end

	local project_path = vim.fn.getcwd() .. "/" .. project_name
	if vim.fn.isdirectory(project_path) == 1 then
		vim.notify("Directory '" .. project_name .. "' already exists!", vim.log.levels.ERROR)
		return
	end

	vim.fn.mkdir(project_path, "p")
	local vars = { PROJECT_NAME = project_name }

	for _, dir in ipairs(template.dirs or {}) do
		local processed_dir = process_content(dir, vars)
		vim.fn.mkdir(project_path .. "/" .. processed_dir, "p")
	end

	for file_path, content in pairs(template.files or {}) do
		local processed_path = process_content(file_path, vars)
		local full_path = project_path .. "/" .. processed_path
		local processed_content = process_content(content, vars)

		local file = io.open(full_path, "w")
		if file then
			file:write(processed_content)
			file:close()
		end
	end

	if template.commands and #template.commands > 0 then
		for _, cmd in ipairs(template.commands) do
			local processed_cmd = process_content(cmd, vars)
			local output = vim.fn.system(string.format("cd %s && %s", vim.fn.shellescape(project_path), processed_cmd))

			if vim.v.shell_error ~= 0 then
				vim.notify("Error running command: " .. processed_cmd .. "\n" .. output, vim.log.levels.ERROR)
			end
		end
	end

	vim.notify("Project '" .. project_name .. "' created successfully!", vim.log.levels.INFO)
end

function M.create_project_interactive()
	local template_names = {}
	local template_descriptions = {}

	for name, template in pairs(M.templates) do
		table.insert(template_names, name)
		template_descriptions[name] = template.description
	end

	vim.ui.select(template_names, {
		prompt = "Select project template:",
		format_item = function(item)
			return item .. " - " .. template_descriptions[item]
		end,
	}, function(choice)
		if not choice then
			return
		end

		vim.ui.input({
			prompt = "Project name: ",
		}, function(project_name)
			if project_name and project_name ~= "" then
				M.create_project(project_name, choice)
			end
		end)
	end)
end

function M.setup()
	load_templates()

	vim.api.nvim_create_user_command("ProjectNew", function()
		M.create_project_interactive()
	end, {})
	vim.api.nvim_create_user_command("ProjectCreate", function(opts)
		local args = vim.split(opts.args, " ")
		if #args < 2 then
			vim.notify("Usage: ProjectCreate <template> <project_name>", vim.log.levels.ERROR)
			return
		end
		M.create_project(args[2], args[1])
	end, {
		nargs = "+",
		complete = function()
			local templates = {}
			for name, _ in pairs(M.templates) do
				table.insert(templates, name)
			end
			return templates
		end,
	})
	vim.api.nvim_create_user_command("ProjectTemplates", function()
		local lines = { "Available project templates:", "" }
		for name, template in pairs(M.templates) do
			table.insert(lines, "  " .. name .. " - " .. template.description)
		end
		vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
	end, {})
end

return M
