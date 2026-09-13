{ ... }:
{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };
  };

  wayland.windowManager.hyprland.extraConfig = builtins.readFile ./noctalia.lua;
}
