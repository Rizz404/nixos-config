{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    ./starship.nix
    ./git.nix
    ./wezterm.nix
  ];

  home.stateVersion = "26.05";
}
