#!/usr/bin/env bash
set -euo pipefail

# * Dipanggil sebagai hooks.wallpaper_changed (lihat default.nix) - jalan tiap
#   wallpaper ganti, baik otomatis (wallpaper.automation) maupun manual lewat
#   keybinding (SUPER+W / SHIFT+W / ALT+W di modules/keybindings.lua).
#
# * Widget desktop diatur manual lewat GUI/settings.toml (bukan Nix), jadi ID
#   sticker-nya di-discover dari settings.toml langsung - bisa berapa aja,
#   nama apa aja, gak perlu tau ID-nya di awal.
#
# * Tiap sticker widget dapet gambar random independen (di-shuffle bareng biar
#   antar-sticker gak kebagian gambar yang sama selama jumlah gambar >= jumlah
#   sticker widget).
state_file="$HOME/.local/state/noctalia/settings.toml"
sticker_dir="$HOME/Pictures/Liked Images Square"

[[ -d "$sticker_dir" && -f "$state_file" ]] || exit 0

mapfile -t sticker_ids < <(awk '
  match($0, /^[ \t]*\[desktop_widgets\.widget\.([A-Za-z0-9_-]+)\]$/, arr) { cur = arr[1]; next }
  /^[ \t]*\[/ { cur = "" }
  cur != "" && $0 ~ /^[ \t]*type[ \t]*=[ \t]*"sticker"$/ { print cur; cur = "" }
' "$state_file" | sort -u)
(( ${#sticker_ids[@]} > 0 )) || exit 0

mapfile -t images < <(find "$sticker_dir" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) | shuf)
(( ${#images[@]} > 0 )) || exit 0

upsert_sticker_image() {
  local id="$1" escaped="$2"
  local header="[desktop_widgets.widget.${id}.settings]"
  local tmp
  tmp="$(mktemp "$(dirname "$state_file")/.sticker-random.XXXXXX")"
  awk -v header="$header" -v newpath="$escaped" '
    BEGIN { in_target = 0; found_header = 0; wrote_path = 0 }
    {
      line = $0
      # Cocokin substring, bukan persis - entry-nya berindentasi (nested under
      # [desktop_widgets.widget.<id>]) sedangkan header di sini flat.
      if (index(line, header) > 0) {
        in_target = 1; found_header = 1
        print line
        next
      }
      if (in_target && line ~ /^[ \t]*\[/) {
        if (!wrote_path) { print "        image_path = \"" newpath "\""; wrote_path = 1 }
        in_target = 0
      }
      if (in_target && line ~ /^[ \t]*image_path[ \t]*=/) {
        sub(/=.*/, "= \"" newpath "\"", line)
        wrote_path = 1
      }
      print line
    }
    END {
      if (in_target && !wrote_path) { print "        image_path = \"" newpath "\"" }
      if (!found_header) {
        print ""
        print header
        print "image_path = \"" newpath "\""
      }
    }
  ' "$state_file" > "$tmp" && mv "$tmp" "$state_file"
}

n=${#images[@]}
i=0
for id in "${sticker_ids[@]}"; do
  picked="${images[i % n]}"
  i=$((i + 1))

  # Escape backslash & double-quote biar valid sebagai TOML basic string
  escaped=${picked//\\/\\\\}
  escaped=${escaped//\"/\\\"}

  upsert_sticker_image "$id" "$escaped"
done
