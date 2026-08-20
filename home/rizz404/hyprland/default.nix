{ pkgs, osConfig, ... }:
let
  isOffice = osConfig.networking.hostName == "dell-slim-ecs1250-office";
  hostConf = if isOffice then ./office.conf else ./personal.conf;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = null; # paket sudah disediakan system-wide lewat modules/desktop/hyprland.nix
    extraConfig = builtins.readFile ./common.conf + "\n" + builtins.readFile hostConf;
  };

  xdg.portal.config.common.default = "*";
}
