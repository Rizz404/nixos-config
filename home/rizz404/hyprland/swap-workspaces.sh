#!/usr/bin/env bash
# Tukar semua window antara workspace aktif dengan workspace tujuan ($1).
# Dipanggil oleh SUPER+CTRL+SHIFT+[0-9] (lihat modules/hyprland/keybindings.lua).
#
# Beda dari "move to workspace" (SUPER+SHIFT+n) yang cuma mindahin window
# aktif doang -- ini nuker ISI dua workspace: semua window di workspace
# aktif pindah ke workspace tujuan, dan sebaliknya. Nomor workspace aktif
# gak berubah (fokus gak ikut window), cuma kontennya yang ketuker.

set -uo pipefail

target_ws="$1"
active_ws=$(hyprctl activeworkspace -j | jq -r '.id')

[ "$target_ws" -eq "$active_ws" ] && exit 0

clients_json=$(hyprctl clients -j)

active_addrs=$(jq -r --argjson ws "$active_ws" '.[] | select(.workspace.id == $ws) | .address' <<< "$clients_json")
target_addrs=$(jq -r --argjson ws "$target_ws" '.[] | select(.workspace.id == $ws) | .address' <<< "$clients_json")

if [ -z "$active_addrs" ] && [ -z "$target_addrs" ]; then
    exit 0
fi

while IFS= read -r addr; do
    [ -z "$addr" ] && continue
    hyprctl dispatch "hl.dsp.window.move({ window = 'address:$addr', workspace = $target_ws, follow = false })"
done <<< "$active_addrs"

while IFS= read -r addr; do
    [ -z "$addr" ] && continue
    hyprctl dispatch "hl.dsp.window.move({ window = 'address:$addr', workspace = $active_ws, follow = false })"
done <<< "$target_addrs"
