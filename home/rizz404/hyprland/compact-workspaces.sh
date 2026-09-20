#!/usr/bin/env bash
# Rapetin workspace bernomor 1-10: tutup celah workspace kosong dengan geser
# semua window dari workspace yang lebih tinggi turun satu-satu slot kosong
# (mis. ws2 kosong -> ws3 jadi ws2, ws4 jadi ws3, dst), biar gak perlu
# mindahin window manual satu-satu atau ngelewatin workspace kosong pas mau
# nyampe ke workspace terakhir.
#
# Sama kayak peek-desktop.sh: dispatch lewat hl.dsp.window.move() karena
# config Lua Hyprland versi ini expect syntax itu, bukan
# "movetoworkspacesilent" mentah.

clients_json=$(hyprctl clients -j)
active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
new_active_ws=""

write=1
for src in $(seq 1 10); do
    addrs=$(jq -r --argjson ws "$src" '.[] | select(.workspace.id == $ws) | .address' <<< "$clients_json")
    [ -z "$addrs" ] && continue

    if [ "$src" -eq "$active_ws" ]; then
        new_active_ws="$write"
    fi

    if [ "$src" -ne "$write" ]; then
        while IFS= read -r addr; do
            hyprctl dispatch "hl.dsp.window.move({ window = \"address:$addr\", workspace = $write, follow = false })"
        done <<< "$addrs"
    fi

    write=$((write + 1))
done

# Workspace aktif kosong (kasus umum: abis nutup semua window di situ) -
# biarin tetep di nomor yang sama, nanti keisi sendiri kalau ada yang digeser
# masuk. Kalau workspace aktif itu sendiri yang ikut digeser, ikutin fokusnya.
if [ -n "$new_active_ws" ] && [ "$new_active_ws" -ne "$active_ws" ]; then
    hyprctl dispatch "hl.dsp.focus({ workspace = $new_active_ws })"
fi
