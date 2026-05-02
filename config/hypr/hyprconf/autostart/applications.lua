hl.on("hyprland.start", function()
	hl.exec_cmd("otd-daemon")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("swww-daemon")
	hl.exec_cmd("niri-screen-time -daemon")

	hl.exec_cmd("systemctl --user start localsearch-3.service") -- Required by some GNOME apps

	hl.exec_cmd("hyprctl setcursor volantes_cursors 24")
	hl.exec_cmd("qs -c noctalia-shell")
	hl.exec_cmd("qs -c overview")
	-- hl.exec_cmd("hyprpm reload")

	-- Startup Apps
	hl.exec_cmd("arch-update --tray")
	hl.exec_cmd("sleep 1 && discord")
	hl.exec_cmd("sleep 1 && easyeffects --gapplication-service")
	hl.exec_cmd("sleep 1 && spotify")
	hl.exec_cmd("steam")
	-- hl.exec_cmd('ghostty --class="btm-monitor" --title="btm-monitor" -e btm')
end)
