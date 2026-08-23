{ ... }:

{
  programs.plasma.configFile = {
    dolphinrc = {
      General.GlobalViewProps = false;

      "KFileDialog Settings" = {
        "Places Icons Auto-resize" = false;
        "Places Icons Static Size" = 16;
      };

      "Notification Messages".warnAboutRisksBeforeActingAsAdmin = false;

      PlacesPanel.IconSize = 16;

      PreviewSettings.Plugins =
        "ffmpegthumbnailer,appimagethumbnail,audiothumbnail,glycin-heif,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,glycin-image-rs,jpegthumbnail,glycin-jxl,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,glycin-svg,svgthumbnail,ffmpegthumbs,gsf-office";
    };

    katerc = {
      General = {
        "Days Meta Infos" = 30;
        "Save Meta Infos" = true;
        "Show Full Path in Title" = false;
        "Show Menu Bar" = true;
        "Show Status Bar" = true;
        "Show Tab Bar" = true;
        "Show Url Nav Bar" = true;
      };

      filetree = {
        listMode = false;
        middleClickToClose = false;
        shadingEnabled = true;
        showCloseButton = false;
        showFullPathOnRoots = false;
        showToolbar = true;
        sortRole = 0;
      };
    };

    spectaclerc = {
      General = {
        autoSaveImage = true;
        clipboardGroup = "PostScreenshotCopyImage";
      };

      ImageSave.translatedScreenshotsFolder = "Screenshots";
      VideoSave.translatedScreencastsFolder = "Screencasts";
    };
  };
}
