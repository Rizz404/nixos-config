# Noctalia × Hyprland — Panduan Ricing (menuju look "Spotlight")

Referensi: [noctalia.dev/#spotlight](https://noctalia.dev) cuma galeri screenshot user, gak ada
resep teknis di halamannya. Tapi semua submission di situ share 1 pola yang sama:
**wallpaper-driven theming** (semua warna shell ngikut wallpaper) + bar/widget minimal +
konsistensi warna lintas aplikasi. Dokumen ini nurunin pola itu jadi langkah konkret yang
match sama config yang ada di repo ini.

Sumber teknis dokumen ini:
- `example.toml` dari source Noctalia (v5.1.0, rev `4a92d27d` — lihat `flake.lock` input `noctalia`),
  berisi SEMUA key config beserta default & komentarnya.
- `docs/user/**/*.mdx` dari source yang sama (dokumentasi resmi yang dibundel di repo Noctalia).
- `assets/templates/**` dari source yang sama (isi template built-in per-aplikasi).
- Config yang sudah ada di repo ini: `home/rizz404/noctalia/default.nix`,
  `home/rizz404/noctalia/noctalia.lua` + `modules/*.lua`, `home/rizz404/hyprland/hyprland.lua` +
  `modules/appearance.lua`, dan runtime state di `~/.config/noctalia/config.toml`.

---

## 0. Dua lapis config — baca ini dulu sebelum ubah apa pun

Noctalia punya **dua sumber config yang di-merge**, urutan load-nya penting:

1. **`config.toml`** — deklaratif, di-generate dari `programs.noctalia.settings` di
   `home/rizz404/noctalia/default.nix` (sekarang isinya cuma blok `theme`). File ini symlink ke
   Nix store, jadi **read-only**, cuma berubah lewat `home-manager switch`.
2. **`settings.toml`** — runtime, ditulis otomatis oleh Settings GUI (`SUPER + ,`) atau IPC
   (`noctalia msg ...`). File ini **di-load belakangan dan menang** kalau ada key yang sama
   dengan `config.toml`.

Konsekuensi buat alur kerja: **eksperimen dulu lewat GUI** (nulis ke `settings.toml`, gak nyentuh
Nix sama sekali, aman buat coba-coba) → begitu ketemu kombinasi yang cocok, **pindahin key yang
relevan ke `programs.noctalia.settings`** di `default.nix` → `home-manager switch`. Kalau gak
dipindah, hasil eksperimen kamu cuma hidup di `settings.toml` dan gak ke-track sama sekali di
Git — hilang kalau kamu pernah reset state atau pindah mesin.

`checkConfig = true` (default, gak diubah di `default.nix` kalian) artinya tiap `home-manager
switch` bakal jalanin `noctalia config validate` ke isi `settings` sebelum di-apply — jadi typo
field akan ketahuan pas build, bukan pas runtime.

---

## 1. Wallpaper — fondasi paling menentukan

Section `[wallpaper]`. Field yang relevan:

| Field | Fungsi |
|---|---|
| `fill_mode` | `crop` (default, isi penuh layar dengan crop) vs `fit` (keliatan utuh, ada letterbox) vs `span` (1 wallpaper lebar ngalir lintas multi-monitor). Buat foto/scenery pilih `crop`; buat ilustrasi/art yang komposisinya penting pilih `fit`. |
| `fill_color` | Warna pengisi letterbox/uncovered area. **Pakai nama role** (`surface`, `primary`, dst — bukan hex tetap) biar ikut palette aktif, bukan warna nge-jomplang sendiri. |
| `transition` | Array efek transisi (`fade`, `wipe`, `disc`, `stripes`, `zoom`, `honeycomb`) — dipilih random tiap ganti wallpaper. Kosongkan array (hapus baris) buat pakai semua efek. |
| `directory` | Folder yang di-scan wallpaper picker + auto-rotate. Kosong = default ke `XDG_PICTURES_DIR`. |
| `automation.enabled` | `true` buat wallpaper ganti otomatis tiap `interval_seconds`, pilih `order = "random"` atau `"alphabetical"`. |

Tips pemilihan gambar: pilih wallpaper dengan **1-2 warna dominan yang jelas**, bukan foto ramai —
soalnya langkah berikutnya (dynamic theming) narik seluruh palette shell dari 1 warna seed di
gambar ini. Wallpaper noisy → palette generated jadi kusam/gak konsisten walau setting lain udah
pas.

Bisa juga declare wallpaper favorit lengkap dengan preferensi tema-nya sendiri lewat
`[[wallpaper.favorite]]` (per-wallpaper bisa beda `theme_mode` dan `wallpaper_scheme` — berguna
kalau kamu punya beberapa wallpaper untuk mood berbeda).

---

## 2. Dynamic theme dari wallpaper — kunci look "kohesif" ala spotlight

Section `[theme]`. Ini yang paling berdampak dari semua langkah — beda `source` bikin shell kamu
selamanya pakai palette tetap (`builtin`, kondisi sekarang: `Catppuccin`) vs ikut-ikutan wallpaper
tiap kali ganti.

| Field | Nilai & fungsi |
|---|---|
| `source` | `builtin` (palette tetap) → ganti ke **`wallpaper`** supaya palette di-generate ulang tiap wallpaper berubah. |
| `wallpaper_scheme` | Algoritma generate warna dari gambar. Lihat tabel di bawah. |
| `mode` | `dark` / `light` / `auto` (ikut jadwal sunrise-sunset di `[location]`). Ini yang dipakai *aplikasi* (lewat template, lihat Langkah 8). |
| `shell_mode` | Mode shell Noctalia sendiri (bar/panel/launcher) — default `follow` (ikut `mode`). Bisa di-pin beda dari `mode`, mis. bar selalu dark walau app-mu ganti sesuai jadwal siang/malam. |
| `pure_black_dark` | `true` = background dark mode diganti hitam pekat (OLED-style), tetap pertahanin warna foreground/accent dari palette. Banyak dipakai di rice minimal-kontras-tinggi. |

Pilihan `wallpaper_scheme`:

| Value | Karakter |
|---|---|
| `m3-tonal-spot` | Default Material You — seimbang, gak terlalu saturated. |
| `m3-content` | Chroma lebih tinggi, cocok kalau widget/teks banyak (content-forward). |
| `m3-fruit-salad` | Multi-accent, hue-nya beda-beda per role — playful. |
| `m3-rainbow` | Full color wheel, dipakai kalau suka banyak warna aksen sekaligus. |
| `m3-monochrome` | Cuma 1 hue — paling minimalis/monokrom. |
| `vibrant` | Saturasi tinggi, kontras tegas — sering yang bikin "pop" di screenshot. |
| `faithful` | Warna paling nempel ke warna asli gambar. |
| `soft` | Faithful tapi saturasi dilembutin. |
| `muted` | Saturasi rendah keseluruhan, gaya "quiet"/kalem. |
| `dysfunctional` | Sengaja "salah"/off-kilter, eksperimental. |

Buat look minimal-tapi-nge-pop kayak kebanyakan screenshot spotlight: mulai dari `m3-content`
atau `vibrant`, baru turun ke `soft`/`muted` kalau kerasa terlalu ramai.

---

## 3. Bar — dari default ke minimal

Section `[bar.main]` (nama bar default di config kalian). Baseline resmi & artinya:

| Field | Efek buat look minimal |
|---|---|
| `thickness` | Tinggi bar. Default `34`. Bar tipis (`28-32`) kesan lebih minimal. |
| `radius` / `radius_top_*` / `radius_bottom_*` | Radius sudut bar. Naikin (`16-20`) + `margin_edge > 0` bikin bar keliatan "melayang" (floating pill), bukan nempel penuh ke tepi layar. |
| `margin_ends` | Inset dari ujung bar. Default `180` — makin besar, bar makin pendek/terpusat (gaya "island bar"). |
| `margin_edge` | Jarak bar ke tepi layar fisik. `0` = nempel (full-width), `>0` = melayang. |
| `background_opacity` | `< 1.0` + `[backdrop]`/blur aktif = efek glass. |
| `capsule` | `true` = tiap widget dapet pill background sendiri — ini yang bikin bar keliatan "segmented" kayak banyak rice modern. |
| `capsule_fill` | Warna pill, pakai role (`surface_variant` default, atau `primary` buat 1-2 widget yang mau di-highlight). |
| `start` / `center` / `end` | **Ini yang paling penting buat kesan "minimal".** Default resmi: `start=[launcher, wallpaper, workspaces]`, `center=[clock]`, `end=[media, tray, notifications, clipboard, network, bluetooth, volume, brightness, battery, control-center, session]` — itu 11 widget di `end` doang, kepenuhan. Potong ke yang beneran kepake: mis. `end=[tray, network, bluetooth, volume, battery, control-center]`. |

Lanjutan buat visual yang lebih "grouped" ala showcase: widget-widget yang berhubungan (mis.
`network`, `bluetooth`, `volume`) bisa digabung jadi **1 capsule group** (background sama-sama,
1 border) lewat Settings GUI → **Bar → Bar Widgets** → drag 1 widget ke tengah widget lain untuk
gabung. Hasilnya tersimpan sebagai `[[bar.main.capsule_group]]` di config — biasanya lebih gampang
diatur lewat GUI (drag & drop) daripada nulis manual.

---

## 4. Dock (opsional)

Section `[dock]`, default `enabled = false`. Kalau mau taskbar/dock kayak di sebagian screenshot
(macOS-style dock icon row):

| Field | Fungsi |
|---|---|
| `enabled` | Set `true` buat aktifin. |
| `magnification` + `magnification_scale` | Efek icon membesar pas di-hover (default `true`, scale `1.45`) — ciri khas dock macOS-style yang sering muncul di rice. |
| `active_scale` / `inactive_scale` | Ukuran icon app aktif vs tidak. |
| `pinned` | Array nama app yang di-pin permanen, mis. `["firefox", "wezterm", "dolphin"]`. |
| `auto_hide` | Sembunyiin dock kecuali pointer deket edge — biar gak makan ruang layar pas gak dipake. |

Kalau kamu sudah nyaman cuma pakai bar (kondisi sekarang), dock bisa dilewati — banyak juga
submission spotlight yang cuma pakai bar tanpa dock sama sekali.

---

## 5. Notification & OSD — biar gak "beda dunia" dari bar

Section `[notification]` dan `[osd]`. Keduanya punya `background_opacity` dan `offset_x`/`offset_y`
sendiri-sendiri (default `0.97` / `20` / `8`) — selaraskan opacity-nya kira-kira sama dengan
`bar.main.background_opacity` biar transparansi terasa konsisten di semua permukaan shell, bukan
cuma di bar doang.

`[osd].position` (`top_right`, `bottom_center`, dst.) — pilih sudut yang gak nabrak posisi bar
kamu (kalau bar di `top`, OSD `bottom_*` biasanya lebih rapi).

---

## 6. Backdrop & Lockscreen — konsistensi di luar desktop

- `[backdrop]` (default `enabled = false`) — render wallpaper blur+tint sebagai layer terpisah,
  dipakai compositor tertentu (niri overview). Untuk Hyprland biasanya gak krusial, tapi kalau
  nanti coba compositor lain ini yang bikin efek "blurred background saat overview".
- `[lockscreen]` — set `blurred_desktop = true` biar lockscreen nunjukin snapshot desktop yang
  di-blur (bukan wallpaper polos), plus `blur_intensity`/`tint_intensity` biar senada sama gaya
  blur yang udah kamu pakai di bar Hyprland (`decoration.blur` di `appearance.lua`).

---

## 7. Sinkronisasi warna Hyprland — border ikut wallpaper (bagian paling teknis)

Ini bagian yang paling nge-jawab "kenapa border/window di showcase itu selalu senada sama
wallpaper" — dan ada 1 detail spesifik ke setup kalian yang perlu diperhatiin.

### 7.1. Mekanismenya

Noctalia punya **built-in template** khusus Hyprland (`assets/templates/hyprland/`) yang, kalau
diaktifkan, nge-generate file berisi warna dari palette aktif (ikut wallpaper kalau `theme.source
= "wallpaper"`) dan nulis ulang tiap kali tema berubah. Aktifin lewat:

```toml
[theme.templates]
enable_builtin_templates = true
builtin_ids              = ["hyprland"]
```

Karena `configType = "lua"` di `hyprland/default.nix` kalian, template ini mendeteksi mode Lua
dan nulis ke **`~/.config/hypr/noctalia.lua`** (bukan `.conf`) — isinya kira-kira:
- `general.col.active_border` / `inactive_border` diambil dari role `primary` / `surface`.
- `group.col.*` (border/groupbar saat window di-group) diambil dari `secondary`/`error`/`surface`.
- File itu return sebuah module dengan fungsi `apply_theme()` yang manggil `hl.config(...)` buat
  nge-set warna itu ke Hyprland.

Noctalia lalu otomatis coba nyisipin baris `require("noctalia").apply_theme()` ke
`~/.config/hypr/hyprland.lua` supaya fungsi itu ke-panggil tiap Hyprland load config.

### 7.2. Kenapa auto-insert-nya bakal gagal di setup kalian — dan cara benerinnya

`~/.config/hypr/hyprland.lua` di mesin ini adalah **symlink ke Nix store** (read-only), hasil dari
`extraConfig = builtins.readFile ./hyprland.lua` di `hyprland/default.nix`. Noctalia gak bisa
nulis ke situ — persis kasus yang disebut eksplisit di dokumentasi resminya: *"For declaratively
managed configs such as Home Manager symlinks into the Nix store, remove the Noctalia include ...
from the declarative source"*. Jadi auto-insert-nya harus dilewati, dan baris require-nya
ditambahin manual ke source Lua kalian sendiri.

**Cara paling konsisten sama gaya split-module yang udah kalian pakai:** tambah 1 file baru
`home/rizz404/noctalia/modules/theme.lua` isinya cuma
`require("noctalia").apply_theme()`, lalu require file itu dari `noctalia.lua` (didaftarin di
`xdg.configFile` seperti 3 module lain), dan tambahin path-nya ke `xdg.configFile` di
`noctalia/default.nix`.

**Yang lebih penting — soal urutan eksekusi:** saya cek langsung file hasil build
(`~/.config/hypr/hyprland.lua`, resolved ke `/nix/store/.../hm_hyprhyprland.lua`), dan urutannya
ternyata:

```
require("modules.noctalia.autostart")
require("modules.noctalia.keybindings")
require("modules.noctalia.rules")
-- (lalu baru)
require("modules.hyprland.monitors")
...
require("modules.hyprland.appearance")   <- ini yang set-ulang general.col
...
```

Artinya isi `noctalia.lua` (top-level) dieksekusi **duluan**, baru `hyprland.lua` (top-level)
nyusul — kebalikan dari yang ditulis di `docs/hyprland-noctalia-cheatsheet.md` (yang bilang
Noctalia di-import "setelah" Hyprland). Konsekuensinya: kalau kamu taruh
`require("noctalia").apply_theme()` di sisi Noctalia (sesuai saran di atas), warna dinamis dari
Noctalia akan **ke-timpa lagi** oleh `general.col.active_border`/`inactive_border` statis yang
sudah di-set di `hyprland/modules/appearance.lua` (baris `col = { active_border = {...}, inactive_border = ... }`) — karena itu dieksekusi belakangan.

**Fix-nya:** hapus (atau kosongkan) key `col.active_border` dan `col.inactive_border` di
`general` pada `hyprland/modules/appearance.lua`, biar gak ada yang nge-timpa lagi setelah
Noctalia set warnanya. Field lain di `general`/`decoration` (`gaps_in/out`, `border_size`,
`rounding`, `blur`, `shadow`) tetap aman dibiarin seperti sekarang — template Hyprland-nya Noctalia
cuma nyentuh `general.col.*` dan `group.col.*`, gak pernah nyentuh `decoration.*`, jadi gak
bentrok sama komentar "SATU sumber" yang udah ada di `noctalia.lua` soal decoration.

### 7.3. Efek akhirnya

Setiap kali kamu ganti wallpaper (dan `theme.source = "wallpaper"`), border window aktif/tidak
aktif di Hyprland ikut berubah otomatis — ini yang bikin desktop keliatan "1 tema utuh" alih-alih
bar berwarna A tapi border window masih warna B yang gak nyambung.

---

## 8. App theming lintas aplikasi — biar terminal/file-manager gak beda dunia

Mekanisme yang sama (`[theme.templates]`) juga punya template built-in buat aplikasi lain. Cek
daftar lengkap yang tersedia di mesin kamu dengan `noctalia theme --list-templates`. Yang relevan
buat stack kalian (dari `docs/hyprland-noctalia-cheatsheet.md`: pakai `wezterm` + `dolphin`, dan
mesin ini dual-boot ke Plasma):

| Template id | Guna |
|---|---|
| `wezterm` | Generate `~/.config/wezterm/colors/noctalia.toml` — palette terminal (ANSI 16 warna + tab bar) ikut tema aktif. |
| `gtk3`, `gtk4` | Theme GTK app (banyak app non-KDE) ikut palette. |
| `qt` | Theme Qt app generik. |
| `kcolorscheme` | Nge-generate KDE color scheme dan (lewat `post_action = "kde-color-scheme"`) langsung apply ke `kdeglobals` — ini yang bikin **Dolphin** dan app KDE lain ikut warna yang sama, termasuk pas kamu login ke sesi Plasma. |

Aktifin sesuai kebutuhan:

```toml
[theme.templates]
enable_builtin_templates = true
builtin_ids              = ["hyprland", "wezterm", "gtk3", "gtk4", "qt", "kcolorscheme"]
```

Catatan yang sama kayak di Langkah 7 berlaku: kalau config target app itu juga di-manage
deklaratif lewat Home Manager (symlink ke Nix store, read-only), auto-write dari Noctalia akan
gagal nulis ke situ — solusinya taruh integrasi tema itu di source Nix kamu sendiri (atau biarkan
app tsb gak deklaratif dan biarkan Noctalia yang nulis file live-nya).

Kalau suatu saat mau app lain yang belum ada built-in template-nya, ada juga jalur
`[theme.templates.user.<nama>]` buat declare template sendiri (`input_path`/`output_path`/
`post_hook`) — detail lengkap ada di dokumentasi upstream `theming/templates`.

---

## 9. Font & polish terakhir

- `[shell] font_family` — set 1 Nerd Font (biar ikon di bar & terminal `wezterm` konsisten).
  Kosong = pakai `sans-serif` default sistem.
- `[shell] corner_radius_scale` — multiplier radius buat **semua** elemen shell Noctalia sekaligus
  (panel, launcher, dsb) — `0` kotak penuh, `1` default, `2` extra rounded. Ini terpisah dari
  `decoration.rounding` di Hyprland (yang cuma buat window), jadi kalau mau look "semua serba
  rounded" konsisten, samakan rasa radius keduanya (mis. kalau Hyprland `rounding = 8` kerasa
  cukup rounded, jangan set `corner_radius_scale` di atas `1`).
- Icon theme & cursor theme desktop (bukan bagian Noctalia, tapi bagian tema sistem) tetap
  perlu disamain manual — pilih 1 icon theme dark yang matching mood wallpaper.

---

## 10. Uji & iterasi

- Sebagian besar key di atas **hot-reload lewat inotify** — cukup save `settings.toml`/edit lewat
  GUI, gak perlu restart shell (dicatat di komentar baris pertama `example.toml`).
- Buat rerender ulang semua template app (Langkah 7-8) tanpa ganti tema, ada IPC:
  `noctalia msg` (lihat kategori Media & UI → Theme di dokumentasi upstream).
- Validasi config manual sebelum commit ke Nix: `noctalia config validate <file.toml>` — command
  yang sama yang otomatis jalan pas `home-manager switch` karena `checkConfig = true`.
- Iterasi warna: ganti-ganti `wallpaper_scheme` dulu (murah, instant) sebelum oprek detail bar/dock
  — background dan wallpaper_scheme itu yang paling nentuin "vibe" keseluruhan, sisanya tinggal
  layout tweak.

---

*Sumber: `example.toml`, `nix/home-module.nix`, dan `docs/user/**` dari source
`github:noctalia-dev/noctalia` rev `4a92d27dadb32c4bcc9c1cb14eb808a3a0bb0a93` (input flake
`noctalia` di `flake.lock`); `assets/templates/hyprland/*` dan `assets/templates/builtin.toml`
dari source yang sama; file hasil build `~/.config/hypr/hyprland.lua` (resolved ke
`hm_hyprhyprland.lua` di Nix store) buat verifikasi urutan eksekusi aktual di Langkah 7.2.*
