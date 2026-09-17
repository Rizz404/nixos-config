#!/usr/bin/env bash
set -euo pipefail

# * Workaround bug casing di template kcolorscheme Noctalia - lihat komentar
#   theme.hooks.colors_changed di default.nix.
plasma-apply-colorscheme noctalia

# * Ekspor path wallpaper aktif ke ~/.config/qylock/wallpaper.txt biar theme
#   login screen (SDDM, lihat ~/qylock/themes/noctalia-sync) bisa nunjukin
#   wallpaper yang sama kayak yang lagi aktif di desktop.
state_file="$HOME/.local/state/noctalia/settings.toml"
out_dir="$HOME/.config/qylock"
mkdir -p "$out_dir"
awk '
  /^\[wallpaper\.last\]/ { in_section = 1; next }
  /^\[/ { in_section = 0 }
  in_section && /^path/ { gsub(/^path *= *"|"$/, ""); print; exit }
' "$state_file" > "$out_dir/wallpaper.txt"
