-- Config integrasi Noctalia <-> Hyprland, disalin dari dokumentasi resmi:
-- https://docs.noctalia.dev/noctalia/compositor-settings/hyprland/
-- https://docs.noctalia.dev/noctalia/ipc/shell/
--
-- File ini di-import SETELAH hyprland.lua (lihat home/rizz404/default.nix),
-- jadi hl.config di bawah ini nimpa nilai general/decoration dari
-- hyprland.lua buat yang key-nya sama.

hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
end)

-- Noctalia merekomendasikan gap lebih kecil & rounding lebih besar
-- daripada default polos Hyprland biar cocok sama tampilan bar/panel-nya.
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
    },
    decoration = {
        rounding       = 20,
        rounding_power = 2,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 2,
            vibrancy = 0.1696,
        },
    },
})

local mainMod = "SUPER"
local ipc = "noctalia msg "

hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))

-- Default resmi Noctalia buat control-center itu SUPER+S, tapi combo itu
-- udah dipakai hyprland.lua buat toggle scratchpad "magic". Hyprland gak
-- nimpa bind lama kalau ada bind baru di combo yang sama — dua-duanya
-- bakal kejalanin bareng kalau ditekan. Makanya di sini dipindah ke
-- SUPER+N biar gak dobel aksi.
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"))

hl.window_rule({
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size = { 1080, 920 },
})

hl.layer_rule({
    name = "noctalia",
    match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})
