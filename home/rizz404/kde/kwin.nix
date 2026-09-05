{ ... }:

{
  programs.plasma.configFile = {
    kwinrc = {
      Desktops = {
        Number = 1;
        Rows = 1;
      };

      Xwayland.Scale = 1;
    };

    kwinrulesrc = {
      "02ecdb93-7a4d-498b-8db1-aaa70b65d17f" = {
        Description = "RustDesk Remote Shortcuts";
        disableglobalshortcuts = true;
        disableglobalshortcutsrule = 2;
        title = "519095509@fujiyama - Remote Desktop - RustDesk";
        titlematch = 2;
        wmclass = "rustdesk";
        wmclassmatch = 1;
      };

      General = {
        count = 1;
        rules = "02ecdb93-7a4d-498b-8db1-aaa70b65d17f";
      };
    };
  };
}
