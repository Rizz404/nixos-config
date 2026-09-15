# Hyprland × Noctalia — Keybinding Cheatsheet

Diambil langsung dari config di `~/nixos-config`:
- `home/rizz404/hyprland/hyprland.lua`
- `home/rizz404/noctalia/noctalia.lua`

File Noctalia di-*import* **setelah** file Hyprland (lihat `home/rizz404/default.nix`),
jadi kalau ada bind yang sama, Noctalia yang menang.

> **Gaya keybinding:** modifier dibuat bervariasi (gak melulu `SUPER`) — beberapa pakai
> `ALT` (gaya KDE/Windows: Alt+F4, Alt+Tab, Alt+Space) dan beberapa pakai `CTRL+ALT`
> atau `CTRL+SUPER` buat shortcut tambahan ala Windows.

---

## Aplikasi

| Keybind | Aksi |
|---|---|
| `CTRL + ALT + T` | Buka terminal (`wezterm`) |
| `SUPER + E` | Buka file manager (`dolphin`) |
| `SUPER + R` | App launcher (`hyprlauncher`) |
| `ALT + Space` | Noctalia launcher panel (gaya KRunner KDE) |

## Window

| Keybind | Aksi |
|---|---|
| `ALT + F4` | Tutup window fokus |
| `F11` / `SUPER + F` | Toggle fullscreen |
| `SUPER + P` | Toggle pseudotile |
| `SUPER + J` | Toggle split (khusus layout dwindle) |
| `SUPER + drag LMB` | Pindah window (`mouse:272`) |
| `SUPER + drag RMB` | Resize window (`mouse:273`) |
| Setiap app baru dibuka | Otomatis fullscreen (window rule `auto-fullscreen`, lihat catatan di bawah) |

## Fokus & Navigasi

| Keybind | Aksi |
|---|---|
| `SUPER + ←↑↓→` | Pindah fokus arah panah |
| `SUPER + scroll` | Geser workspace berikutnya/sebelumnya |
| 3-finger swipe (touchpad, horizontal) | Ganti workspace |

## Workspace & Desktop

| Keybind | Aksi |
|---|---|
| `SUPER + 0-9` | Pindah ke workspace 1-10 (`0` = workspace 10) |
| `CTRL + SUPER + 0-9` | Sama seperti di atas — shortcut alternatif ala Windows |
| `CTRL + SUPER + ←/→` | Pindah ke workspace sebelumnya/berikutnya berurutan (ala Windows) |
| `SUPER + SHIFT + 0-9` | Pindahkan window ke workspace itu |
| `SUPER + S` | Toggle scratchpad (special workspace `"magic"`) |
| `SUPER + SHIFT + S` | Kirim window ke scratchpad |
| `SUPER + M` / `SUPER + SHIFT + M` | Peek desktop — toggle ke special workspace kosong `"peek"` (emulasi "show desktop" Windows, Hyprland gak punya minimize beneran) |
| `CTRL + ALT + Delete` | Power menu Noctalia (lock/suspend/logout/reboot/shutdown dalam satu popup, gaya KDE) |

## Noctalia Shell

| Keybind | Aksi |
|---|---|
| `ALT + Space` | Toggle launcher panel |
| `SUPER + N` | Toggle control center |
| `SUPER + ,` | Toggle jendela settings Noctalia |
| `SUPER + L` | Kunci sesi (session lock) |
| `SUPER + V` | Clipboard history (panel bawaan Noctalia, gaya Win+V / Klipper) |
| `ALT + Tab` | Window switcher (overlay grid Noctalia) |

## Screenshot

| Keybind | Aksi |
|---|---|
| `Print` | Screenshot monitor fokus, auto-save ke `~/Pictures/Screenshots` + copy ke clipboard |
| `SUPER + Print` | Screenshot region (pilih area interaktif) |
| `SUPER + SHIFT + Print` | Freeze layar + anotasi (coret-coret) sebelum simpan/copy |

## Media & Laptop

*(locked + repeating, jalan di layer manapun)*

| Tombol | Aksi |
|---|---|
| Volume +/- | `wpctl set-volume` ±5% |
| Mute | Toggle mute output/mic |
| Brightness +/- | `brightnessctl` ±5% |
| ▶ ⏸ ⏮ ⏭ | `playerctl` play/pause/prev/next |

---

## Catatan hasil review terakhir

Sudah dicek ulang seluruh `hyprland.lua` + `noctalia.lua`, dan disilangkan ke type-stub
resmi Hyprland (`hl.meta.lua`) buat mastiin semua `hl.dsp.*`/`hl.window_rule` yang dipakai
valid. Dua hal yang perlu kamu perhatiin (bukan syntax error, tapi perilaku yang mungkin
gak sesuai niat):

1. **Rule `auto-fullscreen` (window rule terbaru) ikut nge-fullscreen-in `hyprland-run`.**
   Rule itu match semua class kecuali `dev.noctalia.Noctalia`, padahal ada rule lama
   `move-hyprland-run` yang niatnya bikin window `hyprland-run` jadi popup kecil di
   pojok (float + posisi manual) — sekarang malah ketiban fullscreen juga. Kalau mau
   dibetulin, tambahin exclude-nya:
   ```lua
   match = { class = "^(?!dev\\.noctalia\\.Noctalia$|hyprland-run$).*$" }
   ```
   Dampak sama juga (lebih kecil) ke rule `fix-xwayland-drags` (window helper drag
   XWayland, class kosong) — biasanya invisible jadi gak terlalu kerasa, tapi FYI.

2. **Belum sempat dites langsung** (gak ada koneksi live ke socket Hyprland dari sini):
   pastiin `F11`/`SUPER+F` beneran bisa keluar dari fullscreen tanpa langsung
   ke-force balik lagi sama rule `auto-fullscreen`. Kalau ternyata balik otomatis,
   window rule statisnya kemungkinan re-enforce terus-terusan — kabarin aja kalau itu
   terjadi, nanti dicariin cara lain (misal lewat `on_created_empty` di workspace rule).

---

*Sumber: `home/rizz404/hyprland/hyprland.lua`, `home/rizz404/noctalia/noctalia.lua`
(+ `default.nix` keduanya) di repo `nixos-config`, disilangkan dengan type-stub resmi
`hl.meta.lua` dari package Hyprland, [wiki.hypr.land](https://wiki.hypr.land/configuring/core/binds/),
dan `noctalia msg --help` yang dites langsung ke instance Noctalia yang jalan.
Layout dwindle (default host ini) — beberapa bind seperti `SUPER+J` khusus berlaku
di layout itu.*
