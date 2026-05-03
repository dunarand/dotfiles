-- Game Mode
--
-- Once a window is fully initiated with a "game" tag, this module will make
-- some optimizations to make the game run better. These include closing some
-- background processes, changing power profiles, etc.

local function start_game_mode()
	hl.dsp.exec_cmd("powerprofilesctl set performance")
	hl.notification.create({ text = "Game mode initiated", timeout = 3000, icon = "info" })
end

local function end_game_mode()
	hl.dsp.exec_cmd("powerprofilesctl set balanced")
	hl.notification.create({ text = "Game mode ended", timeout = 3000, icon = "info" })
end

local game_count = 0

hl.on("window.open", function(w)
	if w.content_type == "game" then
		game_count = game_count + 1
		if game_count == 1 then
			start_game_mode()
		end
	end
end)

hl.on("window.close", function(w)
	if w.content_type == "game" then
		game_count = game_count - 1
		if game_count == 0 then
			end_game_mode()
		end
	end
end)
