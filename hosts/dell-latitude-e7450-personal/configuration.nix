{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # === Bootloader: Limine, dual-boot dengan CachyOS asli di disk yang sama ===
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  boot.loader.limine = {
    enable = true;
    efiInstallAsRemovable = true;

    extraConfig = ''
      /+CachyOS
        protocol: linux
        path: boot():/0bcb8e0c7ca746e8875dceb3f97bef01/linux-cachyos/vmlinuz
        module_path: boot():/0bcb8e0c7ca746e8875dceb3f97bef01/linux-cachyos/initramfs
        cmdline: quiet nowatchdog splash rw rootflags=subvol=/@ root=UUID=bd74beaa-c72c-4a4a-ba70-ad602f145601 i8042.unlock
    '';
  };

  system.activationScripts.limineBootPolicy = {
    deps = [ "etc" ];
    text = ''
      conf=/boot/limine/limine.conf

      if [ -f "$conf" ]; then
        ${pkgs.gnused}/bin/sed -i \
          '/^[[:space:]]*default_entry:/d' "$conf"

        latest="$(${pkgs.gawk}/bin/awk '
          /^\/\/Generation [0-9]+$/ {
            print $2
            exit
          }
        ' "$conf")"

        if [ -n "$latest" ]; then
          echo "Limine: default NixOS -> Generation $latest"
          ${pkgs.systemd}/bin/bootctl set-default \
            "NixOS default profile/Generation $latest" \
            || echo "Warning: gagal mengatur LoaderEntryDefault"
        fi
      fi
    '';
  };

  # Utility buat pindah boot ke CachyOS asli
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "to-cachy" ''
      set -euo pipefail
      echo "Mengubah default boot ke CachyOS..."
      ${systemd}/bin/bootctl set-default "CachyOS"
      echo "Reboot ke CachyOS..."
      ${systemd}/bin/systemctl reboot
    '')
  ];

  networking.hostName = "dell-latitude-e7450-personal";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  services.printing.enable = true;

  users.users.rizz404 = {
    isNormalUser = true;
    description = "Rizqiansyah";
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
