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
