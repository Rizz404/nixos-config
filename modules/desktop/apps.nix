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
    (pkgs.callPackage ../../pkgs/ab-download-manager.nix { })

    # * Dibutuhin biar template GTK3/GTK4 & QT Noctalia (lihat
    # * home/rizz404/noctalia/default.nix) beneran keliatan efeknya di app
    adw-gtk3 # tema GTK3/GTK4 yang dipasangin Noctalia lewat gsettings
    nwg-look # GUI buat cek/atur tema GTK kalau apply.sh Noctalia gak cukup
    kdePackages.qt6ct # color scheme "noctalia (KColorScheme)" / "noctalia" QT butuh ini
  ];
}
