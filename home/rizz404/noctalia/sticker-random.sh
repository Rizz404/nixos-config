#!/usr/bin/env bash
set -euo pipefail

# * Dipanggil sebagai hooks.wallpaper_changed (lihat default.nix) - jalan tiap
#   wallpaper ganti, baik otomatis (wallpaper.automation) maupun manual lewat
#   keybinding (SUPER+W / SHIFT+W / ALT+W di modules/keybindings.lua). Pilih 1
#   gambar random dari folder sticker, lalu timpa image_path widget bertipe
#   "sticker" di runtime state (settings.toml) - file itu di-watch inotify
#   jadi sticker di desktop langsung ganti tanpa perlu reload manual.
sticker_dir="$HOME/Pictures/Liked Images Square"
state_file="$HOME/.local/state/noctalia/settings.toml"

[[ -d "$sticker_dir" && -f "$state_file" ]] || exit 0

mapfile -t images < <(find "$sticker_dir" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \))
(( ${#images[@]} > 0 )) || exit 0

picked="${images[RANDOM % ${#images[@]}]}"

# Escape backslash & double-quote biar valid sebagai TOML basic string
escaped=${picked//\\/\\\\}
escaped=${escaped//\"/\\\"}

tmp="$(mktemp "$(dirname "$state_file")/.sticker-random.XXXXXX")"
awk -v newpath="$escaped" '
  { lines[NR] = $0 }
  END {
    id = ""
    cur_id = ""
    for (i = 1; i <= NR; i++) {
      if (match(lines[i], /^ *\[desktop_widgets\.widget\.([A-Za-z0-9_-]+)\]$/, arr)) {
        cur_id = arr[1]
      }
      if (cur_id != "" && lines[i] ~ /^ *type *= *"sticker"$/) {
        id = cur_id
      }
    }
    if (id == "") {
      for (i = 1; i <= NR; i++) print lines[i]
      exit
    }
    header = "[desktop_widgets.widget." id ".settings]"
    in_target = 0
    for (i = 1; i <= NR; i++) {
      line = lines[i]
      if (index(line, header) > 0) {
        in_target = 1
      } else if (in_target && line ~ /^ *\[/) {
        in_target = 0
      }
      if (in_target && line ~ /^ *image_path *=/) {
        sub(/=.*/, "= \"" newpath "\"", line)
      }
      print line
    }
  }
' "$state_file" > "$tmp" && mv "$tmp" "$state_file"
