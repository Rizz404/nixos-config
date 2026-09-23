{ pkgs, ... }:
{
  virtualisation.podman.enable = true;
  virtualisation.containers.policy.default = [{ type = "insecureAcceptAnything"; }];
  virtualisation.waydroid.enable = true;

  # Kernel >=6.17 nixpkgs default gak nyertain modul ip_tables lagi,
  # tapi package waydroid biasa masih hardcode ke iptables-legacy yang butuh itu.
  # waydroid-nftables pakai nft langsung, gak butuh ip_tables sama sekali.
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
}
