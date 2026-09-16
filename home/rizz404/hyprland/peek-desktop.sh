#!/usr/bin/env bash
# Toggle "peek desktop": stash semua window di workspace aktif ke special
# workspace tersembunyi (jadi keliatan desktop kosong), atau balikin lagi
# kalau udah di-stash.
#
# Hyprland versi ini (config Lua) bikin `hyprctl dispatch` expect syntax Lua
# (`hl.dsp.*`), bukan syntax classic "dispatcher arg1,arg2" lagi — makanya
# dipanggil lewat hl.dsp.window.move(), bukan movetoworkspacesilent mentah.

active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
stashed=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "special:peek")] | length')

if [ "$stashed" -gt 0 ]; then
    hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:peek") | .address' |
        while read -r addr; do
            hyprctl dispatch "hl.dsp.window.move({ window = \"address:$addr\", workspace = $active_ws, follow = false })"
        done
else
    hyprctl clients -j | jq -r --argjson ws "$active_ws" \
        '.[] | select(.workspace.id == $ws) | .address' |
        while read -r addr; do
            hyprctl dispatch "hl.dsp.window.move({ window = \"address:$addr\", workspace = \"special:peek\", follow = false })"
        done
fi
