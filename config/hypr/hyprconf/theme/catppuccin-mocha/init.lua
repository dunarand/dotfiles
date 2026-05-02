local M = {}

M.colors = require("theme.catppuccin-mocha.colors")
M.looks = require("theme.catppuccin-mocha.looks")

M.looks.apply(M.colors)

return M
