{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = null; # paket sudah disediakan system-wide lewat modules/desktop/hyprland.nix
    configType = "lua";
    extraConfig = builtins.readFile ./hyprland.lua;
  };
  xdg.portal.config.common.default = "*";
}
