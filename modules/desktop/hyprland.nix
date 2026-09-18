{ pkgs, lib, ... }:
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
  services.udisks2.enable = true;

  # * Biar app tetap auth saat pindah ke hyprland dari plasma
  security.pam.services.login.kwallet = lib.mkDefault {
    enable = true;
    package = pkgs.kdePackages.kwallet-pam;
  };

  # * Open with dialog buat manual gak minjem plasma
  environment.etc."xdg/menus/hyprland-applications.menu".text = ''
    <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
      "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
    <Menu>
      <Name>Applications</Name>
      <DefaultAppDirs/>
      <DefaultDirectoryDirs/>
      <DefaultMergeDirs/>
    </Menu>
  '';

  environment.systemPackages = with pkgs; [
    # * Bar, launcher, notifikasi, wallpaper, lockscreen, idle, polkit agent,
    hyprlauncher   # * menu/app launcher bawaan Hypr ecosystem, dipakai di SUPER+R
    brightnessctl  # * tombol brightness laptop
    playerctl      # * tombol media next/prev/play-pause
    # * Pakai wallet plasma buat nyimpen kredensial dan tetap ada walau nantinya plasma hilang
    kdePackages.kwallet
    kdePackages.kwallet-pam
    udiskie # * Auto-mount + notifikasi + kasih menu eject pada usb drive
    xrdb    # * Set Xft.dpi biar app XWayland (steam, dll) gak kekecilan/blur di monitor scale 1.5 (lihat modules/hyprland/autostart.lua)
  ];
}
