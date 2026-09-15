{ pkgs, lib, ... }:
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

  # Fix "app/browser logout tiap ganti sesi Hyprland <-> Plasma" (lihat
  # hl.on("hyprland.start", ...) yang manggil pam_kwallet_init di
  # hyprland.lua). Itu butuh 2 hal biar KWallet/ksecretd beneran ke-unlock:
  # daemon-nya (kwalletd6+ksecretd, dari paket `kwallet`) kudu jalan, dan
  # hook PAM `pam_kwallet5.so` kudu ada di /etc/pam.d/login.
  #
  # Dua-duanya SEBENERNYA udah otomatis ke-pasang gara-gara
  # services.desktopManager.plasma6.enable di modules/desktop/plasma.nix —
  # tapi itu bikin Hyprland diam-diam numpang punya Plasma. Sengaja
  # dideklarasi ulang eksplisit di sini (opsi yang sama persis, NixOS aman
  # nge-merge deklarasi yang identik dari 2 modul) biar Hyprland "punya"
  # dependency-nya sendiri — kalau modules/desktop/plasma.nix suatu saat
  # dicabut, fitur ini tetep jalan buat Hyprland.
  #
  # Backend-nya tetep KWallet/ksecretd punya KDE (bukan gnome-keyring yang
  # lebih "standar" di ekosistem Hyprland) — sengaja, biar gak perlu 2 vault
  # kepisah (Hyprland vs Plasma) yang balikin lagi masalah logout-nya.
  #
  # Dibungkus lib.mkDefault: modules/desktop/plasma.nix nyet opsi yang
  # sama persis di priority normal. NixOS gak otomatis nganggep 2 definisi
  # "sama" walau nilainya identik (derivation Nix bawa function di
  # passthru-nya, jadi `==` selalu false) — tanpa mkDefault ini bakal error
  # "defined multiple times". mkDefault bikin definisi Plasma yang menang
  # kalau dua-duanya ada (gak ada bedanya buat kita), tapi definisi di sini
  # tetep kepake kalau plasma.nix suatu saat dicabut.
  security.pam.services.login.kwallet = lib.mkDefault {
    enable = true;
    package = pkgs.kdePackages.kwallet-pam;
  };

  # Fix "Open With" dialog Dolphin/KDE kosong pas jalan di Hyprland.
  # Hyprland (lewat systemd env sync) nge-export XDG_MENU_PREFIX="hyprland-",
  # tapi gak ada distro package yang nyediain hyprland-applications.menu
  # (beda sama Arch yang punya paket archlinux-xdg-menu, atau Plasma yang
  # bawa plasma-applications.menu). Tanpa file ini, kbuildsycoca6 gagal
  # nyusun menu app-nya → KOpenWithDialog nongol kosong.
  #
  # Sengaja ditulis sendiri di sini (bukan pinjam punya paket Plasma) biar
  # Hyprland gak nempel ke Plasma — salah satu boleh dihapus kapan aja tanpa
  # bikin yang lain ikut rusak. Isinya generic sesuai freedesktop Menu Spec:
  # cuma bilang "pakai semua .desktop yang ke-detect lewat XDG_DATA_DIRS",
  # gak ada kategori/submenu spesifik DE manapun.
  # Ref: https://specifications.freedesktop.org/menu/1.1/example.html
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

    # Daemon KWallet/ksecretd + helper PAM-nya — lihat komentar di
    # security.pam.services.login.kwallet di atas. Ditulis eksplisit di
    # sini juga (bukan cuma ngandelin plasma6.nix narik ini) biar Hyprland
    # gak kehilangan daemon-nya kalau Plasma suatu saat dicabut.
    kdePackages.kwallet
    kdePackages.kwallet-pam
  ];
}
