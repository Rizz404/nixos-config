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
  ];

  home.stateVersion = "26.05";
}
