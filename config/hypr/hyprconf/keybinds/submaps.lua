local defaultPrograms = require("defaults")

local rf = require("utils.resize-float")
local tf = require("utils.toggle-float")

local k = require("keybinds.keys")
local modb = k.modb

-- ===============================================

hl.bind(modb .. "SHIFT + d", hl.dsp.submap("disabled"), { description = "Disable Keybinds Toggle" })
hl.define_submap("disabled", function()
	hl.bind("escape", hl.dsp.submap("reset"))
	hl.bind("CTRL + c", hl.dsp.submap("reset"))
end)

-- =====================================
-- ==== Application Launcher Submap ====
-- =====================================

hl.bind(modb .. "ALT + space", hl.dsp.submap("apps"), { description = "Enter App Launcher Mode" })
hl.define_submap("apps", "reset", function()
	hl.bind("t", hl.dsp.exec_cmd(defaultPrograms.terminal))
	hl.bind("e", hl.dsp.exec_cmd(defaultPrograms.fileManager))
	hl.bind("b", hl.dsp.exec_cmd(defaultPrograms.browser))
	hl.bind("n", hl.dsp.exec_cmd(defaultPrograms.editor))
	hl.bind("c", hl.dsp.exec_cmd(defaultPrograms.calculator))
	hl.bind("v", hl.dsp.exec_cmd(defaultPrograms.videoPlayer))
	hl.bind("m", hl.dsp.exec_cmd(defaultPrograms.musicPlayer))
	hl.bind("i", hl.dsp.exec_cmd(defaultPrograms.imageViewer))
	hl.bind("r", hl.dsp.exec_cmd(defaultPrograms.resourceMon))
	hl.bind("escape", hl.dsp.submap("reset"))
	hl.bind("CTRL + c", hl.dsp.submap("reset"))
end)

-- =======================
-- ==== GOATed Submap ====
-- =======================

hl.bind(modb .. "SHIFT + r", function()
	hl.dsp.submap("resize")() -- no more hl.config here
end, { description = "Enter Resize Mode" })

local function exit_resize()
	hl.dsp.submap("reset")() -- no more hl.config here either
end

hl.define_submap("resize", function()
	hl.bind("right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
	hl.bind("left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
	hl.bind("up", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
	hl.bind("down", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
	hl.bind(
		"SHIFT + right",
		hl.dsp.window.move({ x = 10, y = 0, relative = true }),
		{ repeating = true }
	)
	hl.bind(
		"SHIFT + left",
		hl.dsp.window.move({ x = -10, y = 0, relative = true }),
		{ repeating = true }
	)
	hl.bind(
		"SHIFT + up",
		hl.dsp.window.move({ x = 0, y = -10, relative = true }),
		{ repeating = true }
	)
	hl.bind(
		"SHIFT + down",
		hl.dsp.window.move({ x = 0, y = 10, relative = true }),
		{ repeating = true }
	)

	hl.bind("f", hl.dsp.window.fullscreen({ mode = "maximized" }))
	hl.bind("SHIFT + f", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
	hl.bind("CTRL + f", tf.toggle_float)
	hl.bind("c", hl.dsp.window.center())
	hl.bind("x", hl.dsp.window.close())
	hl.bind("SHIFT + x", hl.dsp.window.kill())
	hl.bind("p", hl.dsp.window.pin())
	hl.bind("r", rf.resize_float)

	hl.bind("CTRL + 1", hl.dsp.window.resize({ x = 10, y = 10 }))
	hl.bind("CTRL + 2", hl.dsp.window.resize({ x = 20, y = 20 }))
	hl.bind("CTRL + 3", hl.dsp.window.resize({ x = 30, y = 30 }))
	hl.bind("CTRL + 4", hl.dsp.window.resize({ x = 40, y = 40 }))
	hl.bind("CTRL + 5", hl.dsp.window.resize({ x = 50, y = 50 }))
	hl.bind("CTRL + 6", hl.dsp.window.resize({ x = 60, y = 60 }))
	hl.bind("CTRL + 7", hl.dsp.window.resize({ x = 70, y = 70 }))
	hl.bind("CTRL + 8", hl.dsp.window.resize({ x = 80, y = 80 }))
	hl.bind("CTRL + 9", hl.dsp.window.resize({ x = 90, y = 90 }))

	for i = 1, 10 do
		local key = tostring(i % 10)
		hl.bind(key, hl.dsp.focus({ workspace = i }))
		hl.bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	end

	hl.bind("h", hl.dsp.focus({ direction = "left" }))
	hl.bind("l", hl.dsp.focus({ direction = "right" }))
	hl.bind("k", hl.dsp.focus({ direction = "up" }))
	hl.bind("j", hl.dsp.focus({ direction = "down" }))
	hl.bind("SHIFT + h", hl.dsp.window.move({ direction = "left" }))
	hl.bind("SHIFT + l", hl.dsp.window.move({ direction = "right" }))
	hl.bind("SHIFT + k", hl.dsp.window.move({ direction = "up" }))
	hl.bind("SHIFT + j", hl.dsp.window.move({ direction = "down" }))
	hl.bind("tab", hl.dsp.window.cycle_next())

	hl.bind("escape", exit_resize)
	hl.bind("CTRL + c", exit_resize)
end)
