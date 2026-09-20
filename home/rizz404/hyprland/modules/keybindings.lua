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

-- Toggle window fokus antara floating <-> tiling
-- * Window yang di-toggle jadi floating otomatis di-resize ke ukuran wajar
--   (900x600) + di-center, bukan ngewarisin ukuran tiled-nya yang sering
--   nyaris fullscreen (auto-maximize) -- biar kalau ada beberapa window
--   di-float bareng gak langsung numpuk penuh nutupin layar
hl.bind("SUPER + SHIFT + SPACE", function()
    hl.dispatch(hl.dsp.window.float({
        action = "toggle"
    }))
    local win = hl.get_active_window()
    if win and win.floating then
        hl.dispatch(hl.dsp.window.resize({
            x = 900,
            y = 600
        }))
        hl.dispatch(hl.dsp.window.center())
    end
end)

-- Move focus with SUPER + arrow keys
-- * smart-focus.sh: fokus terarah bawaan Hyprland gak nyebrang antara
--   window tiling & floating (dua domain terpisah, gak ada config buat
--   nyatuin) -- script ini coba fokus arah biasa dulu, baru fallback nyari
--   window terdekat di domain sebaliknya kalau gak ada tetangga di domain
--   yang sama
hl.bind("SUPER + left", hl.dsp.exec_cmd("~/.config/hypr/smart-focus.sh left"))
hl.bind("SUPER + right", hl.dsp.exec_cmd("~/.config/hypr/smart-focus.sh right"))
hl.bind("SUPER + up", hl.dsp.exec_cmd("~/.config/hypr/smart-focus.sh up"))
hl.bind("SUPER + down", hl.dsp.exec_cmd("~/.config/hypr/smart-focus.sh down"))

-- Resize focused window with SUPER + SHIFT + arrow keys
-- * Cuma kerasa efeknya kalau ada window lain buat di-resize bareng di
--   workspace yang sama (window tunggal yang udah fullscreen/maximize gak
--   punya boundary buat digeser)
-- * relative = true wajib ada -- tanpa itu x/y dibaca sebagai ukuran
--   absolut (window bisa error "Invalid size" kalau x/y ke-set 0), bukan
--   delta pixel kayak resizeactive classic
local resize_step = 40
hl.bind("SUPER + SHIFT + left", hl.dsp.window.resize({
    x = -resize_step,
    y = 0,
    relative = true
}), {
    repeating = true
})
hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize({
    x = resize_step,
    y = 0,
    relative = true
}), {
    repeating = true
})
hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({
    x = 0,
    y = -resize_step,
    relative = true
}), {
    repeating = true
})
hl.bind("SUPER + SHIFT + down", hl.dsp.window.resize({
    x = 0,
    y = resize_step,
    relative = true
}), {
    repeating = true
})

-- Tukar posisi window fokus dengan window di arah panah, SUPER + ALT + arrow
-- * direction pakai kata penuh ("left"/"right"/dst), bukan singkatan l/r/u/d
--   kayak classic swapwindow -- singkatan bikin dispatcher gak nemu window
--   tetangganya sama sekali
-- * Cuma kerasa efeknya kalau ada 2+ window tiled di workspace yang sama
hl.bind("SUPER + ALT + left", hl.dsp.window.swap({
    direction = "left"
}))
hl.bind("SUPER + ALT + right", hl.dsp.window.swap({
    direction = "right"
}))
hl.bind("SUPER + ALT + up", hl.dsp.window.swap({
    direction = "up"
}))
hl.bind("SUPER + ALT + down", hl.dsp.window.swap({
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

-- * Rapetin workspace 1-10: tutup celah kosong
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("~/.config/hypr/compact-workspaces.sh"))

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

-- * Live-resize gaps tanpa reload config
local default_gaps_out = tonumber(hl.get_config("general.gaps_out")) or 8
local default_gaps_in = tonumber(hl.get_config("general.gaps_in")) or 4

local function resize_gaps(step)
    return function()
        local gaps_out = tonumber(hl.get_config("general.gaps_out")) or default_gaps_out
        local gaps_in = tonumber(hl.get_config("general.gaps_in")) or default_gaps_in
        hl.config({
            general = {
                gaps_out = math.max(0, math.floor(gaps_out + step)),
                gaps_in = math.max(0, math.floor(gaps_in + step / 2))
            }
        })
    end
end

hl.bind("CTRL + SUPER + equal", resize_gaps(4))
hl.bind("CTRL + SUPER + minus", resize_gaps(-4))
hl.bind("CTRL + SUPER + G", function()
    hl.config({
        general = {
            gaps_out = default_gaps_out,
            gaps_in = default_gaps_in
        }
    })
end)

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
