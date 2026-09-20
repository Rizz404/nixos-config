---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
            -- * Default libinput "lrm" bikin tap 3 jari = klik tengah = paste
            --   primary selection. Kepencet gak sengaja pas swipe 3 jari
            --   workspace kecepetan/kependekan (jatuh ke tap-detection,
            --   bukan gesture). "lmr" bikin tap 3 jari jadi klik kanan --
            --   masih ada efeknya, tapi gak nyisipin teks nyasar kayak paste.
            tap_button_map = "lmr"
        }
    },

    -- * Default 300px kerasa kejauhan buat trackpad kecil -- harus geser
    --   hampir sepanjang trackpad baru workspace-nya pindah. Diturunin biar
    --   lebih "sat set" (snappier), gak perlu swipe penuh.
    gestures = {
        workspace_swipe_distance = 150
    }
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})
