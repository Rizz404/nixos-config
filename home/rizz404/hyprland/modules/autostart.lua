-------------------
---- AUTOSTART ----
-------------------
-- * Udah ada noctalia gak usah rakit dari awal
-- * Noctalia sendiri sudah di-autostart dari modules/noctalia/autostart.lua, gak perlu diulang di sini

-- * Matiin drkonqi-coredump-launcher.socket pas Hyprland nyala biar gak ngebug crash
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user stop drkonqi-coredump-launcher.socket")
end)

-- * Pinjem kwallet untuk hyprland buat simpen credentials
hl.on("hyprland.start", function()
    hl.exec_cmd("@KWALLET_PAM_INIT@")
end)

-- Monitor scale 1.5 (fractional) + XWayland gak support fractional scaling
-- native (`xrandr --query` selalu lapor 1280x720, bukan 1920x1080 fisik,
-- gak peduli xwayland.force_zero_scaling di modules/hyprland/misc.lua).
-- Xft.dpi = 144 (96 * 1.5) ini yang paling reliable dites langsung: app
-- CEF/GTK yang lewat XWayland (steam, dkk — cek `hyprctl clients -j | grep
-- xwayland`) baca resource ini buat nentuin device scale factor sendiri,
-- hasilnya pas ukuran DAN tajam (beda dari GDK_SCALE/QT_SCALE_FACTOR yang
-- sempat dicoba di modules/hyprland/environment.lua, dibuang lagi karena
-- korbanin ketajaman). Qt (ONLYOFFICE) gak ikut baca resource ini — belum
-- ketemu fix bersihnya, lihat catatan di environment.lua.
hl.on("hyprland.start", function()
    hl.exec_cmd("sh -c 'echo \"Xft.dpi: 144\" | xrdb -merge -'")
end)

-- Float window yang dibuka dari app lain, tile kalau dibuka langsung --
-- lihat komentar di float-if-external.sh
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/float-if-external.sh")
end)
