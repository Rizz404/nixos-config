{ pkgs, ... }:
{
  # keep 5 generations
  system.activationScripts.trimGenerations = {
    text = ''
      ${pkgs.nix}/bin/nix-env \
        -p /nix/var/nix/profiles/system \
        --delete-generations +5
    '';
    deps = [ ];
  };

  # GC hanya dijalankan oleh timer.
  systemd.services.nix-gc-async = {
    description = "Reclaim unused Nix store paths";

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      ${pkgs.nix}/bin/nix-collect-garbage
    '';
  };

  systemd.timers.nix-gc-async = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
}
