{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = null; # paket sudah disediakan system-wide lewat modules/desktop/hyprland.nix
    configType = "lua";
    # Placeholder @KWALLET_PAM_INIT@ di hyprland.lua diganti path binary
    # pam_kwallet_init yang asli (buat auto-unlock KWallet/ksecretd, lihat
    # komentar di hyprland.lua bagian AUTOSTART). Ditulis begini (bukan
    # hardcode path store-nya) biar tetap valid walau hash-nya berubah pas
    # kwallet-pam ke-update.
    extraConfig = builtins.replaceStrings
      [ "@KWALLET_PAM_INIT@" ]
      [ "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init" ]
      (builtins.readFile ./hyprland.lua);
  };
  xdg.portal.config.common.default = "*";
}
