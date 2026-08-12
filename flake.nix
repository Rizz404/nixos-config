{
  description = "NixOS modular configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
	    url = "github:nix-community/home-manager/release-26.05";
	    inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  

  outputs = { self, nixpkgs, home-manager, ... }: {
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

          home-manager.nixosModules.home-manager
                  {
                   home-manager.useGlobalPkgs = true;
                   home-manager.useUserPackages = true;
                   home-manager.backupFileExtension = "backup";
                   home-manager.users.rizz404 = import ./home/rizz404/default.nix;
                  }
        ];
      };
    };
  };
}
