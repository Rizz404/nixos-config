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
          # hyprland = border window, wezterm = terminal, gtk3/gtk4/qt = app non-KDE,
          # kcolorscheme = Dolphin & app KDE lain
          builtin_ids = [ "hyprland" "wezterm" "gtk3" "gtk4" "qt" "kcolorscheme" ];

          enable_community_templates = true;
          # vscode sengaja gak dipakai - settings.json-nya di-sync ke perangkat non-Linux juga
          community_ids = [ "brave" ];

          # * Template custom buat theme SDDM noctalia-sync - lihat
          #   ~/qylock/themes/noctalia-sync/Main.qml (loadNoctaliaColors()).
          user.qylock-colors = {
            input_path = "${config.home.homeDirectory}/.config/noctalia/templates/qylock-colors.json.tmpl";
            output_path = "${config.home.homeDirectory}/.config/qylock/colors.json";
          };
        };
      };

      nightlight = {
        enabled = true;
      };

      # * Lockscreen native Noctalia - wallpaper & warna otomatis ikut wallpaper aktif
      #   ("wallpaper" field dikosongin = pakai desktop wallpaper), gak butuh plumbing
      #   custom kayak percobaan qylock kemarin.
      #   blurred_desktop = false (bukan live screenshot) biar konsisten sama login
      #   screen (~/qylock/themes/noctalia-sync) - itu cuma bisa akses wallpaper file,
      #   gak bisa screenshot desktop yang belum ada sesinya.
      lockscreen = {
        enabled = true;
        blurred_desktop = false;
        blur_intensity = 0.6;
        tint_intensity = 0.35;
      };

      location = {
        auto_locate = true;
      };

      # * colors_changed fire tiap palette regenerate (termasuk auto wallpaper
      #   rotation) - dipakai buat 2 hal, lihat on-colors-changed.sh: (1) koreksi
      #   bug casing template kcolorscheme Noctalia (nulis "ColorScheme=Noctalia"
      #   tapi scheme yang ke-generate namanya "noctalia" huruf kecil, bikin KDE
      #   apps fallback ke default), dan (2) ekspor path wallpaper aktif buat
      #   login screen custom (~/qylock/themes/noctalia-sync).
      hooks = {
        colors_changed = onColorsChangedScript;
        # * wallpaper_changed fire tiap wallpaper aktif ganti - otomatis (wallpaper.automation
        #   di bawah) maupun manual lewat keybinding SUPER+W/SHIFT+W/ALT+W (lihat
        #   modules/keybindings.lua). sticker-random.sh milih 1 gambar random dari
        #   ~/Pictures/Liked Images Square dan nimpa image_path widget sticker di desktop.
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

      # Bar "4 pulau" (capsule_group) - lihat docs/noctalia-ricing-guide.md section 3
      bar.default = {
        position = "top";
        enabled = true;
        thickness = 32;
        radius = 16;
        margin_ends = 0;
        margin_edge = 4;
        # * 0 = gak nambah reserved space ekstra selain gaps_out Hyprland (appearance.lua),
        #   biar window bisa mepet bar tanpa dead-space dobel
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
            #   kontrasnya kalau primary hasil generate wallpaper kebetulan gelap/terang ekstrem
            opacity = 0.85;
          }
        ];
      };

      widget.clock = {
        format = "{:%H:%M} · {:%a, %d %b}";
        tooltip_format = "{:%A, %d %B %Y}";
      };

      # Desktop widgets - lihat docs/noctalia-ricing-guide.md section 11.
      # Widget individualnya sengaja gak dideklarasi di sini - posisinya (cx/cy) cuma
      # bisa ditentuin dengan bener lewat edit mode (Settings -> Desktop -> Toggle
      # Editor), yang nulis ke settings.toml. Baru promote ke sini kalau udah final
      # (Settings -> Export Config -> Merged User Config).
      desktop_widgets = {
        enabled = true;
      };

      # Dock - lihat docs/noctalia-ricing-guide.md section 4
      # dock = {
      #   enabled = true;
      #   position = "bottom";
      #   icon_size = 44;
      #   radius = 20;
      #   margin_edge = 8;
      #   background_opacity = 0.55;
      #   magnification = true;
      #   magnification_scale = 1.4;
      #   show_running = true;
      #   auto_hide = true;

      #   # Desktop entry ID stem - urutan ini yang muncul di dock
      #   pinned = [
      #     "org.kde.dolphin" # Dolphin
      #     "dev.noctalia.Noctalia" # Noctalia (lihat catatan di bawah)
      #     "brave-browser" # Brave
      #     "org.wezfurlong.wezterm" # WezTerm
      #     "code" # VS Code
      #   ];
      # };

      # Notification & OSD - lihat docs/noctalia-ricing-guide.md section 5.
      # Warna ikut wallpaper otomatis (theme.source = "wallpaper" di atas), jadi cuma
      # perlu atur transparansi. scale ini global per-jenis (gak ada per-tipe toast/OSD),
      # jadi diturunin dikit biar semua kerasa lebih compact termasuk capslock OSD.
      notification = {
        background_opacity = 0.8;
        scale = 0.85;

        # Notif "Screenshot saved" ilang lebih cepat, gak numpuk lama-lama di layar
        filter.screenshot = {
          enabled = true;
          match_content = "[Ss]creenshot";
          override_duration = 2500;
        };
      };

      osd = {
        background_opacity = 0.8;
        scale = 0.85;
        position = "bottom_center"; # bar di top, OSD di bottom biar gak numpuk
      };

      idle = {
        pre_action_fade_seconds = 0;
        behavior = {
          lock = {
            enabled = true;
            timeout = 900; # 15 menit
            action = "lock";
          };
          dim-ac = {
            enabled = true;
            timeout = 300; # 5 menit, saat di-charge
            action = "command";
            command = "${idlePowerScript} ac dim start";
            resume_command = "${idlePowerScript} ac dim resume";
          };
          screenoff-ac = {
            enabled = true;
            timeout = 600; # 10 menit, saat di-charge
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
          screenoff-battery = {
            enabled = true;
            timeout = 300; # 5 menit, saat pakai baterai
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
