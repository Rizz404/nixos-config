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
        class = "^(?!dev\\.noctalia\\.Noctalia$|hyprland-run$|org\\.kde\\.dolphin$).*$",
        title = "^(?!.*wants to (open|save)).*$"
    },
    maximize = true
})

-- Dolphin (class org.kde.dolphin) sering ke-trigger buka bukan cuma dari
-- SUPER+E manual, tapi juga dari app lain lewat aksi "show in file
-- manager"/"open containing folder" (mis. dari Brave downloads, qBittorrent,
-- AB Download Manager) yang shell out ke dolphin. Kalau instance itu kena
-- "auto-maximize" di atas, window-nya kadang ngebug parah (gagal ke-render/
-- gak bisa kebuka sama sekali) — diduga terkait bug repaint yang sama yang
-- disebut di modules/hyprland/environment.lua soal Qt KDEPlasmaPlatformTheme6
-- di Hyprland. Tetap excluded dari auto-maximize di atas apapun trigger-nya.
--
-- Float paksa buat instance yang ke-trigger dari app lain sekarang ditangani
-- float-if-external.sh (reaktif, berdasar parent process) alih-alih static
-- rule di sini, supaya Dolphin yang dibuka langsung (SUPER+E) tetap tiling
-- normal. Kalau bug render di atas balik lagi khusus buat trigger eksternal
-- (kemungkinan karena static rule di-apply sebelum render pertama, sedangkan
-- script reaktif baru float SETELAH window sempat ke-tile), rule statis ini
-- perlu ditambah lagi sebagai fallback.

-- Sebagian app render window-nya ke buffer ARGB yang punya alpha channel di
-- hampir semua piksel (antialiasing teks, rounded corner, shadow client-side)
-- walau window-nya niatnya opaque penuh. decoration.blur.enabled global di
-- appearance.lua nge-blur berdasarkan alpha AKTUAL di buffer, bukan niat
-- app-nya, jadi seluruh window keliatan "berkabut"/hazy alih-alih cuma
-- background-nya. KDE Plasma gak kena karena KWin cuma blur region yang
-- di-hint eksplisit lewat _KDE_NET_WM_BLUR_BEHIND_REGION, dan app-app ini
-- gak set hint itu. Class dikonfirmasi langsung lewat `hyprctl clients -j`
-- (bukan cuma nebak dari desktop file), kecuali chromium-browser yang
-- disamakan pola-nya dengan brave-browser (codebase sama, StartupWMClass
-- terverifikasi cocok 1:1 antara live class Brave vs desktop file-nya).
--
-- Terkonfirmasi kena (CEF/Chromium, Flutter, atau Compose Desktop — semua
-- ini dikenal alokasi surface ARGB penuh di Linux Wayland):
--   - steam, ONLYOFFICE (CEF, sumber laporan awal)
--   - brave-browser, chromium-browser, code (VS Code), itch — Chromium/CEF
--   - rustdesk — Flutter (linux embedder-nya juga selalu pakai ARGB surface)
--   - com-abdownloadmanager-desktop-AppKt — Kotlin Compose Desktop (Skiko)
--   - org.telegram.desktop — Qt tapi window/shadow-nya digambar sendiri
--     (custom CSD), isu "TelegramDesktop blurry" ini umum dilaporkan di
--     Hyprland. Sengaja TIDAK termasuk: qBittorrent (Qt Widgets standar
--     tanpa custom shadow/rounding, kemungkinan gak kena — belum ada bukti).
for _, entry in ipairs({
    { name = "steam", class = "steam" },
    { name = "onlyoffice", class = "ONLYOFFICE" },
    { name = "brave", class = "brave-browser" },
    { name = "chromium", class = "chromium-browser" },
    { name = "vscode", class = "code" },
    { name = "itch", class = "itch" },
    { name = "rustdesk", class = "rustdesk" },
    { name = "ab-download-manager", class = "com-abdownloadmanager-desktop-AppKt" },
    { name = "telegram", class = "org\\.telegram\\.desktop" }
}) do
    hl.window_rule({
        name = "no-blur-" .. entry.name,
        match = {
            class = "^(" .. entry.class .. ")$"
        },
        no_blur = true,
        opaque = true
    })
end
