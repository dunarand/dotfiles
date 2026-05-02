local M = {}

function M.apply(colors)
    local theme_borders = {
        general = {
            col = {
                active_border   = colors.window_active_border,
                inactive_border = colors.inactive_border,
            },
        },
        group = {
            col = {
                border_active          = colors.group_border_active,
                border_inactive        = colors.group_border_inactive,
                border_locked_active   = colors.group_border_locked_active,
                border_locked_inactive = colors.group_border_locked_inactive,
            },
            groupbar = {
                col = {
                    active          = colors.groupbar_active,
                    inactive        = colors.groupbar_inactive,
                    locked_active   = colors.groupbar_locked_active,
                    locked_inactive = colors.groupbar_locked_inactive,
                },
            },
        },
    }

    local resize_borders = {
        general = {
            col = { active_border = colors.resize_border },
        },
        group = {
            col = {
                border_active        = colors.resize_group_border,
                border_locked_active = colors.resize_group_locked_border,
            },
            groupbar = {
                col = {
                    active        = colors.resize_groupbar,
                    locked_active = colors.resize_groupbar_locked,
                },
            },
        },
    }

    hl.config(theme_borders)

    hl.on("keybinds.submap", function(name)
        if name == "resize" then
            hl.config(resize_borders)
        else
            hl.config(theme_borders)
        end
    end)
end

return M
