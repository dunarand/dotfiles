local defaultPrograms = require("defaults")

local cof = require("utils.close-or-unfocus")
local rf = require("utils.resize-float")
local tf = require("utils.toggle-float")
local wr = require("utils.generate-windowrules")

local k = require("keybinds.keys")
local modb = k.modb
local ipc = k.ipc

-- ======================================
-- ==== Session and General Commands ====
-- ======================================

hl.bind(
	modb .. "SHIFT + escape",
	hl.dsp.exec_cmd(ipc .. "sessionMenu toggle"),
	{ locked = true, description = "Toggle Power Menu" }
)
hl.bind(
	modb .. "CTRL + backspace",
	hl.dsp.exec_cmd(ipc .. "lockScreen lock"),
	{ description = "Lock Screen" }
)
hl.bind(
	"CTRL + SHIFT + delete",
	hl.dsp.exec_cmd(
		"command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"
	),
	{ description = "Shutdown Hyprland" }
)
hl.bind(
	"CTRL + SHIFT + f5",
	hl.dsp.exec_cmd("killall qs && qs -c noctalia-shell"),
	{ description = "Restart/Refresh Noctalia Shell" }
)
hl.bind(modb .. "ALT + SHIFT + k", function()
	local current = hl.dsp.exec_cmd([[
    hyprctl devices -j |
        jq -r '.keyboards[] |
        .active_keymap' |
        head -n1 |
        cut -c1-2 |
        tr 'a-z' 'A-Z']])
	if current == "EN" then
		hl.config({ input = { kb_layout = "tr" } })
	else
		hl.config({ input = { kb_layout = "us" } })
	end
end, { locked = true, description = "Switch Keyboard Layout" })
hl.bind("ALT + p", wr.generate_windowrule, { description = "Focused Window Properties" })

-- ===============================================

hl.bind(
	modb .. "f11",
	hl.dsp.exec_cmd("sleep 1 && hyprctl dispatch 'hl.dsp.dpms({action=\"toggle\"})'"),
	{ locked = true, description = "Toggle Screen On/Off" }
)
hl.bind(
	modb .. "f12",
	hl.dsp.exec_cmd("sleep 1 && hyprctl dispatch 'hl.dsp.force_idle(900)"),
	{ locked = true, description = "Sleep" }
)

-- ===============================================

hl.bind(
	modb .. "tab",
	hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"),
	{ description = "Toggle Workspace View" }
)

-- ========================
-- ==== Window Actions ====
-- ========================

hl.bind(modb .. "f", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Maximize" })
hl.bind(
	modb .. "SHIFT + f",
	hl.dsp.window.fullscreen({ mode = "fullscreen" }),
	{ description = "Fullscreen" }
)
hl.bind(modb .. "c", hl.dsp.window.center(), { description = "Center Window" })
hl.bind(modb .. "r", rf.resize_float, { description = "Resize Window" })
hl.bind(modb .. "x", hl.dsp.window.close(), { description = "Close Window" })
hl.bind(modb .. "SHIFT + x", hl.dsp.window.kill(), { description = "Kill Window" })
hl.bind(modb .. "p", hl.dsp.window.pin(), { description = "Pin Window" })
hl.bind(modb .. "CTRL + f", tf.toggle_float, { description = "Toggle Floating Window" })
hl.bind(modb .. "escape", cof.close_or_unfocus, { description = "Close/Unfocus Floating Window" })

-- =======================
-- ==== Program Binds ====
-- =======================

hl.bind(modb .. "t", hl.dsp.exec_cmd(defaultPrograms.terminal), { description = "Terminal" })
hl.bind(modb .. "e", hl.dsp.exec_cmd(defaultPrograms.fileManager), { description = "File Manager" })
hl.bind(modb .. "b", hl.dsp.exec_cmd(defaultPrograms.browser), { description = "Browser" })

-- ===============================================

hl.bind(
	modb .. "CTRL + SHIFT + c",
	hl.dsp.exec_cmd(defaultPrograms.termexec .. "tmux a -t config"),
	{ description = "Hyprland Config" }
)

-- ===================
-- ==== Launchers ====
-- ===================

hl.bind(
	modb .. "SHIFT + space",
	hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/brave-search.sh"),
	{ description = "Web Search" }
)
hl.bind(
	modb .. "f1",
	hl.dsp.exec_cmd(
		'hyprctl dispatch exec "[float; size 1280 720]" '
			.. defaultPrograms.termexec
			.. "fs --float"
	),
	{ description = "File Search" }
)
-- hl.bind(
-- 	modb .. "space",
-- 	hl.dsp.exec_cmd(ipc .. "launcher toggle"),
-- 	{ description = "Application Launcher" }
-- )
hl.bind(
	modb .. "space",
	hl.dsp.exec_cmd("pkill rofi || rofi -show drun"),
	{ description = "Application Launcher" }
)
hl.bind(
	modb .. "SHIFT + tab",
	hl.dsp.exec_cmd(ipc .. "launcher windows"),
	{ description = "Cycle Windows" }
)
hl.bind(
	modb .. "q",
	hl.dsp.exec_cmd("pkill rofi || ~/.config/hypr/scripts/keybinds.sh"),
	{ description = "Keybinds" }
)
hl.bind(
	modb .. "CTRL + space",
	hl.dsp.exec_cmd("pkill rofi || ~/.config/hypr/layout-manager/layout-manager.sh"),
	{ description = "Layout Menu" }
)
hl.bind(
	modb .. "v",
	hl.dsp.exec_cmd(ipc .. "launcher clipboard"),
	{ description = "Clipboard History" }
)

-- ======================
-- ==== Moving focus ====
-- ======================

hl.bind(modb .. "h", hl.dsp.focus({ direction = "left" }), { description = "Focus Left" })
hl.bind(modb .. "l", hl.dsp.focus({ direction = "right" }), { description = "Focus Right" })
hl.bind(modb .. "k", hl.dsp.focus({ direction = "up" }), { description = "Focus Up" })
hl.bind(modb .. "j", hl.dsp.focus({ direction = "down" }), { description = "Focus Down" })

-- ========================
-- ==== Moving windows ====
-- ========================

hl.bind(
	modb .. "SHIFT + h",
	hl.dsp.window.move({ direction = "left" }),
	{ description = "Move Window to Left" }
)
hl.bind(
	modb .. "SHIFT + l",
	hl.dsp.window.move({ direction = "right" }),
	{ description = "Move Window to Right" }
)
hl.bind(
	modb .. "SHIFT + k",
	hl.dsp.window.move({ direction = "up" }),
	{ description = "Move Window to Up" }
)
hl.bind(
	modb .. "SHIFT + j",
	hl.dsp.window.move({ direction = "down" }),
	{ description = "Move Window to Down" }
)

-- ============================
-- ==== Mouse interactions ====
-- ============================

hl.bind(
	modb .. "mouse:272",
	hl.dsp.window.drag(),
	{ mouse = true, description = "Drag to Move Window (Hold)" }
)
hl.bind(
	modb .. "mouse:273",
	hl.dsp.window.resize(),
	{ mouse = true, description = "Resize Window (Hold)" }
)
hl.bind(
	modb .. "CTRL + mouse:273",
	hl.dsp.window.resize(),
	{ mouse = true, description = "Resize Window & Keep Aspect Ratio (Hold)" }
)
hl.bind(modb .. "mouse:274", hl.dsp.window.close(), { description = "Close/Kill Focused Window" })
hl.bind(
	modb .. "SHIFT + mouse:274",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/minimize.sh"),
	{ description = "Toggle Window Minimized State" }
)

-- ===============================================

hl.bind("mouse:btn_side", hl.dsp.exec_cmd("hyprctl dispatch keybind BACK"))
hl.bind("mouse:btn_extra", hl.dsp.exec_cmd("hyprctl dispatch keybind FORWARD"))

-- ===============================================

hl.bind(modb .. "mouse_up", hl.dsp.focus({ workspace = "e+1" }), { description = "Next Workspace" })
hl.bind(
	modb .. "mouse_down",
	hl.dsp.focus({ workspace = "e-1" }),
	{ description = "Previous Workspace" }
)

-- ===============================================

hl.bind(
	modb .. "ALT + mouse:272",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/minimize.sh"),
	{ description = "Minimize Window" }
)
hl.bind(
	modb .. "ALT + mouse:273",
	hl.dsp.window.fullscreen({ mode = "maximized" }),
	{ description = "Fullscreen Toggle" }
)
hl.bind(modb .. "ALT + mouse:274", hl.dsp.window.close(), { description = "Close/Kill Focused" })

-- =====================================
-- ==== Keyboard Special/Extra Keys ====
-- =====================================

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/vol-up.sh"),
	{ locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/vol-down.sh"),
	{ locked = true }
)

hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true }
)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind(modb .. "XF86AudioMute", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind(modb .. "XF86AudioRaiseVolume", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind(modb .. "XF86AudioLowerVolume", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- ===============================================

hl.bind("ALT + right", hl.dsp.send_shortcut({ mods = "", key = "end" }))
hl.bind("ALT + left", hl.dsp.send_shortcut({ mods = "", key = "home" }))
hl.bind("ALT + up", hl.dsp.send_shortcut({ mods = "", key = "page_up" }))
hl.bind("ALT + down", hl.dsp.send_shortcut({ mods = "", key = "page_down" }))
