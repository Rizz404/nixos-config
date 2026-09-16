#!/usr/bin/env bash
# Toggle "peek desktop": stash semua window di workspace aktif ke special
# workspace tersembunyi (jadi keliatan desktop kosong), atau balikin lagi
# kalau udah di-stash.
#
# Hyprland versi ini (config Lua) bikin `hyprctl dispatch` expect syntax Lua
# (`hl.dsp.*`), bukan syntax classic "dispatcher arg1,arg2" lagi — makanya
# dipanggil lewat hl.dsp.window.move(), bukan movetoworkspacesilent mentah.
#
# Window yang dipindah pakai `follow = false` gak otomatis dapet fokus
# keyboard (input.follow_mouse=1 di hyprland.lua bikin fokus cuma nempel
# kalau kursor digerakin ke atasnya), jadi window yang tadi fokus sebelum
# di-peek disimpen ke state_file, terus di-fokusin eksplisit lagi pas balik.

state_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-peek-focus"
active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
stashed=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "special:peek")] | length')

if [ "$stashed" -gt 0 ]; then
    mapfile -t addrs < <(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:peek") | .address')
    for addr in "${addrs[@]}"; do
        hyprctl dispatch "hl.dsp.window.move({ window = \"address:$addr\", workspace = $active_ws, follow = false })"
    done

    if [ -s "$state_file" ]; then
        prev_addr=$(cat "$state_file")
        hyprctl dispatch "hl.dsp.focus({ window = \"address:$prev_addr\" })"
        rm -f "$state_file"
    fi
else
    focused_addr=$(hyprctl activewindow -j | jq -r '.address // empty')
    if [ -n "$focused_addr" ]; then
        printf '%s' "$focused_addr" > "$state_file"
    else
        rm -f "$state_file"
    fi

    mapfile -t addrs < <(hyprctl clients -j | jq -r --argjson ws "$active_ws" '.[] | select(.workspace.id == $ws) | .address')
    for addr in "${addrs[@]}"; do
        hyprctl dispatch "hl.dsp.window.move({ window = \"address:$addr\", workspace = \"special:peek\", follow = false })"
    done
fi
