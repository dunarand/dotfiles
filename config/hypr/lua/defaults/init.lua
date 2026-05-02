local M = {}

M.terminal    = "ghostty"
M.termexec    = "ghostty -e "
M.fileManager = "nautilus"
M.browser     = "brave"
M.editor      = "ghostty -e nvim"
M.music       = "spotify"
M.calculator  = "gnome-calculator"
M.currencyConv = "valuta"
M.musicPlayer = "amberol"
M.imageViewer = "loupe"
M.videoPlayer = "showtime"
M.resourceMon = "resources"

function M.in_terminal(cmd)
    return M.termexec .. cmd
end

return M
