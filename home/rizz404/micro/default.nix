{ pkgs, ... }:

{
  programs.micro = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./settings.json);
  };

  # Deklarasi Plugin & Tema ke ~/.config/micro/plug/
  xdg.configFile = {
    "micro/bindings.json".source = ./bindings.json;
    "micro/plug".source = ./plug;
    "micro/colorschemes".source = ./colorschemes;
  };
}