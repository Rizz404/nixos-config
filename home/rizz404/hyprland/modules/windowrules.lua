--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name = "suppress-maximize-events",
    match = {
        class = ".*"
    },

    suppress_event = "maximize"
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false
    },

    no_focus = true
})

-- Hyprland-run windowrule
hl.window_rule({
    name = "move-hyprland-run",
    match = {
        class = "hyprland-run"
    },

    move = "20 monitor_h-120",
    float = true
})

-- Dialog file picker (Open/Save) dari portal xdg-desktop-portal-gtk/kde.
-- Title-nya selalu "<app/site> wants to open/save" apapun app pemanggilnya
-- (browser, electron, dll) — dipakai buat identifikasi karena class-nya ikut
-- app pemanggil (mis. Brave munculin class "brave", beda dari window utama
-- "brave-browser"), jadi gak bisa diandalkan lintas app.
-- Dialog ini didesain fixed-size oleh GTK; kalau ikut kena "auto-maximize"
-- di bawah, dia dipaksa gede sepenuh layar dan layoutnya berantakan (tombol
-- Open/Cancel bisa ke-push keluar canvas).
hl.window_rule({
    name = "float-file-picker",
    match = {
        title = ".*wants to (open|save).*"
    },
    float = true,
    size = {960, 680}
})

hl.window_rule({
    name = "auto-maximize",
    match = {
        class = "^(?!dev\\.noctalia\\.Noctalia$|hyprland-run$).*$",
        title = "^(?!.*wants to (open|save)).*$"
    },
    maximize = true
})
