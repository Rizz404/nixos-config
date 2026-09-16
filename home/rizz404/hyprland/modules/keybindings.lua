---------------------
---- KEYBINDINGS ----
---------------------
-- * Keybindings lebih bervariasi jadi gak usah pakai variable
-- * Beberapa udah self explanatory
local programs = require("modules.hyprland.programs")

hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(programs.terminal))
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + M", hl.dsp.exec_cmd("~/.config/hypr/peek-desktop.sh"))
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("~/.config/hypr/peek-desktop.sh"))
hl.bind("SUPER + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind("F11", hl.dsp.window.fullscreen({
    action = "toggle"
}))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({
    action = "toggle"
}))
-- * Kayak WINDOWS + R
hl.bind("SUPER + R", hl.dsp.exec_cmd(programs.menu))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with SUPER + arrow keys
hl.bind("SUPER + left", hl.dsp.focus({
    direction = "left"
}))
hl.bind("SUPER + right", hl.dsp.focus({
    direction = "right"
}))
hl.bind("SUPER + up", hl.dsp.focus({
    direction = "up"
}))
hl.bind("SUPER + down", hl.dsp.focus({
    direction = "down"
}))

hl.bind("CTRL + SUPER + right", hl.dsp.focus({
    workspace = "+1"
}))
hl.bind("CTRL + SUPER + left", hl.dsp.focus({
    workspace = "-1"
}))

for i = 1, 10 do
    local key = i % 10
    hl.bind("CTRL + SUPER + " .. key, hl.dsp.focus({
        workspace = i
    }))
end

-- Switch workspaces with "SUPER" + [0-9]
-- Move active window to a workspace with "SUPER" + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key, hl.dsp.focus({
        workspace = i
    }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({
        workspace = i
    }))
end

-- Example special workspace (scratchpad)
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({
    workspace = "special:magic"
}))

-- Scroll through existing workspaces with "SUPER" + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({
    workspace = "e+1"
}))
hl.bind("SUPER + mouse_up", hl.dsp.focus({
    workspace = "e-1"
}))

-- Move/resize windows with "SUPER" + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), {
    mouse = true
})
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), {
    mouse = true
})

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
    locked = true,
    repeating = true
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), {
    locked = true,
    repeating = true
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), {
    locked = true,
    repeating = true
})

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
    locked = true
})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true
})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
    locked = true
})
