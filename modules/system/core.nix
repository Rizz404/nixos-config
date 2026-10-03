{ pkgs, inputs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.extra-substituters = [
    "https://attic.xuyh0120.win/lantian"
    "file:///home/rizz404/nix-cache"
    "https://noctalia.cachix.org"
    "https://cache.numtide.com"
    ];
  nix.settings.trusted-public-keys = [
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
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
    efibootmgr
  ];
}
