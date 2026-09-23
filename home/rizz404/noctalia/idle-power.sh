#!/usr/bin/env bash
# Dim/restore brightness, screen off/on, ATAU lock dari idle behavior Noctalia
# (lihat default.nix -> settings.idle.behavior).
#
# Noctalia gak punya kondisional bawaan buat "beda timeout kalau lagi
# charge vs enggak" — cuma named behavior + timeout tetap per nama. Makanya
# tiap mode (dim, lock) didefinisikan DUA behavior (varian -ac timeout
# panjang, varian -battery timeout pendek) yang jalan berbarengan, tapi
# masing-masing cek sendiri status charging saat itu lewat script ini dan
# no-op kalau timernya "gak nyambung" sama kondisi aktual (misal varian
# battery keburu nyala pas laptop lagi di-charge -> dibiarin aja).
#
# mode "lock" sengaja gabungin dpms-off (screen off) + session lock dalam
# SATU behavior (bukan 2 behavior terpisah kayak dulu). Alasannya: bug
# upstream Noctalia (github.com/noctalia-dev/noctalia/issues/4190) -
# munculnya lockscreen bikin idle daemon keliru nge-"resume" behavior lain
# yang udah kepicu duluan (mis. dim jadi balik terang lagi), padahal
# seharusnya cuma re-arm buat siklus berikutnya. Kalau screen-off jadi
# behavior TERPISAH yang nyala belakangan (kayak dulu), dia sendiri kena
# reset itu tiap kali lock nyala duluan - efeknya layar gak pernah beneran
# mati. Fix-nya: dpms-off dijalanin LEBIH DULU, baru lock - jadi pas
# lockscreen muncul & idle daemon keliru resume, backlight udah mati duluan
# jadi gak keliatan efeknya (dim yang ke-resume juga gak masalah, wong
# layarnya mati).
#
# lock & dpms dipakai lewat `noctalia msg ...` (bukan native action
# "lock"/"screen_off") biar bisa di-gate per tier kayak di atas.
#
# $1 = tier yang mau dicek ("ac" atau "battery")
# $2 = mode ("dim" atau "lock")
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
    lock-start)
        noctalia msg dpms-off
        noctalia msg session lock
        ;;
    lock-resume)
        noctalia msg dpms-on
        ;;
esac
