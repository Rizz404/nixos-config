{ pkgs, ... }:
{
  # * Ganti pesan boot/shutdown putih-hijau khas Linux dengan splash grafis
  #   Catppuccin Mocha - selaras sama theme.builtin Noctalia (home/rizz404/noctalia/default.nix)
  boot.plymouth = {
    enable = true;
    theme = "catppuccin-mocha";
    themePackages = [
      (pkgs.catppuccin-plymouth.override { variant = "mocha"; })
    ];
  };

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];
}
