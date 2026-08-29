{
  description = "NixOS modular configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nixpkgs, home-manager, nix-cachyos-kernel, ... }@inputs:
    let
      system = "x86_64-linux";

      # Modul bersama yang dipakai di semua host
      sharedModules = [
        ./modules/system/core.nix
        ./modules/system/shell.nix
        ./modules/system/devtools.nix
        ./modules/system/network.nix
        ./modules/system/swap.nix
        ./modules/system/kernel.nix
        ./modules/system/gc.nix
        ./modules/system/nix-ld.nix
        ./modules/desktop/plasma.nix
        ./modules/desktop/apps.nix
        ./modules/desktop/kde-apps.nix
        ./modules/desktop/fonts.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";

          home-manager.sharedModules = [
            inputs.plasma-manager.homeModules.plasma-manager
          ];

          home-manager.users.rizz404 = import ./home/rizz404/default.nix;
        }
      ];
    in
    {
      nixosConfigurations = {
        # Host Kantor
        dell-slim-ecs1250-office = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/dell-slim-ecs1250-office/configuration.nix
          ] ++ sharedModules;
        };

        # Host Laptop Personal
        dell-latitude-e7450-personal = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/dell-latitude-e7450-personal/configuration.nix
          ] ++ sharedModules;
        };
      };
    };
}
