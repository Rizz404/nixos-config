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
          "Show Preview" = false;
          "Show Speedbar" = true;
          "Show hidden files" = false;
          "Sort by" = "Name";
          "Sort directories first" = true;
          "Sort hidden files last" = false;
          "Sort reversed" = false;
          "Speedbar Width" = 140;
          "View Style" = "DetailTree";
        };

        WM = {
          activeBackground = "38,41,46";
          activeBlend = "38,41,46";
          activeForeground = "252,252,252";
          inactiveBackground = "38,41,46";
          inactiveBlend = "38,41,46";
          inactiveForeground = "177,177,177";
        };
      };

      krunnerrc.General.FreeFloating = true;

      plasma-localerc.Formats.LANG = "en_US.UTF-8";
    };
  };
}
