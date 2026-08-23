{ pkgs, ... }:
let
  catppuccin-kde = pkgs.catppuccin-kde.override {
    flavour = [ "mocha" "macchiato" "frappe" "latte" ];
    accents = [ "blue" "rosewater" "pink" "mauve" "red" "peach" "green" "teal" "sapphire" "lavender" ];
    winDecStyles = [ "modern" ];
  };
in
{
  home.packages = [
    pkgs.papirus-icon-theme
    catppuccin-kde
  ];

  xdg.configFile."dolphinrc".source = ./dolphinrc;
  xdg.configFile."katerc".source = ./katerc;
  xdg.configFile."kdeglobals".source = ./kdeglobals;
  xdg.configFile."kglobalshortcutsrc".source = ./kglobalshortcutsrc;
  xdg.configFile."kwinrc".source = ./kwinrc;
  xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc".source = ./plasma-org.kde.plasma.desktop-appletsrc;
  xdg.configFile."plasmarc".source = ./plasmarc;
  xdg.configFile."plasmashellrc".source = ./plasmashellrc;
}
