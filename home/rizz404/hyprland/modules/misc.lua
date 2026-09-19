----------------
----  MISC  ----
----------------
-- * Wallpaper Hyprland sendiri gak pernah keliatan (selalu ketutup layer
-- * wallpaper Noctalia, lihat home/rizz404/noctalia/default.nix), tapi
-- * dimatiin eksplisit di sini biar gak ada proses render/load sia-sia dan
-- * gak ada kemungkinan sempet keliatan (mis. pas Noctalia belum start).
hl.config({
    misc = {
        force_default_wallpaper = 0, -- 0 atau 1 = disable anime mascot wallpaper (-1 = random, termasuk mascot)
        disable_hyprland_logo = true -- Disable random hyprland logo / anime girl background
    }
})

-- Monitor kita scale 1.5 (fractional). XWayland gak support fractional
-- scaling secara native, jadi app yang jalan lewat XWayland (steam,
-- ONLYOFFICE, dll — cek `hyprctl clients -j | grep xwayland`) di-render di
-- scale 1x lalu di-upscale bilinear sama Hyprland ke 1.5x, hasilnya teks
-- keliatan soft/blur walau decoration.blur dimatiin sekalipun (sudah
-- dites langsung: matiin decoration.blur.enabled gak ngubah apa-apa, tapi
-- render Steam pakai GDK_SCALE=2 + force_zero_scaling langsung jadi tajam).
-- force_zero_scaling bikin XWayland ngaku scale=1 (dimensi = resolusi fisik
-- monitor, bukan resolusi logical yang udah dibagi 1.5), jadi Hyprland gak
-- perlu upscale sama sekali buat nampilin surface-nya 1:1 piksel.
hl.config({
    xwayland = {
        force_zero_scaling = true
    }
})
