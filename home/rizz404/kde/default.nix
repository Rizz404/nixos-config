{ pkgs, ... }:

let
  catppuccin-kde = pkgs.catppuccin-kde.override {
    flavour = [
      "mocha"
      "macchiato"
      "frappe"
      "latte"
    ];

    accents = [
      "blue"
      "rosewater"
      "pink"
      "mauve"
      "red"
      "peach"
      "green"
      "teal"
      "sapphire"
      "lavender"
    ];

    winDecStyles = [ "modern" ];
  };
in
{
  imports = [
    ./workspace.nix
    ./shortcuts.nix
    ./kwin.nix
    ./apps.nix
    ./misc.nix
  ];

  home.packages = [
    pkgs.papirus-icon-theme
    catppuccin-kde
  ];

  programs.plasma = {
    enable = true;

    # Tetap false selama panel/widgets belum dimigrasikan.
    overrideConfig = false;
  };

  # Temporary.
  # Nanti dihapus setelah panel/widgets dipindahkan ke Plasma Manager.
  xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc".source =
    ./plasma-org.kde.plasma.desktop-appletsrc;

  xdg.configFile."plasmashellrc".source =
    ./plasmashellrc;
}
