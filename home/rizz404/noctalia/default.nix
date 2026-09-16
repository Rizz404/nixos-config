{ config, ... }:
let
  idleDimScript = "${config.home.homeDirectory}/.config/noctalia/idle-dim.sh";
in
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

      # Idle SENGAJA gak pernah suspend/sleep otomatis — cuma dim brightness.
      # Suspend cuma kejadian kalau user sengaja mencet tombol power fisik
      # (lihat hosts/<host>/configuration.nix -> services.logind.settings).
      #
      # Timeout beda pas charge vs pakai baterai disimulasikan dengan DUA
      # behavior yang jalan paralel, masing-masing self-check status charging
      # lewat idle-dim.sh dan no-op kalau gak nyambung sama kondisi aktual.
      idle = {
        pre_action_fade_seconds = 0;
        behavior = {
          dim-ac = {
            enabled = true;
            timeout = 600; # 10 menit, saat di-charge
            action = "command";
            command = "${idleDimScript} ac dim";
            resume_command = "${idleDimScript} ac resume";
          };
          dim-battery = {
            enabled = true;
            timeout = 300; # 5 menit, saat pakai baterai
            action = "command";
            command = "${idleDimScript} battery dim";
            resume_command = "${idleDimScript} battery resume";
          };
        };
      };
    };
  };

  wayland.windowManager.hyprland.extraConfig = builtins.readFile ./noctalia.lua;

  xdg.configFile = {
    "hypr/modules/noctalia/autostart.lua".source = ./modules/autostart.lua;
    "hypr/modules/noctalia/keybindings.lua".source = ./modules/keybindings.lua;
    "hypr/modules/noctalia/rules.lua".source = ./modules/rules.lua;

    "noctalia/idle-dim.sh" = {
      source = ./idle-dim.sh;
      executable = true;
    };
  };
}
