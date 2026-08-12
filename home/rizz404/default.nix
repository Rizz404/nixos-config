{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    ./starship.nix
    ./git.nix
    ./vscode.nix
    ./wezterm.nix
    ./fastfetch.nix
  ];

  home.stateVersion = "26.05";
}
