local M = {}

function M.apply_to_config(config)
	config.tab_bar_at_bottom = true
	-- config.show_close_tab_button_in_tabs = true -- only on nightly currently
	config.show_new_tab_button_in_tab_bar = false

	config.tab_max_width = 32
end

return M
