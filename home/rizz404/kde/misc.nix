{ ... }:

{
  programs.plasma.configFile = {
    kded5rc = {
      Module-browserintegrationreminder.autoload = false;
      Module-device_automounter.autoload = false;
    };

    kwalletrc.Wallet."First Use" = false;
  };
}
