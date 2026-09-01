{ pkgs, ... }:
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

    # notifikasi — dua-duanya
    mako
    swaynotificationcenter

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
