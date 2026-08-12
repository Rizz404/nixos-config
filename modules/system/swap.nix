{ ... }:
{
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16384;
    }
  ];

  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };
}
