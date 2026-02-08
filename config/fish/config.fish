source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

set -x XCURSOR_THEME "volantes_cursors"
set -x XCURSOR_SIZE 24

export XCURSOR_THEME=volantes_cursors
export XCURSOR_SIZE=24
export GDK_SCALE=1
export GDK_DPI_SCALE=1

export QT_XCB_CURSOR_THEME=volantes_cursors
export QT_XCB_CURSOR_SIZE=24


zoxide init fish | source
