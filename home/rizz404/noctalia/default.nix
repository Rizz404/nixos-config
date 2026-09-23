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
        # * Default (mru=false) urutin window ikut workspace/posisi, kerasa "acak"
        # * pas alt-tab. mru=true bikin urutannya ikut window yang terakhir
        # * dipakai duluan, kayak behavior Windows/KDE.
        window_switcher = {
          mru = true;
        };
        screenshot = {
          directory = "~/Pictures/Screenshots";
          show_cursor = true;
        };
      };

      theme = {
        mode = "auto";
        shell_mode = "auto";
        source = "wallpaper";
        builtin = "Catppuccin";
        community_palette = "Oxocarbon";
        wallpaper_scheme = "m3-content";
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
            members = [ "launcher" "taskbar" ];
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

      widget.taskbar = {
        # * Fitur inti: kelompokin icon app per-workspace biar keliatan
        # * app apa aja yang jalan di tiap workspace, bukan cuma pill kosong
        group_by_workspace = true;
        workspace_group_content = "icons";
        group_single_icon_per_app = true; # * >1 window Discord di 1 workspace = 1 icon

        # * Tetep kompak - cuma tampilin workspace yang ada isinya. 10 workspace
        # * dari keybindings.lua gak bakal bikin taskbar selebar itu.
        hide_empty_workspaces = true;
        only_active_workspace = false; # * justru mau liat SEMUA workspace terisi

        show_workspace_label = true;
        workspace_label_placement = "corner";
        workspace_group_capsule = true; # * border/bg per-grup biar batas antar-workspace jelas

        show_all_outputs = false;
        focused_output_only = false;

        icon_scale = 0.9; # * dikit lebih kecil biar muat lebih banyak app
        show_active_indicator = true;
        active_indicator_color = "primary";
        active_opacity = 1.0;
        inactive_opacity = 0.75;

        focused_color = "primary";
        occupied_color = "on_surface";
        empty_color = "outline";
        urgent_color = "error";
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
        # * lock & screen-off DIGABUNG jadi satu behavior (bukan screenoff
        # * terpisah 30 detik setelah lock kayak dulu) - workaround bug upstream
        # * Noctalia (github.com/noctalia-dev/noctalia/issues/4190) yang bikin
        # * lockscreen muncul keliru nge-"resume" behavior lain yang udah
        # * kepicu duluan (layar jadi terang lagi alih-alih mati). Detail di
        # * idle-power.sh. Hapus workaround ini kalau upstream udah fix (PR #4002).
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
            resume_command = "${idlePowerScript} ac lock resume";
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
            resume_command = "${idlePowerScript} battery lock resume";
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
