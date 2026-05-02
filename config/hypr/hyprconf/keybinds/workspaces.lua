local k = require("keybinds.keys")
local modb = k.modb

-- ====================
-- ==== Workspaces ====
-- ====================

for i = 1, 10 do
	local key = i % 10
	hl.bind(modb .. key, hl.dsp.focus({ workspace = i }), { description = "Workspace " .. i })
	hl.bind(
		modb .. "SHIFT + " .. key,
		hl.dsp.window.move({ workspace = i }),
		{ description = "Move Window to Workspace " .. i }
	)
end

hl.bind(
	modb .. "ALT + right",
	hl.dsp.focus({ workspace = "e+1" }),
	{ description = "Next Workspace" }
)
hl.bind(
	modb .. "ALT + left",
	hl.dsp.focus({ workspace = "e-1" }),
	{ description = "Previous Workspace" }
)
hl.bind(
	modb .. "CTRL + right",
	hl.dsp.window.move({ workspace = "e+1" }),
	{ description = "Move Window to Next Workspace" }
)
hl.bind(
	modb .. "CTRL + left",
	hl.dsp.window.move({ workspace = "e-1" }),
	{ description = "Move Window to Previous Workspace" }
)

-- ============================
-- ==== Special Workspaces ====
-- ============================

hl.bind(
	modb .. "m",
	hl.dsp.workspace.toggle_special("overlay"),
	{ description = "Toggle Overlay Special" }
)
hl.bind(
	modb .. "ALT + m",
	hl.dsp.window.move({ workspace = "e+0" }),
	{ description = "Move from Overlay Workspace" }
)
hl.bind(
	modb .. "SHIFT + m",
	hl.dsp.window.move({ workspace = "special:overlay" }),
	{ description = "Move to Overlay Workspace" }
)

-- ===============================================

hl.bind(
	modb .. "z",
	hl.dsp.workspace.toggle_special("minimized"),
	{ description = "Toggle Minimized Workspace" }
)
hl.bind(
	modb .. "SHIFT + z",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/minimize.sh"),
	{ description = "Toggle Window Minimized State" }
)

-- ===============================================

hl.bind(modb .. "s", hl.dsp.workspace.toggle_special("spotify"), { description = "Toggle Spotify" })
hl.bind(modb .. "o", hl.dsp.workspace.toggle_special("obs"), { description = "Toggle OBS" })
hl.bind(modb .. "d", hl.dsp.workspace.toggle_special("discord"), { description = "Toggle Discord" })
hl.bind(
	modb .. "SHIFT + e",
	hl.dsp.workspace.toggle_special("easyeffects"),
	{ description = "Toggle EasyEffects" }
)

-- ===============================================

hl.bind(
	modb .. "grave",
	hl.dsp.workspace.toggle_special("btm"),
	{ description = "Toggle btm System Monitor (Hold Key)" }
)
hl.bind(modb .. "grave", hl.dsp.workspace.toggle_special("btm"), { release = true })
