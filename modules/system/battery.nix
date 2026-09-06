{ ... }:
{
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 50;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  services.power-profiles-daemon.enable = false;
}
