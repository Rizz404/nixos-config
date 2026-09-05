{ pkgs, ... }:

# The "Moe-Dark" global theme (KDE Store, by jomada) is what's actually
# active in the live Plasma session. It's not packaged in nixpkgs, so we
# fetch it straight from the author's source repos and pin exact revisions
# -- same approach as the plugins/colorschemes in ../micro/default.nix --
# instead of committing the theme's binary assets into this repo.
#
# Only `lookAndFeel` is declared: setting it alone lets Plasma's own
# `plasma-apply-lookandfeel` apply the whole bundle (cursor, color scheme,
# window decoration, wallpaper, plasma theme) the same way picking it in
# System Settings would. plasma-manager warns against also setting
# windowDecorations/splashScreen/etc separately, since the look-and-feel
# package's own defaults already cover those and would fight with it.
#
# NOTE: this only takes effect via an autostart script that runs once per
# Plasma session login (not immediately on `home-manager switch`), and is
# skipped entirely if its content hash hasn't changed since last run. After
# switching, log out and back in to actually see it applied.
let
  moeDark = pkgs.fetchFromGitLab {
    owner = "jomada";
    repo = "moe-dark";
    rev = "1e9dcd6d89a58f1de61e13cc361f563e01dd1c26";
    hash = "sha256-bQMbOKsHsaoEC4UJ5aIYD+D/GGkEAd7txYG8+VdaTV8=";
  };

  # Cursor theme isn't part of jomada's repo (it's a separate KNS
  # dependency of the look-and-feel package), so it's fetched from its own
  # upstream project.
  whiteSurCursors = pkgs.fetchFromGitHub {
    owner = "vinceliuice";
    repo = "WhiteSur-cursors";
    rev = "e190baf618ed95ee217d2fd45589bd309b37672b";
    hash = "sha256-hFtfq8F6KeqUEBlypPCr/EKq6rif/g868vJd8c06c1I=";
  };
in
{
  programs.plasma.workspace.lookAndFeel = "Moe-Dark";

  xdg.dataFile = {
    "plasma/look-and-feel/Moe-Dark".source = "${moeDark}/look-and-feel/Moe-Dark";
    "color-schemes/MoeDark.colors".source = "${moeDark}/color-schemes/MoeDark.colors";
    "plasma/desktoptheme/Moe-Dark".source = "${moeDark}/Moe-Dark";
    "aurorae/themes/MoeDark".source = "${moeDark}/aurorae/MoeDark";
    "wallpapers/MoeDark-DarkSouls".source = "${moeDark}/Wallpapers/MoeDark-DarkSouls";
  };

  # Cursor themes are looked up under ~/.icons, not ~/.local/share/icons.
  home.file.".icons/WhiteSur-cursors".source = "${whiteSurCursors}/dist";
}
