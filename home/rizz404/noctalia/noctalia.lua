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
        gaps_in = 5,
        gaps_out = 10
    },
    decoration = {
        rounding = 20,
        rounding_power = 2,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            vibrancy = 0.1696
        }
    }
})

-- * Keybindings lebih bervariasi jadi gak usah pakai variable
local ipc = "noctalia msg "

hl.bind("ALT + Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind("SUPER + N", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind("SUPER + comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind("SUPER + L", hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))
hl.bind("Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd(ipc .. "screenshot-annotate"))
hl.bind("SUPER + V", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))

hl.window_rule({
    match = {
        class = "dev.noctalia.Noctalia"
    },
    float = true,
    size = {1080, 920}
})

hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$"
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true
})
