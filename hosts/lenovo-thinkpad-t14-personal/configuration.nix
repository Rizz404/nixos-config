{ config, lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # biar nixos-rebuild gak cuma pakai 2 dari 12 thread yang ada, override swap.nix
  nix.settings = {
    max-jobs = lib.mkForce 4;
    cores = lib.mkForce 3;
  };

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.loader.limine.enable = true;

  networking.hostName = "lenovo-thinkpad-t14-personal";
  networking.networkmanager.enable = true;

  # * Power button buat sleep saat aktif bukan langsung poweroff
  services.logind.settings.Login.HandlePowerKey = "suspend";

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

  # * Eksperimen: SDDM login theme + Quickshell lockscreen dari qylock
  #   (~/qylock). theme = nama folder di https://github.com/Darkkal44/qylock/tree/main/themes
  #   - ganti sesuka hati, banyak preview di README-nya. Di-comment dulu (butuh nixpkgs
  #   unstable terpisah yang lumayan besar buat di-download, ditunda sampai ada
  #   koneksi yang gak makan kuota) - lihat input `qylock` di flake.nix.
  # programs.qylock = {
  #   enable = true;
  #   theme = "nier-automata";
  # };

  system.stateVersion = "26.05";
}
