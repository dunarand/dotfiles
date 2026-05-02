-- ==========================
-- ==== STEAM GAME RULES ====
-- ==========================

-- General Game
hl.window_rule({
	name = "steam-game",
	match = { class = "steam_app.*" },
	workspace = 1,
	focus_on_activate = true,
	fullscreen = true,
	tag = "game",
})

-- ===============================================

hl.window_rule({
	name = "squad-launcher",
	match = { class = "steam_app_393380", title = "SquadGame" },
	workspace = "1 silent",
	focus_on_activate = false,
	float = true,
	fullscreen = false,
})

hl.window_rule({
	name = "squad-launcher-2",
	match = { class = "steam_app_393380", title = "^$" },
	workspace = "1 silent",
	focus_on_activate = false,
	float = true,
	fullscreen = false,
})

-- ===============================================

hl.window_rule({
	name = "megabonk",
	match = { class = "Megabonk.x86_64" },
	workspace = 1,
	focus_on_activate = true,
	fullscreen = true,
	tag = "game",
})

-- ===============================================

hl.window_rule({
	name = "slay-the-spire",
	match = { class = "Slay the Spire|Slay the Spire 2" },
	workspace = 1,
	focus_on_activate = true,
	fullscreen = true,
	tag = "game",
})

-- ===============================================

hl.window_rule({
	name = "beamng",
	match = { class = "BeamNG.drive.x64" },
	workspace = 1,
	focus_on_activate = true,
	fullscreen = true,
	tag = "game",
})

-- ===============================================

hl.window_rule({
	name = "seven-days-to-end-with-you",
	match = { class = "steam_app_1859280", title = "Seven Days to End with You" },
	workspace = 1,
	focus_on_activate = true,
	center = true,
	float = true,
	fullscreen = false,
	size = "1600 900",
	tag = "game",
})

-- ===============================================

hl.window_rule({
	name = "lari-launcher",
	match = { class = "steam_app_1086940", title = "LariLauncher" },
	workspace = "1 silent",
	focus_on_activate = false,
	center = true,
	float = true,
	fullscreen = false,
})

hl.window_rule({
	name = "baldurs-gate-3",
	match = { class = "bg3", title = "Baldur's Gate 3.*" },
	workspace = 1,
	focus_on_activate = true,
	fullscreen = true,
	tag = "game",
})

-- ===============================================

hl.window_rule({
	name = "ready-or-not-launcher",
	match = { class = "steam_app_1144200" },
	workspace = "1 silent",
	focus_on_activate = true,
	fullscreen = false,
	float = true,
	center = true,
})
