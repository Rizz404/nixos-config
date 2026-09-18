-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- * Harusnya gak usah dijelasin env itu apa, beberapa juga self explanatory
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- CATATAN SOAL SCALING XWAYLAND (baca modules/misc.lua buat konteks
-- force_zero_scaling): sempat dicoba GDK_SCALE/QT_SCALE_FACTOR=2 di sini
-- buat kompensasi ukuran, tapi DIBUANG lagi setelah dites langsung:
--   - `xrandr --query` nunjukin XWayland tetap lapor resolusi 1280x720
--     (bukan 1920x1080 fisik) ke app walau force_zero_scaling aktif — jadi
--     app yang auto-detect scale dari situ (Qt, via mm fisik ÷ resolusi ini)
--     tetap dapet angka kekecilan (~1.09x, bukan 1.5x).
--   - QT_SCALE_FACTOR manual "nutupin" ukurannya, TAPI ini post-render
--     stretch kasar (didokumentasikan di Qt sendiri), bukan native re-render
--     — kanvas dokumen ONLYOFFICE (dirender CEF, bukan Qt widget biasa)
--     jadi keliatan blur lagi walau ukurannya udah bener.
--   - GDK_SCALE gak kepakai app manapun yang beneran GTK-XWayland di sistem
--     ini, jadi gak ada gunanya juga dipertahanin.
-- Fix yang beneran kepake taruh di Xft.dpi (lihat modules/autostart.lua) —
-- itu yang kebukti bikin Steam (CEF) pas ukuran + tajam tanpa env var Qt di
-- atas. ONLYOFFICE spesifik masih belum ketemu fix yang bersih (env var Qt
-- selalu ujungnya trade-off ukuran vs blur di kanvas dokumennya) — untuk
-- sementara pakai fitur Zoom bawaan ONLYOFFICE (pojok kanan bawah) buat
-- kanvas dokumennya, itu native re-render jadi tetep tajam di zoom berapa
-- pun.

-- * Biar bisa open with di dolphin jadi buat manual
hl.env("XDG_MENU_PREFIX", "hyprland-")

-- * Tanpa ini, app KDE (Dolphin dkk) gak load plugin KDEPlasmaPlatformTheme6,
--   jadi gak masuk jalur yang baca AccentColor/ColorScheme buat recolor icon dinamis
-- * Dicomment sementara (2026-09-16): diduga jadi penyebab UI dialog extract
--   Dolphin/Ark ke-corrupt (Options panel numpuk, tombol Extract gak kepencet).
--   Plugin KDEPlasmaPlatformTheme6 diduga punya popup-repaint bug di Hyprland.
--   Test: uncomment lagi kalau home-manager switch abis ini bug-nya ilang.
-- hl.env("QT_QPA_PLATFORMTHEME", "kde6")
