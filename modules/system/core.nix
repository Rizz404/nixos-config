{ pkgs, inputs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    htop
    tree
    vim
  ];
}
