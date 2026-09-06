{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.loader.limine.enable = true;

  networking.hostName = "lenovo-thinkpad-t14-personal";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  services.printing.enable = true;

  users.users.rizz404 = {
    isNormalUser = true;
    description = "Rizqiansyah";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [ kdePackages.kate ];
  };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
