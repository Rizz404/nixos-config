{ ... }:

{
  programs.plasma = {
    workspace = {
      iconTheme = "Papirus-Dark";
    };

    configFile = {
      kdeglobals = {
        KDE = {
          contrast = 4;
          frameContrast = 0.2;
        };

        "KFileDialog Settings" = {
          "Allow Expansion" = false;
          "Automatically select filename extension" = true;
          "Breadcrumb Navigation" = true;
          "Decoration position" = 2;
          "Show Full Path" = false;
          "Show Inline Previews" = true;
          "Show Speedbar" = true;
          "Show hidden files" = false;
          "Sort by" = "Name";
          "Sort directories first" = true;
          "Sort hidden files last" = false;
          "Sort reversed" = false;
          "Speedbar Width" = 140;
          "View Style" = "DetailTree";
        };
      };

      krunnerrc.General.FreeFloating = true;

      plasma-localerc.Formats.LANG = "en_US.UTF-8";
    };
  };
}
