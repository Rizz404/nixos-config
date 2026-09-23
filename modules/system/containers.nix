{ ... }:
{
  virtualisation.podman.enable = true;
  virtualisation.containers.policy.default = [{ type = "insecureAcceptAnything"; }];
  virtualisation.waydroid.enable = true;
}
