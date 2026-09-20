-----------------
---- LAYOUT  ----
-----------------
hl.config({
    dwindle = {
        preserve_split = true
    }
})

hl.config({
    master = {
        new_status = "master"
    }
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true
    }
})

-- Matiin auto-merge window ke group pas di-drag (default Hyprland: nge-drop
-- window (termasuk yang floating) ke atas window lain bisa nge-merge-in dia
-- jadi tab/group di window itu -- keliatannya kayak "window floating balik
-- jadi tiling lagi" pas di-drag terus dilepas, padahal itu ke-tab-in ke
-- group). Dikonfirmasi langsung di sesi live: `hyprctl getoption
-- group:drag_into_group` defaultnya 1 (enabled).
hl.config({
    group = {
        drag_into_group = 0
    }
})
