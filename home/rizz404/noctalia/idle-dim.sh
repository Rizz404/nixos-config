#!/usr/bin/env bash
# Dim/restore brightness dari idle behavior Noctalia (lihat default.nix ->
# settings.idle.behavior.dim-ac / dim-battery).
#
# Noctalia gak punya kondisional bawaan buat "beda timeout kalau lagi
# charge vs enggak" — cuma named behavior + timeout tetap per nama. Makanya
# didefinisikan DUA behavior (dim-ac timeout panjang, dim-battery timeout
# pendek) yang jalan berbarengan, tapi masing-masing cek sendiri status
# charging saat itu lewat script ini dan no-op kalau timernya "gak nyambung"
# sama kondisi aktual (misal dim-battery keburu nyala pas laptop lagi
# di-charge -> dibiarin aja, gak dim).
#
# $1 = tier yang mau dicek ("ac" atau "battery")
# $2 = phase ("dim" atau "resume")

set -euo pipefail

tier="$1"
phase="$2"
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

case "$phase" in
    dim)
        brightnessctl -s set "$dim_brightness" >/dev/null
        ;;
    resume)
        brightnessctl -r >/dev/null
        ;;
esac
