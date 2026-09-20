# Hyprland × Noctalia — Keybinding Cheatsheet

Diambil langsung dari config di `~/nixos-config`:
- `home/rizz404/hyprland/hyprland.lua` (+ `modules/keybindings.lua`, `modules/input.lua`)
- `home/rizz404/noctalia/noctalia.lua` (+ `modules/keybindings.lua`)

File Noctalia di-*import* **setelah** file Hyprland (lihat `home/rizz404/default.nix`),
jadi kalau ada bind yang sama, Noctalia yang menang.

> **Gaya keybinding:** modifier dibuat bervariasi (gak melulu `SUPER`) — beberapa pakai
> `ALT` (gaya KDE/Windows: Alt+F4, Alt+Tab, Alt+Space) dan beberapa pakai `CTRL+ALT`
> atau `CTRL+SUPER` buat shortcut tambahan ala Windows. Beberapa aksi sengaja punya
> dua bind (mis. tutup window `ALT+F4` **atau** `SUPER+Q`, launcher `ALT+Space`
> **atau** `SUPER+Space`) buat jaga-jaga kalau salah satu modifier ke-capture app lain.

> Penjelasan di tabel di bawah sengaja diringkas 1-2 baris. Istilah yang di-*link*
> (mis. [tiling](#tiling)) artinya lengkapnya ada di **[Kamus Istilah](#kamus-istilah)**
> paling bawah — klik/scroll ke situ kalau lupa maksudnya apa.

---

## Kamus Istilah

| Istilah | Penjelasan |
|---|---|
| <a id="tiling"></a>**Tiling** | Window otomatis diatur rapi bersebelahan (gak numpuk), ngisi layar kayak ubin/tegel — kebalikan dari cara window "normal" (Windows/macOS) yang bisa numpuk bebas. Posisi & ukurannya diatur otomatis sama Hyprland, kamu gak drag-drag manual. |
| <a id="floating"></a>**Floating** | Mode window "normal" — bebas ditumpuk, dipindah, di-resize semau kamu, gak diatur otomatis sama Hyprland. Kebalikan dari [tiling](#tiling). |
| <a id="workspace"></a>**Workspace** | Kayak "Virtual Desktop" di Windows atau "Desktop" di macOS — layar kerja terpisah yang bisa kamu isi window beda-beda, tinggal pindah-pindah pakai `SUPER+angka`. |
| <a id="fokus"></a>**Fokus** | Window mana yang lagi aktif nerima keyboard input (border-nya biasanya ke-highlight). Yang lagi fokus itu yang kena efek kalau kamu pencet bind kayak tutup/resize/pindah window. |
| <a id="fullscreen"></a>**Fullscreen** | Window nutupin seluruh layar, sampai bar Noctalia di atas ikut ketutup. Beda sama [tiling](#tiling) biasa: fullscreen "keluar" dari sistem tiling sama sekali, cuma nyisain 1 window itu doang di layar. |
| <a id="pseudotile"></a>**Pseudotile** | Window tetap di slot [tiling](#tiling)-nya (gak keluar dari susunan), tapi ukurannya jadi tetap/gak ikut ngoper otomatis walau kamu tambah window lain di workspace itu. Kepake kalau ada app yang maunya ukuran fix (mis. video player biar rasio gak gepeng) tapi kamu tetap mau dia nempel rapi bareng window lain, bukan [floating](#floating) bebas. Jarang kepake sehari-hari kecuali app-nya emang rewel soal ukuran. |
| <a id="dwindle"></a>**Dwindle / split** | Cara Hyprland nyusun window [tiling](#tiling): tiap window baru "membelah" ruang window aktif jadi dua, kayak potong kue terus potong lagi separuhnya. Arah belahannya (vertikal/horizontal) bisa di-toggle per-window. Ini layout default host ini. |
| <a id="scratchpad"></a>**Scratchpad** | Satu [workspace](#workspace) khusus tersembunyi (namanya `"magic"` di config ini) buat "nyimpen" window sementara — gak keitung di taskbar/nomor workspace biasa, cuma muncul pas dipanggil, numpuk di atas apapun yang lagi fokus. Usecase: terminal/musik player/notes yang mau selalu gampang dipanggil tanpa makan slot workspace, kayak "Quake terminal" tapi buat app apa aja. |
| <a id="gaps"></a>**Gaps** | Jarak/celah kosong antar window [tiling](#tiling) dan antara window-ke-tepi layar. |
| <a id="control-center"></a>**Control center** | Panel geser dari sisi layar isi toggle wifi/bluetooth/volume/dll, mirip Control Center iOS/macOS atau Quick Settings Android/Windows 11. |
| <a id="window-switcher"></a>**Window switcher** | Overlay nunjukin thumbnail semua window yang lagi kebuka, buat pindah fokus — sama konsepnya kayak Alt+Tab di Windows, cuma tampilannya beda (grid Noctalia, bukan strip horizontal). |
| <a id="peek-desktop"></a>**Peek desktop** | Sembunyiin semua window sementara biar keliatan wallpaper doang, kayak "Show Desktop" (klik pojok kanan-bawah taskbar) di Windows. Caranya di config ini: toggle ke [workspace](#workspace) khusus kosong bernama `"peek"` — akal-akalan, soalnya Hyprland emang gak punya fitur minimize beneran. |
| <a id="clipboard-history"></a>**Clipboard history** | Riwayat hal-hal yang pernah kamu *copy* sebelumnya (teks/gambar), bisa dipilih buat *paste* lagi tanpa perlu copy ulang. Mirip `WIN+V` di Windows atau Klipper di KDE. |
| <a id="screenshot-region"></a>**Screenshot region** | Mode screenshot di mana kursor berubah jadi alat pilih area — kamu drag kotak buat nentuin bagian layar mana aja yang mau di-*capture*, beda sama screenshot layar penuh. |
| <a id="freeze-anotasi"></a>**Freeze + anotasi** | Layar "dibekukan" dulu (gambar gak kegeser pas kamu gambar di atasnya), lalu dibuka mode coret-coret (panah, teks, kotak, dll) di atas hasil screenshot sebelum disimpan/di-*copy*. |
| <a id="screencopy"></a>**Screencopy (protokol)** | Mekanisme tingkat-rendah yang dipakai Hyprland/wlroots buat "ngambil gambar" dari layar (dipakai fitur screenshot & screen-share). Kalau ada keterbatasan (mis. kursor mouse gak ikut ke-capture), itu batasan di level protokol ini, bukan salah setting app-nya. |

---

## Aplikasi

| Keybind | Aksi |
|---|---|
| `CTRL + ALT + T` | Buka terminal (`wezterm`) |
| `SUPER + E` | Buka file manager (`dolphin`) |
| `SUPER + R` | App launcher — ketik nama app, Enter (`hyprlauncher`) |
| `ALT + Space` / `SUPER + Space` | Launcher panel Noctalia — mirip Spotlight (macOS) / KRunner (KDE), lebih niat dari yang di atas |

## Window

| Keybind | Aksi |
|---|---|
| `ALT + F4` / `SUPER + Q` | Tutup window yang lagi [fokus](#fokus) |
| `F11` / `SUPER + F` | Toggle [fullscreen](#fullscreen) |
| `SUPER + P` | Toggle [pseudotile](#pseudotile) |
| `SUPER + J` | Ganti arah [split](#dwindle) window aktif (vertikal ↔ horizontal) |
| `SUPER + SHIFT + Space` | Toggle [floating](#floating) ↔ [tiling](#tiling) — jadi floating otomatis di-resize 900×600 + center |
| `SUPER + drag LMB` | Pindah window ([floating](#floating) doang, tiling diatur otomatis) |
| `SUPER + drag RMB` | Resize window |
| Setiap app baru dibuka | Otomatis [fullscreen](#fullscreen) (window rule `auto-fullscreen`, ada catatan bug — lihat bawah) |

## Fokus & Navigasi

| Keybind | Aksi |
|---|---|
| `SUPER + ←↑↓→` | Pindah [fokus](#fokus) arah panah, lewat `smart-focus.sh` (nyebrang antar [tiling](#tiling)/[floating](#floating), gak cuma bawaan Hyprland) |
| `SUPER + SHIFT + ←↑↓→` | Resize window [fokus](#fokus), 40px/tekan (repeating) |
| `SUPER + ALT + ←↑↓→` | Tukar posisi window [fokus](#fokus) dengan tetangga arah itu |
| `SUPER + scroll` | Pindah [workspace](#workspace) berikutnya/sebelumnya — cuma yang ada isinya |
| 3-finger swipe (touchpad, horizontal) | Ganti [workspace](#workspace), versi touchpad-nya `SUPER+scroll` |

## Workspace & Desktop

| Keybind | Aksi |
|---|---|
| `SUPER + 0-9` | Loncat ke [workspace](#workspace) nomor 1-10 (`0` = 10), walau kosong |
| `CTRL + SUPER + 0-9` | Sama kayak di atas — shortcut alternatif ala Windows |
| `CTRL + SUPER + ←/→` | Pindah [workspace](#workspace) sebelumnya/berikutnya berurutan |
| `SUPER + SHIFT + 0-9` | Pindahkan window [fokus](#fokus) ke [workspace](#workspace) itu (kamu tetap di tempat) |
| `SUPER + S` | Toggle [scratchpad](#scratchpad) |
| `SUPER + SHIFT + S` | Kirim window [fokus](#fokus) ke [scratchpad](#scratchpad) |
| `SUPER + SHIFT + G` | Rapetin [workspace](#workspace) 1-10 (tutup celah yang kosong) lewat `compact-workspaces.sh` |
| `SUPER + M` / `SUPER + SHIFT + M` | Toggle [peek desktop](#peek-desktop) |
| `CTRL + ALT + Delete` | Power menu Noctalia (lock/suspend/logout/reboot/shutdown) |

## Layout & Gaps

| Keybind | Aksi |
|---|---|
| `CTRL + SUPER + =` | Perbesar [gaps](#gaps) (+4px antar-window, +2px ke tepi layar), live |
| `CTRL + SUPER + -` | Perkecil [gaps](#gaps), gak bisa minus dari 0 |
| `CTRL + SUPER + G` | Reset [gaps](#gaps) ke default config (`appearance.lua`) |

*Usecase: lagi screen-record/share terus mau rapetin/lega-in tampilan on-the-fly. Kalau gak pernah kepake, 3 bind ini aman diabaikan — atau bilang aja kalau mau dihapus.*

## Noctalia Shell

| Keybind | Aksi |
|---|---|
| `ALT + Space` / `SUPER + Space` | Toggle launcher panel |
| `SUPER + N` | Toggle [control center](#control-center) |
| `SUPER + ,` | Buka pengaturan Noctalia (tema, wallpaper, dll) |
| `SUPER + L` | Kunci layar — sama kayak `WIN+L` di Windows |
| `SUPER + V` | [Clipboard history](#clipboard-history) |
| `ALT + Tab` | [Window switcher](#window-switcher) |
| `SUPER + W` | Wallpaper berikutnya |
| `SUPER + SHIFT + W` | Wallpaper sebelumnya |
| `SUPER + ALT + W` | Wallpaper random |
| `SUPER + CTRL + W` | Notifikasi nama wallpaper aktif |

## Screenshot

*Disimpan ke `~/Pictures/Screenshots` (dideklarasikan di `noctalia/default.nix`).*

| Keybind | Aksi |
|---|---|
| `Print` | Screenshot layar penuh, auto-save + copy ke clipboard |
| `SUPER + Print` | [Screenshot region](#screenshot-region) |
| `SUPER + SHIFT + Print` | [Freeze + anotasi](#freeze-anotasi) sebelum simpan/copy |

> Kursor mouse gak ikut ke-capture walau setting `show_cursor` aktif — keterbatasan
> [screencopy](#screencopy), bukan salah config. Cek update Noctalia atau laporkan ke
> upstream-nya kalau ini penting buatmu.

## Media & Laptop

*(locked + repeating — tetap jalan di lockscreen / app apapun)*

| Tombol | Aksi |
|---|---|
| Volume +/- | `wpctl set-volume` ±5% |
| Mute (output) | Toggle mute speaker/headphone |
| Mic Mute | Toggle mute mic |
| Brightness +/- | `brightnessctl` ±5% |
| ▶ ⏸ ⏮ ⏭ | `playerctl` play/pause/prev/next — kontrol media player yang lagi jalan |

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

3. **`SUPER` + tap 3-jari di touchpad sempat kebaca sebagai paste** — sudah diperbaiki di
   `input.lua` (`tap_button_map = "lmr"` + `workspace_swipe_distance = 150`). Root
   cause: default libinput map tap 3-jari ke klik tengah (= paste primary selection),
   kepencet gak sengaja pas swipe workspace kecepetan/kependekan buat ke-recognize
   sebagai gesture.

---

*Sumber: `home/rizz404/hyprland/hyprland.lua` + `home/rizz404/hyprland/modules/keybindings.lua`
+ `home/rizz404/hyprland/modules/input.lua`,
`home/rizz404/noctalia/noctalia.lua` + `home/rizz404/noctalia/modules/keybindings.lua`
(+ `default.nix` keduanya) di repo `nixos-config`, disilangkan dengan type-stub resmi
`hl.meta.lua` dari package Hyprland, [wiki.hypr.land](https://wiki.hypr.land/configuring/core/binds/),
`noctalia msg --help` yang dites langsung ke instance Noctalia yang jalan, dan
`~/.local/state/noctalia/settings.toml` buat verifikasi setting screenshot yang aktif.
Bind yang panggil script eksternal (`smart-focus.sh`, `peek-desktop.sh`,
`compact-workspaces.sh` di `~/.config/hypr/`) ngikutin perilaku sesuai komentar di
`modules/keybindings.lua` masing-masing.
Layout dwindle (default host ini) — beberapa bind seperti `SUPER+J` khusus berlaku
di layout itu.*
