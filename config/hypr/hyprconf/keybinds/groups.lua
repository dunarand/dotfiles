local k = require("keybinds.keys")
local modb = k.modb

-- =======================
-- ==== Group Actions ====
-- =======================

hl.bind(modb .. "g", hl.dsp.group.toggle(), { description = "Toggle Group" })
hl.bind(
	modb .. "SHIFT + g",
	hl.dsp.group.lock_active({ action = "toggle" }),
	{ description = "Lock Active Group" }
)
hl.bind(
	modb .. "CTRL + g",
	hl.dsp.window.move({ out_of_group = true }),
	{ description = "Move Window Out of Group" }
)
hl.bind(
	modb .. "ALT + g",
	hl.dsp.window.deny_from_group({ action = "toggle" }),
	{ description = "Toggle Window to Ignore Grouping" }
)

-- ===============================================

hl.bind(
	modb .. "CTRL + h",
	hl.dsp.window.move({ into_group = true, direction = "left" }),
	{ description = "Move Window into Group" }
)
hl.bind(
	modb .. "CTRL + j",
	hl.dsp.window.move({ into_group = true, direction = "down" }),
	{ description = "Move Window into Group" }
)
hl.bind(
	modb .. "CTRL + k",
	hl.dsp.window.move({ into_group = true, direction = "up" }),
	{ description = "Move Window into Group" }
)
hl.bind(
	modb .. "CTRL + l",
	hl.dsp.window.move({ into_group = true, direction = "right" }),
	{ description = "Move Window into Group" }
)

-- ===============================================

hl.bind("ALT + tab", hl.dsp.group.next(), { description = "Focus Forward in Group" })
hl.bind("CTRL + tab", hl.dsp.group.prev(), { description = "Focus Back in Group" })
hl.bind(
	"SHIFT + ALT + tab",
	hl.dsp.group.move_window({ forward = true }),
	{ description = "Move Window Forward in Group" }
)
hl.bind(
	"SHIFT + CTRL + tab",
	hl.dsp.group.move_window({ forward = false }),
	{ description = "Move Window Back in Group" }
)
