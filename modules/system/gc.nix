{ pkgs, ... }:
{
  # Murah & cepat, aman jalan tiap boot/switch
  system.activationScripts.trimGenerations = {
    text = ''
      ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +5
    '';
    deps = [ ];
  };

  # Mahal (scan /nix/store) — jangan blocking boot, jalanin di background
  systemd.services.nix-gc-async = {
    description = "Reclaim disk space freed by trimmed generations";
    serviceConfig.Type = "oneshot";
    script = "${pkgs.nix}/bin/nix-collect-garbage";
    wantedBy = [ "multi-user.target" ]; # jalan setelah boot selesai, non-blocking
  };

  systemd.timers.nix-gc-async = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
}
