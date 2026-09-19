{ ... }:
{
  hardware.bluetooth.enable = true;
  services.tailscale.enable = true;
  services.upower.enable = true;
  systemd.services.tailscaled.serviceConfig.TimeoutStopSec = "5s";
}
