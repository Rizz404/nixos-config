{ ... }:
{
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4096;
    }
  ];

  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };
}
