#!/usr/bin/env bash
# Dipanggil oleh SUPER+panah (lihat modules/hyprland/keybindings.lua).
#
# Fokus terarah bawaan Hyprland (movefocus/hl.dsp.focus({direction=...}))
# di versi ini gak nyebrang antara window tiling dan floating -- keduanya
# domain fokus yang terpisah (dicek langsung di sesi live: dari window
# tiling, panah ke segala arah cuma muter di window tiling lain, gak pernah
# nyentuh window floating, dan sebaliknya; gak ada config option buat ini).
#
# Script ini jalan on-demand tiap keypress (bukan daemon background): coba
# fokus arah biasa dulu, kalau ternyata gak pindah (gak ada tetangga di
# domain yang sama ke arah itu), cari window terdekat di domain SEBALIKNYA
# (tiling<->floating) di workspace yang sama, ke arah yang sesuai, lalu
# fokus ke situ manual.

set -uo pipefail

dir="$1" # left|right|up|down

before=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')
[[ -n "$before" ]] || exit 0

hyprctl dispatch "hl.dsp.focus({direction='$dir'})" >/dev/null

after=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')
[[ "$after" == "$before" ]] || exit 0

info=$(hyprctl activewindow -j 2>/dev/null)
ws=$(jq -r '.workspace.id' <<<"$info")
floating=$(jq -r '.floating' <<<"$info")
x=$(jq -r '.at[0]' <<<"$info")
y=$(jq -r '.at[1]' <<<"$info")
w=$(jq -r '.size[0]' <<<"$info")
h=$(jq -r '.size[1]' <<<"$info")
cx=$((x + w / 2))
cy=$((y + h / 2))

target=$(hyprctl clients -j 2>/dev/null | jq -r \
    --argjson ws "$ws" --argjson floating "$floating" \
    --argjson cx "$cx" --argjson cy "$cy" --arg dir "$dir" '
    map(select(.workspace.id == $ws and .floating != $floating))
    | map(. + {ccx: (.at[0] + .size[0] / 2), ccy: (.at[1] + .size[1] / 2)})
    | map(select(
        if $dir == "left" then .ccx < $cx
        elif $dir == "right" then .ccx > $cx
        elif $dir == "up" then .ccy < $cy
        else .ccy > $cy end
      ))
    | sort_by(((.ccx - $cx) * (.ccx - $cx)) + ((.ccy - $cy) * (.ccy - $cy)))
    | (.[0].address // empty)
')

[[ -n "$target" ]] || exit 0
hyprctl dispatch "hl.dsp.focus({window='address:$target'})" >/dev/null
