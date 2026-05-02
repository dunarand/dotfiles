local k = require("keybinds.keys")
local modb = k.modb
local ipc = k.ipc

-- =============================
-- ==== Utilities / Scripts ====
-- =============================

hl.bind(modb .. "SHIFT + c", hl.dsp.exec_cmd("hyprpicker"), { description = "Color Picker" })
hl.bind(
	modb .. "a",
	hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/cycle-sinks.sh"),
	{ description = "Cycle Audio Output Device" }
)
hl.bind(
	modb .. "SHIFT + a",
	hl.dsp.exec_cmd("~/.config/easyeffects/scripts/preset-cycle.sh"),
	{ description = "Cycle Audio Profile" }
)

-- ===============================================

hl.bind(
	modb .. "w",
	hl.dsp.exec_cmd(ipc .. "wallpaper toggle"),
	{ description = "Toggle Wallpaper Selector" }
)
hl.bind(
	modb .. "SHIFT + v",
	hl.dsp.exec_cmd(ipc .. "plugin:clipper toggle"),
	{ description = "Toggle Clipboard History" }
)
hl.bind(
	modb .. "CTRL + d",
	hl.dsp.exec_cmd(ipc .. "controlCenter toggle"),
	{ description = "Toggle Dashboard" }
)
hl.bind(
	modb .. "CTRL + s",
	hl.dsp.exec_cmd(ipc .. "plugin:screen-toolkit toggle"),
	{ description = "Toggle Screen Utilities" }
)
hl.bind(
	modb .. "CTRL + a",
	hl.dsp.exec_cmd(ipc .. "volume togglePanel"),
	{ description = "Toggle Audio Control" }
)
hl.bind(
	modb .. "CTRL + m",
	hl.dsp.exec_cmd(ipc .. "media toggle"),
	{ description = "Toggle Music Control" }
)
hl.bind(
	modb .. "CTRL + b",
	hl.dsp.exec_cmd(ipc .. "bluetooth togglePanel"),
	{ description = "Toggle Bluetooth Control" }
)
hl.bind(
	modb .. "CTRL + n",
	hl.dsp.exec_cmd(ipc .. "network togglePanel"),
	{ description = "Toggle Network Control" }
)
hl.bind(
	modb .. "CTRL + p",
	hl.dsp.exec_cmd(ipc .. "plugin:mimeapp-gui openPanel"),
	{ description = "Toggle Mimeapps GUI" }
)

-- ==================================
-- ==== Screenshots & Recordings ====
-- ==================================

hl.bind(
	modb .. "SHIFT + s",
	hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/screenshot-mode.sh"),
	{ description = "Area Screenshot" }
)
hl.bind(
	"SHIFT + f9",
	hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }),
	{ description = "Start/Stop OBS Recording" }
)
hl.bind(
	"SHIFT + f10",
	hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }),
	{ description = "Pause/Resume OBS Recording" }
)
