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
    # * 711 (bukan default 700) - biar user "sddm" (greeter, uid terpisah dari rizz404)
    #   bisa traverse ke ~/Pictures/Wallpapers & ~/.config/qylock buat baca wallpaper +
    #   warna live. Isi folder tetap gak ke-list ke user lain, cuma traverse ke path
    #   yang udah tau namanya.
    homeMode = "711";
  };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  # * Pakai qylock cuma buat infra install theme SDDM - theme-nya sendiri
  #   (noctalia-sync) ditulis dari nol, niru visual lockscreen native Noctalia
  #   (blur+tint di atas wallpaper aktif) biar login screen & lockscreen
  #   konsisten. Lockscreen-nya sendiri gak pakai qylock sama sekali, pakai
  #   native Noctalia (programs.noctalia.settings.lockscreen di
  #   home/rizz404/noctalia/default.nix).
  programs.qylock = {
    enable = true;
    theme = "noctalia-sync";
    quickshell.enable = false;
  };

  # * Qt6 default-nya blokir XMLHttpRequest baca file lokal - dibutuhin theme
  #   noctalia-sync buat baca ~/.config/qylock/{colors.json,wallpaper.txt}.
  services.displayManager.sddm.settings.General.GreeterEnvironment = "QML_XHR_ALLOW_FILE_READ=1";

  system.stateVersion = "26.05";
}
