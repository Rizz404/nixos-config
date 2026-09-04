{ pkgs, ... }:
let
  # mako & swaync sama-sama ship dbus-1/services/*.service yang klaim
  # `org.freedesktop.Notifications` — busname yang sama persis dipakai
  # plasma-workspace. File itu di-scan GLOBAL sama D-Bus session bus
  # (lewat XDG_DATA_DIRS), gak peduli session Plasma atau Hyprland yang
  # lagi jalan, jadi kalau dipasang apa adanya salah satunya bisa nyolong
  # notifikasi Plasma walau kita lagi login ke Plasma (kejadian beneran,
  # bukan cuma teori). Makanya cuma satu yang dipasang (mako — lebih
  # ringan), dan busname file-nya dibuang biar dia cuma jalan kalau
  # di-exec manual dari hyprland.lua, gak auto-activate lewat dbus.
  mako' = pkgs.mako.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      rm -f $out/share/dbus-1/services/fr.emersion.mako.service
    '';
  });

  # Mau pindah ke swaync (ada notification-center panel)? Uncomment ini,
  # comment mako' di bawah, terus ganti exec-once mako -> swaync di hyprland.lua.
  # swaync' = pkgs.swaynotificationcenter.overrideAttrs (old: {
  #   postInstall = (old.postInstall or "") + ''
  #     rm -f $out/share/dbus-1/services/org.erikreider.swaync.service
  #   '';
  # });
in
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    configPackages = [ pkgs.hyprland ];
  };

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    waybar

    # launcher — dua-duanya, pilih salah satu per-host di hyprland.conf
    wofi
    rofi

    # notifikasi — cuma mako, swaync di-skip karena busname-nya bentrok (lihat komentar di atas)
    mako'
    # swaync'

    # wallpaper — dua-duanya
    hyprpaper
    awww

    hyprlock
    hypridle
    hyprpolkitagent   # polkit agent native Hyprland, gak nebeng KDE lagi

    wl-clipboard
    cliphist

    grim
    slurp
    swappy

    kitty          # terminal (dolphin buat file manager udah ada via Plasma)
    hyprlauncher   # menu/app launcher bawaan Hypr ecosystem
    brightnessctl  # tombol brightness laptop
    playerctl      # tombol media next/prev/play-pause
  ];
}
