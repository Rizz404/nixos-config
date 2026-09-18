{pkgs, ...}:
{
  # Steam — declarative, otomatis urus 32-bit lib, udev rules controller, port firewall, dst.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;       # kalau mau streaming ke device lain di jaringan
    dedicatedServer.openFirewall = false; # cuma perlu kalau mau host game server sendiri
  };
  hardware.steam-hardware.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true; # bisa langsung `./game.AppImage` tanpa wrapper manual
  };

  environment.systemPackages = with pkgs; [
    itch               # client resmi itch.io
    steam-run          # FHS sandbox buat binary Linux sembarangan (non-AppImage, non-Steam)
    lutris             # kelola game Windows-only dari luar Steam (GOG installer, itch, dll)
    wineWowPackages.stable
    winetricks
  ];
}
