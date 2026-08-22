{ pkgs, ... }:
{
  imports = [
    ./fish
    ./starship
    ./git
    ./wezterm
    ./micro
    ./hyprland
    ./kde
    ./mpv
  ];

  home.stateVersion = "26.05";
}
