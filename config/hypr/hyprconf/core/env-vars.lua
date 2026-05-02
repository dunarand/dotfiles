-- NVIDIA
hl.env("GBM_BACKEND","nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME","nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS","1")
hl.env("__GL_GSYNC_ALLOWED","0")
hl.env("__GL_VRR_ALLOWED","0")
hl.env("LIBVA_DRIVER_NAME","nvidia")

-- Cursors
hl.env("XCURSOR_THEME","volantes_cursors")
hl.env("XCURSOR_SIZE","24")
hl.env("HYPRCURSOR_SIZE","24")

-- Qt
hl.env("QT_QPA_PLATFORM","wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME","qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION","1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR","1")

-- GTK / SDL / Clutter
hl.env("GDK_BACKEND","wayland,x11")
hl.env("SDL_VIDEODRIVER","wayland")
hl.env("CLUTTER_BACKEND","wayland")
hl.env("GDK_SCALE","1")
hl.env("GDK_DPI_SCALE","1")

-- XDG session info
hl.env("XDG_CURRENT_DESKTOP","Hyprland")
hl.env("XDG_SESSION_TYPE","wayland")
hl.env("XDG_SESSION_DESKTOP","Hyprland")
hl.env("XDG_MENU_PREFIX","arch-")

-- Performance
hl.env("PROTON_ENABLE_NVAPI","1")
hl.env("DXVK_STATE_CACHE","1")
