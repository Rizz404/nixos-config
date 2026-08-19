{ pkgs, ... }:
{
  imports = [
    ./fish
    ./starship
    ./git
    ./wezterm
    ./micro
  ];

  home.stateVersion = "26.05";
}
