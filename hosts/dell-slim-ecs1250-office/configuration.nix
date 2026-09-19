{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  virtualisation.vmware.guest.enable = true;

  # * Load vmwgfx di initrd (early KMS) biar Plymouth gak blank sekilas
  #   sebelum driver display VMware kepasang - belum diverifikasi langsung
  #   di mesin ini, cek `journalctl -b -1 | grep -i drm` kalau masih blank.
  boot.initrd.kernelModules = [ "vmwgfx" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "dell-slim-ecs1250-office";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  services.printing.enable = true;

  users.users.rizz404 = {
    isNormalUser = true;
    description = "rizz404";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
