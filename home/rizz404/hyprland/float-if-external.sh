#!/usr/bin/env bash
# Floats window baru yang dibuka sebagai efek samping dari app lain yang
# sedang berjalan (mis. "open containing folder", "open with", handler
# mailto/link dari chat app) — bukan yang dibuka langsung oleh user lewat
# keybind, app launcher, atau diketik di terminal.
#
# Hyprland window rule gak bisa deteksi "siapa yang membuka window ini"
# (cuma bisa match class/title/dll milik window itu sendiri), jadi ini jalan
# reaktif: dengar event openwindow dari socket Hyprland, telusuri ancestry
# proses window yang baru dibuka, lalu float kalau ancestor pertama yang
# bukan wrapper tipis (sh/bash/xdg-open/dll) bukan salah satu launcher yang
# dipercaya.
#
# CATATAN: karena ini reaktif (window sempat ke-tile dulu sebelum di-float),
# bukan static window rule (yang diterapkan sebelum window pertama kali
# di-render), ini menggantikan rule lama "float-dolphin" yang statis. Kalau
# bug render Dolphin yang lama (lihat riwayat windowrules.lua) balik lagi
# khusus untuk trigger eksternal, kemungkinan perlu rule statis lagi sebagai
# fallback -- tapi coba dulu pendekatan ini.
#
# Dijalankan sekali saat Hyprland start, lihat modules/hyprland/autostart.lua.

set -uo pipefail

SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Comm name (/proc/<pid>/comm, max 15 char) yang dianggap "user membuka ini
# langsung": Hyprland sendiri (keybind exec_cmd / autostart), launcher app,
# dan terminal. Tambahin di sini kalau ada launcher lain yang perlu dipercaya.
TRUSTED_LAUNCHERS="Hyprland|noctalia|hyprlauncher|wezterm-gui|wezterm"

# Wrapper exec tipis yang gak dihitung sebagai "launcher" itu sendiri --
# dilewatin pas nelusurin ancestor buat nyari yang beneran.
TRANSPARENT_WRAPPERS="sh|bash|fish|zsh|dash|env|xdg-open"

# Cegah dobel instance (mis. kalau script ini ke-invoke ulang manual).
LOCK="${XDG_RUNTIME_DIR:-/tmp}/float-if-external.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0

launched_directly() {
    local pid="$1" hops=0 comm ppid
    while ((hops < 15)) && [[ -r "/proc/$pid/stat" ]]; do
        comm=$(</proc/"$pid"/comm) || return 1
        if [[ "$comm" =~ ^(${TRUSTED_LAUNCHERS})$ ]]; then
            return 0
        fi
        if [[ ! "$comm" =~ ^(${TRANSPARENT_WRAPPERS})$ ]]; then
            return 1
        fi
        ppid=$(awk '{print $4}' "/proc/$pid/stat") || return 1
        [[ "$ppid" == "1" ]] && return 1
        pid="$ppid"
        hops=$((hops + 1))
    done
    return 1
}

while true; do
    nc -U "$SOCK" 2>/dev/null | while IFS= read -r line; do
        [[ "$line" == openwindow\>\>* ]] || continue

        addr="${line#openwindow>>}"
        addr="${addr%%,*}"
        addr="${addr#0x}"
        [[ -n "$addr" ]] || continue

        pid=""
        for _ in 1 2 3; do
            pid=$(hyprctl clients -j 2>/dev/null |
                jq -r --arg a "0x$addr" '.[] | select(.address == $a) | .pid' | head -n1)
            [[ -n "$pid" && "$pid" != "null" ]] && break
            sleep 0.05
        done
        [[ -n "$pid" && "$pid" != "null" ]] || continue

        # NB: hyprctl dispatch di build Hyprland-Lua ini gak nerima syntax
        # classic "dispatch <nama> <args>" (di-parse sebagai Lua -> error
        # syntax) -- harus lewat hl.dsp.window.float({...}), dikonfirmasi
        # langsung di sesi live.
        launched_directly "$pid" ||
            hyprctl dispatch "hl.dsp.window.float({action='on', window='address:0x$addr'})" >/dev/null
    done
    sleep 1
done
