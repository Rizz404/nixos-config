{ config, ... }:
let
  idlePowerScript = "${config.home.homeDirectory}/.config/noctalia/idle-power.sh";
in
{
  programs.noctalia = {
    enable = true;
    # * Biar gak bentrok sama plasma, jadi kalo bukan hyprland di disable
    systemd.enable = false;

    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };

      idle = {
        pre_action_fade_seconds = 0;
        behavior = {
          dim-ac = {
            enabled = true;
            timeout = 300; # 5 menit, saat di-charge
            action = "command";
            command = "${idlePowerScript} ac dim start";
            resume_command = "${idlePowerScript} ac dim resume";
          };
          screenoff-ac = {
            enabled = true;
            timeout = 600; # 10 menit, saat di-charge
            action = "command";
            command = "${idlePowerScript} ac screen-off start";
            resume_command = "${idlePowerScript} ac screen-off resume";
          };
          dim-battery = {
            enabled = true;
            timeout = 150; # 2.5 menit, saat pakai baterai
            action = "command";
            command = "${idlePowerScript} battery dim start";
            resume_command = "${idlePowerScript} battery dim resume";
          };
          screenoff-battery = {
            enabled = true;
            timeout = 300; # 5 menit, saat pakai baterai
            action = "command";
            command = "${idlePowerScript} battery screen-off start";
            resume_command = "${idlePowerScript} battery screen-off resume";
          };
        };
      };
    };
  };

  wayland.windowManager.hyprland.extraConfig = builtins.readFile ./noctalia.lua;

  xdg.configFile = {
    "hypr/modules/noctalia/autostart.lua".source = ./modules/autostart.lua;
    "hypr/modules/noctalia/keybindings.lua".source = ./modules/keybindings.lua;
    "hypr/modules/noctalia/rules.lua".source = ./modules/rules.lua;

    "noctalia/idle-power.sh" = {
      source = ./idle-power.sh;
      executable = true;
    };
  };
}
