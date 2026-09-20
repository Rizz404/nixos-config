{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = null; # paket sudah disediakan system-wide lewat modules/desktop/hyprland.nix
    configType = "lua";
    extraConfig = builtins.readFile ./hyprland.lua;
  };
  xdg.portal.config.common = {
    default = "*";

    # Fix "Brave sync chain putus / minta kode ulang tiap ganti sesi".
    # Root cause-nya BUKAN cuma soal KWallet ke-unlock atau nggak — Brave
    # minta encryption key-nya lewat portal org.freedesktop.impl.portal.Secret
    # (dicek: ~/.config/BraveSoftware/.../Local State -> os_crypt.portal ada
    # "prev_init_success": false). Satu-satunya portal yang implement Secret
    # di sistem ini itu kwallet.portal (dari paket kwallet), tapi file itu
    # nulis `UseIn=kde` — jadi kalau default (wildcard "*" di atas) yang
    # nentuin, dia di-skip pas XDG_CURRENT_DESKTOP=Hyprland (cuma cocok pas
    # =KDE/Plasma). Brave gak dapet backend Secret sama sekali → gagal diem-
    # diem → key sync chain-nya gak ke-simpan/ke-baca konsisten.
    #
    # Override eksplisit di sini nembus batasan UseIn= itu (beda dari
    # wildcard "*", preferensi per-interface yang dinamain gini emang gak
    # dicek ulang ke UseIn= oleh xdg-desktop-portal), jadi Secret SELALU
    # diarahin ke kwallet apapun desktop-nya — Plasma tetap kwallet juga
    # (gak ada bedanya buat sesi Plasma), Hyprland sekarang ikut dapet.
    "org.freedesktop.impl.portal.Secret" = [ "kwallet" ];
  };

  xdg.configFile = {
    "hypr/peek-desktop.sh" = {
      source = ./peek-desktop.sh;
      executable = true;
    };

    "hypr/compact-workspaces.sh" = {
      source = ./compact-workspaces.sh;
      executable = true;
    };

    "hypr/smart-focus.sh" = {
      source = ./smart-focus.sh;
      executable = true;
    };

    "hypr/modules/hyprland/monitors.lua".source = ./modules/monitors.lua;
    "hypr/modules/hyprland/programs.lua".source = ./modules/programs.lua;

    # Placeholder @KWALLET_PAM_INIT@ diganti path binary pam_kwallet_init
    # yang asli (buat auto-unlock KWallet/ksecretd, lihat komentar di
    # modules/autostart.lua). Ditulis begini (bukan hardcode path store-nya)
    # biar tetap valid walau hash-nya berubah pas kwallet-pam ke-update.
    "hypr/modules/hyprland/autostart.lua".text = builtins.replaceStrings
      [ "@KWALLET_PAM_INIT@" ]
      [ "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init" ]
      (builtins.readFile ./modules/autostart.lua);

    "hypr/modules/hyprland/environment.lua".source = ./modules/environment.lua;
    "hypr/modules/hyprland/permissions.lua".source = ./modules/permissions.lua;
    "hypr/modules/hyprland/appearance.lua".source = ./modules/appearance.lua;
    "hypr/modules/hyprland/animations.lua".source = ./modules/animations.lua;
    "hypr/modules/hyprland/layout.lua".source = ./modules/layout.lua;
    "hypr/modules/hyprland/misc.lua".source = ./modules/misc.lua;
    "hypr/modules/hyprland/input.lua".source = ./modules/input.lua;
    "hypr/modules/hyprland/keybindings.lua".source = ./modules/keybindings.lua;
    "hypr/modules/hyprland/windowrules.lua".source = ./modules/windowrules.lua;
  };

}
