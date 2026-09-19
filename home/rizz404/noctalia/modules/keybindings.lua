-- * Keybindings lebih bervariasi jadi gak usah pakai variable
local ipc = "noctalia msg "

hl.bind("ALT + Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind("SUPER + Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind("SUPER + N", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind("SUPER + comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind("SUPER + L", hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))
hl.bind("Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd(ipc .. "screenshot-annotate"))
hl.bind("SUPER + V", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
hl.bind("SUPER + W", hl.dsp.exec_cmd(ipc .. "wallpaper-next"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(ipc .. "wallpaper-previous"))
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd(ipc .. "wallpaper-random"))
hl.bind("SUPER + CTRL + W",
    hl.dsp.exec_cmd([[sh -c 'noctalia msg notification-show "Wallpaper" "$(noctalia msg wallpaper-get)"']]))
