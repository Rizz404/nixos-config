{ ... }:
{
  programs.noctalia = {
    enable = true;
    # SENGAJA false, JANGAN diubah ke true tanpa scoping tambahan.
    # Docs resmi nyaranin true, tapi itu bikin systemd.user.services.noctalia
    # (lihat nix/home-module.nix di source noctalia) punya
    # PartOf/After/WantedBy = config.wayland.systemd.target, yang defaultnya
    # "graphical-session.target" — target generik yang juga diaktifin sama
    # sesi Plasma 6 (bukan cuma Hyprland). Host ini dual: bisa login ke
    # Plasma ATAU Hyprland (lihat modules/desktop/plasma.nix +
    # home/rizz404/kde/). Kalau true, Noctalia (shell layer-shell + panel +
    # notifikasi) bisa ke-autostart pas sesi Plasma juga → bentrok sama
    # plasmashell/panel & notification daemon Plasma sendiri.
    #
    # Autostart Noctalia tetap jalan tanpa ini kok, lewat hook
    # `hl.on("hyprland.start", ...)` di noctalia.lua — itu murni internal
    # Hyprland, cuma nyala kalau Hyprland yang di-start, jadi otomatis aman
    # dari sesi Plasma.
    systemd.enable = false;

    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };
  };

  wayland.windowManager.hyprland.extraConfig = builtins.readFile ./noctalia.lua;
}
