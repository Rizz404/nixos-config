#!/usr/bin/env bash
# Dim/restore brightness, screen off/on, ATAU lock dari idle behavior Noctalia
# (lihat default.nix -> settings.idle.behavior).
#
# Noctalia gak punya kondisional bawaan buat "beda timeout kalau lagi
# charge vs enggak" — cuma named behavior + timeout tetap per nama. Makanya
# tiap mode (dim, screen-off, lock) didefinisikan DUA behavior (varian -ac
# timeout panjang, varian -battery timeout pendek) yang jalan berbarengan,
# tapi masing-masing cek sendiri status charging saat itu lewat script ini
# dan no-op kalau timernya "gak nyambung" sama kondisi aktual (misal varian
# battery keburu nyala pas laptop lagi di-charge -> dibiarin aja).
#
# screen-off dipakai lewat `noctalia msg dpms-*` (bukan native action
# "screen_off") justru biar bisa di-gate per tier kayak di atas; efeknya
# sama, cuma monitor mati, BUKAN suspend/sleep.
#
# lock juga lewat `noctalia msg session lock` (bukan native action "lock")
# dengan alasan sama - biar timeout-nya beda antara AC & baterai. Gak ada
# fase "resume" buat lock (unlock-nya lewat password di lockscreen, bukan
# idle resume kayak dim/screen-off).
#
# $1 = tier yang mau dicek ("ac" atau "battery")
# $2 = mode ("dim", "screen-off", atau "lock")
# $3 = phase ("start" atau "resume")

set -euo pipefail

tier="$1"
mode="$2"
phase="$3"
dim_brightness="20%"

is_on_ac() {
    local found_battery=0

    for supply in /sys/class/power_supply/*/; do
        [ -r "${supply}type" ] || continue
        case "$(<"${supply}type")" in
            Battery)
                found_battery=1
                ;;
            Mains | USB)
                if [ -r "${supply}online" ] && [ "$(<"${supply}online")" = "1" ]; then
                    return 0
                fi
                ;;
        esac
    done

    # Gak ada battery report sama sekali (mis. desktop/mini-PC) -> anggap
    # selalu nyolok listrik, pakai timeout "ac".
    [ "$found_battery" -eq 0 ]
}

if is_on_ac; then
    current_tier="ac"
else
    current_tier="battery"
fi

[ "$tier" = "$current_tier" ] || exit 0

case "$mode-$phase" in
    dim-start)
        brightnessctl -s set "$dim_brightness" >/dev/null
        ;;
    dim-resume)
        brightnessctl -r >/dev/null
        ;;
    screen-off-start)
        noctalia msg dpms-off
        ;;
    screen-off-resume)
        noctalia msg dpms-on
        ;;
    lock-start)
        noctalia msg session lock
        ;;
esac
