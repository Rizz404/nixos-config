{ pkgs, ... }:
{
  imports = [
    ./fish
    ./starship
    ./git
    ./wezterm
    ./micro
    ./hyprland
    ./noctalia
    ./kde
    ./mpv
    ./udiskie
  ];

  home.stateVersion = "26.05";
}
