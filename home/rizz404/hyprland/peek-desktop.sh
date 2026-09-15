#!/usr/bin/env bash
# Toggle "peek desktop": stash semua window di workspace aktif ke special
# workspace tersembunyi (jadi keliatan desktop kosong), atau balikin lagi
# kalau udah di-stash.

active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
stashed=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "special:peek")] | length')

if [ "$stashed" -gt 0 ]; then
    hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:peek") | .address' |
        while read -r addr; do
            hyprctl dispatch movetoworkspacesilent "$active_ws,address:$addr"
        done
else
    hyprctl clients -j | jq -r --argjson ws "$active_ws" \
        '.[] | select(.workspace.id == $ws) | .address' |
        while read -r addr; do
            hyprctl dispatch movetoworkspacesilent "special:peek,address:$addr"
        done
fi
