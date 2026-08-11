{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    chromium
    wezterm
    onlyoffice-desktopeditors
    qbittorrent
    scrcpy
    mpv
    pavucontrol
  ];
}
