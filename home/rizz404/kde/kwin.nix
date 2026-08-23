{ ... }:

{
  programs.plasma.configFile.kwinrc = {
    Desktops = {
      Number = 1;
      Rows = 1;
    };

    Xwayland.Scale = 1;
  };
}
