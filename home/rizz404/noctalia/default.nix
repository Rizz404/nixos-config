{ config, ... }:
let
  idlePowerScript = "${config.home.homeDirectory}/.config/noctalia/idle-power.sh";
  onColorsChangedScript = "${config.home.homeDirectory}/.config/noctalia/on-colors-changed.sh";
  stickerRandomScript = "${config.home.homeDirectory}/.config/noctalia/sticker-random.sh";
in
{
  programs.noctalia = {
    enable = true;
    # * Biar gak bentrok sama plasma, jadi kalo bukan hyprland di disable
    systemd.enable = false;

    settings = {
      shell = {
        font_family = "Maple Mono NF";
      };

      theme = {
        mode = "auto";
        shell_mode = "auto";
        source = "wallpaper";
        builtin = "Catppuccin";
        community_palette = "Oxocarbon";
        wallpaper_scheme = "m3-tonal-spot";
        templates = {
          enable_builtin_templates = true;
          # * hyprland = border window, wezterm = terminal, gtk3/gtk4/qt = app non-KDE,
          # * kcolorscheme = Dolphin & app KDE lain
          builtin_ids = [ "hyprland" "wezterm" "gtk3" "gtk4" "qt" "kcolorscheme" ];

          enable_community_templates = true;
          # * vscode sengaja gak dipakai - settings.json-nya di-sync ke perangkat non-Linux juga
          community_ids = [ "brave" ];

          # * Template custom buat theme SDDM noctalia-sync
          user.qylock-colors = {
            input_path = "${config.home.homeDirectory}/.config/noctalia/templates/qylock-colors.json.tmpl";
            output_path = "${config.home.homeDirectory}/.config/qylock/colors.json";
          };
        };
      };

      nightlight = {
        enabled = false;
      };

      # * Lockscreen native Noctalia - wallpaper & warna otomatis ikut wallpaper aktif
      lockscreen = {
        enabled = true;
        blurred_desktop = false;
        blur_intensity = 0.6;
        tint_intensity = 0.35;
      };

      location = {
        auto_locate = true;
      };

      # * Hooks untuk buat samain lockscreen sama sticker ketika wallpaper changed
      hooks = {
        colors_changed = onColorsChangedScript;
        wallpaper_changed = stickerRandomScript;
      };

      wallpaper = {
        directory = "~/Pictures/Wallpapers";
        transition = [ "wipe" ];
        automation = {
          enabled = true;
          interval_seconds = 3600;
        };
      };

      bar.default = {
        position = "top";
        enabled = true;
        thickness = 32;
        radius = 16;
        margin_ends = 0;
        margin_edge = 4;
        # * 0 = gak nambah reserved space ekstra selain gaps_out Hyprland (appearance.lua),
        # *  biar window bisa mepet bar tanpa dead-space dobel
        margin_opposite_edge = 0;
        background_opacity = 0.0;
        capsule = true;
        capsule_opacity = 0.55;

        start = [ "group:nav" ];
        center = [ "clock" ];
        end = [ "group:media" "group:sys" ];

        capsule_group = [
          {
            id = "nav";
            members = [ "launcher" "workspaces" ];
            fill = "surface_variant";
            opacity = 0.55;
          }
          {
            id = "media";
            members = [ "media" "notifications" ];
            fill = "surface_variant";
            opacity = 0.55;
          }
          {
            id = "sys";
            members = [ "network" "bluetooth" "volume" "battery" "tray" "control-center" ];
            fill = "primary";
            foreground = "on_primary";
            # * Dinaikin dari 0.55 - di opacity rendah, teks "on_primary" gampang ilang
            # * kontrasnya kalau primary hasil generate wallpaper kebetulan gelap/terang ekstrem
            opacity = 0.85;
          }
        ];
      };

      widget.clock = {
        format = "{:%H:%M} · {:%a, %d %b}";
        tooltip_format = "{:%A, %d %B %Y}";
      };

      # * Biar bisa pake widgets di desktop
      desktop_widgets = {
        enabled = true;
      };

      notification = {
        background_opacity = 0.8;
        scale = 0.85;

        # * Notif "Screenshot saved" ilang lebih cepat, gak numpuk lama-lama di layar
        filter.screenshot = {
          enabled = true;
          match_content = "[Ss]creenshot";
          override_duration = 2500;
        };
      };

      osd = {
        background_opacity = 0.8;
        scale = 0.85;
        position = "bottom_center"; # * bar di top, OSD di bottom biar gak numpuk
      };

      idle = {
        pre_action_fade_seconds = 0;
        # * screenoff HARUS lebih lama dari lock, kalau kebalik layar udah mati
        # * duluan pas lock trigger terus lockscreen kepaksa nyalain layar lagi
        # * (dpms-on) buat nampilin prompt - kerasa "layar nyala lagi sendiri".
        # * lock dipecah -ac/-battery (bukan native action "lock") biar timeout-nya
        # * bisa beda kayak dim/screenoff.
        behavior = {
          dim-ac = {
            enabled = true;
            timeout = 300; # 5 menit, saat di-charge
            action = "command";
            command = "${idlePowerScript} ac dim start";
            resume_command = "${idlePowerScript} ac dim resume";
          };
          lock-ac = {
            enabled = true;
            timeout = 870; # 14.5 menit, saat di-charge
            action = "command";
            command = "${idlePowerScript} ac lock start";
          };
          screenoff-ac = {
            enabled = true;
            timeout = 900; # 15 menit (30 detik setelah lock-ac), saat di-charge
            action = "command";
            command = "${idlePowerScript} ac screen-off start";
            resume_command = "${idlePowerScript} ac screen-off resume";
          };
          dim-battery = {
            enabled = true;
            timeout = 150; # 2.5 menit, saat pakai baterai
            action = "command";
            command = "${idlePowerScript} battery dim start";
            resume_command = "${idlePowerScript} battery dim resume";
          };
          lock-battery = {
            enabled = true;
            timeout = 570; # 9.5 menit, saat pakai baterai
            action = "command";
            command = "${idlePowerScript} battery lock start";
          };
          screenoff-battery = {
            enabled = true;
            timeout = 600; # 10 menit (30 detik setelah lock-battery), saat pakai baterai
            action = "command";
            command = "${idlePowerScript} battery screen-off start";
            resume_command = "${idlePowerScript} battery screen-off resume";
          };
        };
      };
    };
  };

  wayland.windowManager.hyprland.extraConfig = builtins.readFile ./noctalia.lua;

  xdg.configFile = {
    "hypr/modules/noctalia/autostart.lua".source = ./modules/autostart.lua;
    "hypr/modules/noctalia/keybindings.lua".source = ./modules/keybindings.lua;
    "hypr/modules/noctalia/rules.lua".source = ./modules/rules.lua;
    "hypr/modules/noctalia/theme.lua".source = ./modules/theme.lua;

    "noctalia/idle-power.sh" = {
      source = ./idle-power.sh;
      executable = true;
    };

    "noctalia/on-colors-changed.sh" = {
      source = ./on-colors-changed.sh;
      executable = true;
    };

    "noctalia/sticker-random.sh" = {
      source = ./sticker-random.sh;
      executable = true;
    };

    "noctalia/templates/qylock-colors.json.tmpl".source = ./qylock-colors.json.tmpl;
  };
}
