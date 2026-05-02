-- =======================
-- ==== GENERAL RULES ====
-- =======================

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "no-blur",
	match = { class = "^()$", title = "^()$" },
	no_blur = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	name = "Hyprland Share Screen Selector",
	match = { class = "hyprland-share-picker" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "file-dialogs",
	match = {
		title = "(?i)(open|select|choose|save|pick)\\s*(file|files|folder|as|document|doc|item)",
	},
	center = true,
	float = true,
})

hl.window_rule({
	name = "properties-dialogs",
	match = { title = "(?i)(properties)" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "wants-to-save-open",
	match = { title = ".*wants to.*" },
	center = true,
	float = true,
})
