-- ==== SIZE REFERENCES ====

local res = require("resolution")
local sizes = res.sizes

-- =========================
-- ==== APP BASED RULES ====
-- =========================

hl.window_rule({
	name = "spotify",
	match = { class = "spotify|Spotify" },
	workspace = "special:spotify silent",
	focus_on_activate = false,
	center = true,
	float = true,
	size = res.as_array(sizes.seventyfive),
})

-- ===============================================

hl.window_rule({
	name = "obs-windows",
	match = { class = "com.obsproject.Studio" },
	workspace = "special:obs silent",
	center = true,
	float = true,
	size = res.as_array(sizes.fifty),
})

hl.window_rule({
	name = "obs-studio",
	match = { class = "com.obsproject.Studio", title = "OBS.*" },
	size = res.as_array(sizes.fifty),
})

-- ===============================================

hl.window_rule({
	name = "easyeffects",
	match = { class = "com.github.wwmm.easyeffects", title = "Easy Effects" },
	workspace = "special:easyeffects",
	center = true,
	float = true,
	size = res.as_array(sizes.seventyfive),
})

hl.window_rule({
	name = "marktext",
	match = { class = "Marktext", title = "^$" },
	center = true,
})

hl.window_rule({
	name = "localsend",
	match = { class = "localsend" },
	center = true,
	float = true,
	size = res.as_array(sizes.fifty),
})

hl.window_rule({
	name = "btm-usage-monitor",
	match = {
		class = "com.mitchellh.ghostty",
		title = "btm-monitor",
		initial_title = "btm-monitor",
	},
	workspace = "special:btm silent",
	center = true,
	float = true,
	fullscreen = false,
	size = res.as_array(sizes.fifty),
})

hl.window_rule({
	name = "file-roller",
	match = { class = "org.gnome.FileRoller" },
	center = true,
	float = true,
	size = res.as_array(sizes.fifty),
})

hl.window_rule({
	name = "nm-connection",
	match = { class = "nm-connection-editor" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "pavucontrol",
	match = { class = "org.pulseaudio.pavucontrol" },
	center = true,
	float = true,
	size = res.as_array(sizes.fifty),
})

hl.window_rule({
	name = "jetbrains",
	match = { class = "^(jetbrains-.*)$" },
	no_initial_focus = true,
})

hl.window_rule({
	name = "blueman",
	match = { class = "blueman-sendto", title = "Bluetooth File Transfer|Select files to send" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "betterdiscord",
	match = { class = "Betterdiscord-installer" },
	center = true,
	float = true,
})

-- ========================
-- ==== NAUTILUS RULES ====
-- ========================

hl.window_rule({
	name = "nautilus-popup",
	match = { class = "org.gnome.Nautilus" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "nautilus-main-window",
	match = { class = "org.gnome.Nautilus", initial_title = "Loading…" },
	float = false,
})

-- =========================
-- ==== GNOME APP RULES ====
-- =========================

hl.window_rule({
	name = "loupe",
	match = { class = "org.gnome.Loupe" },
	center = true,
	float = true,
	size = res.as_array(sizes.sixtysix),
})

hl.window_rule({
	name = "amberol",
	match = { class = "io.bassi.Amberol" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "showtime",
	match = { class = "org.gnome.Showtime" },
	center = true,
	float = true,
	size = res.as_array(sizes.sixtysix),
})

hl.window_rule({
	name = "calc",
	match = { class = "org.gnome.Calculator" },
	center = true,
	float = true,
	size = { "480", "600" },
})

hl.window_rule({
	name = "valuta",
	match = { class = "io.github.idevecore.Valuta" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "resources",
	match = { class = "net.nokyan.Resources" },
	center = true,
	float = true,
	size = { "1024", "768" },
})

hl.window_rule({
	name = "nautilus-previewer",
	match = { class = "org.gnome.NautilusPreviewer" },
	center = true,
	float = true,
})

-- ======================
-- ==== LUTRIS RULES ====
-- ======================

hl.window_rule({
	name = "lutris-logs",
	match = { class = "net.lutris.Lutris" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "lutris-main-window",
	match = { class = "net.lutris.Lutris", title = "Lutris" },
	float = false,
})

hl.window_rule({
	name = "epic-ui-popup",
	match = { class = "epicgameslauncher.exe" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "epic-main-window",
	match = { class = "epicgameslauncher.exe", title = "Epic Games Launcher" },
	workspace = 5,
	float = false,
})

-- =======================
-- ==== DISCORD RULES ====
-- =======================

hl.window_rule({
	name = "discord",
	match = { class = "discord" },
	workspace = "special:discord silent",
	focus_on_activate = false,
	center = true,
	float = true,
	size = res.as_array(sizes.seventyfive),
})

hl.window_rule({
	name = "discord-ui-popup",
	match = { class = "Discord" },
	workspace = "special:discord silent",
	center = true,
	float = true,
})

-- =======================
-- ===== BRAVE RULES =====
-- =======================

hl.window_rule({
	name = "brave-main-window",
	match = { class = "brave-browser" },
	float = false,
})

hl.window_rule({
	name = "brave-sign-in-popup",
	match = { class = "brave-browser", initial_title = "Untitled.*" },
	center = true,
	float = true,
})

-- ==========================
-- ===== STEAM UI RULES =====
-- ==========================

hl.window_rule({
	name = "steam-ui-popup",
	match = { class = "steam|Steam" },
	workspace = "3 silent",
	focus_on_activate = false,
	center = true,
	float = true,
})

hl.window_rule({
	name = "steam-menus",
	match = { class = "steam", title = "^$" },
	center = false,
})

hl.window_rule({
	name = "steam-main-window",
	match = { class = "steam", title = "Steam" },
	workspace = "3 silent",
	focus_on_activate = false,
	float = false,
})

hl.window_rule({
	name = "steam-friends-list",
	match = { class = "steam", title = "Friends List" },
	no_screen_share = true,
	center = true,
	float = true,
	size = { "280", "640" },
})

hl.window_rule({
	name = "proton",
	match = { class = "steam_proton", initial_class = "steam_proton" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "",
	match = { class = "steam", title = "Steam Settings" },
	no_screen_share = true,
})
