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
    ./gnupg
  ];

  home.stateVersion = "26.05";
}
