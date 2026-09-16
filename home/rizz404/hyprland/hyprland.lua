-- Entry point config Hyprland (Lua). Tiap section dipecah ke modules/,
-- di-import di sini pakai require(), lihat https://wiki.hypr.land/Configuring/Start/
-- Path modul di-symlink oleh home-manager (lihat default.nix -> xdg.configFile),
-- rooted di ~/.config/hypr, jadi "modules.hyprland.xxx" -> modules/hyprland/xxx.lua
require("modules.hyprland.monitors")
require("modules.hyprland.autostart")
require("modules.hyprland.environment")
require("modules.hyprland.permissions")
require("modules.hyprland.appearance")
require("modules.hyprland.animations")
require("modules.hyprland.layout")
require("modules.hyprland.misc")
require("modules.hyprland.input")
require("modules.hyprland.keybindings")
require("modules.hyprland.windowrules")
