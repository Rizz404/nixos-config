{ pkgs, inputs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.extra-substituters = [
      "https://attic.xuyh0120.win/lantian"
      "file:///home/rizz404/nix-cache"
    ];
  nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.settings.keep-outputs = true;
  nix.settings.keep-derivations = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    htop
    tree
    vim
  ];
}
