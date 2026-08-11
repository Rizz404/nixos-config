{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.kdePackages; [
    kdeconnect-kde
    partitionmanager
  ];
}
