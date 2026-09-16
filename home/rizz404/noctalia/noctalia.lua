-- Entry point config Noctalia (Lua). Tiap section dipecah ke modules/,
-- di-import di sini pakai require(), lihat https://wiki.hypr.land/Configuring/Start/
-- Path modul di-symlink oleh home-manager (lihat default.nix -> xdg.configFile),
-- rooted di ~/.config/hypr, jadi "modules.noctalia.xxx" -> modules/noctalia/xxx.lua
--
-- * general/decoration (gaps, rounding, blur) SENGAJA gak di-set di sini.
--   Itu semua udah dikontrol penuh dari hyprland/modules/appearance.lua biar
--   cuma ada SATU sumber, gak ada dua file yang rebutan nimpa key yang sama.
require("modules.noctalia.autostart")
require("modules.noctalia.keybindings")
require("modules.noctalia.rules")
require("modules.noctalia.theme")
