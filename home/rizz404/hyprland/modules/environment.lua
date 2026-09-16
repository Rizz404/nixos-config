-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- * Harusnya gak usah dijelasin env itu apa, beberapa juga self explanatory
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- * Biar bisa open with di dolphin jadi buat manual
hl.env("XDG_MENU_PREFIX", "hyprland-")

-- * Tanpa ini, app KDE (Dolphin dkk) gak load plugin KDEPlasmaPlatformTheme6,
--   jadi gak masuk jalur yang baca AccentColor/ColorScheme buat recolor icon dinamis
hl.env("QT_QPA_PLATFORMTHEME", "kde6")
