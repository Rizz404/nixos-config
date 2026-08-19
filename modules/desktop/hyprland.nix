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
    rofi-wayland

    # notifikasi — dua-duanya
    mako
    swaync

    # wallpaper — dua-duanya
    hyprpaper
    swww

    hyprlock
    hypridle
    hyprpolkitagent   # polkit agent native Hyprland, gak nebeng KDE lagi

    wl-clipboard
    cliphist

    grim
    slurp
    swappy
  ];
}
