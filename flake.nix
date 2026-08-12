{
  description = "Konfigurasi NixOS modular untuk rizz404";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      dell-slim-ecs1250-office = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/dell-slim-ecs1250-office/configuration.nix
          ./modules/system/core.nix
          ./modules/system/shell.nix
          ./modules/system/devtools.nix
          ./modules/system/network.nix
          ./modules/system/swap.nix
          ./modules/desktop/plasma.nix
          ./modules/desktop/apps.nix
          ./modules/desktop/kde-apps.nix
          ./modules/desktop/fonts.nix
        ];
      };
    };
  };
}
