{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    chromium
    wezterm
    onlyoffice-desktopeditors
    qbittorrent
    scrcpy
    android-tools # nyediain `adb` yang dipakai scrcpy buat konek ke HP
    mpv
    pavucontrol
    varia
  ];
}
