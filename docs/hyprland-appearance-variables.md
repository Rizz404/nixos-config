# Hyprland — Variables Cheatsheet (Appearance & Animations)

Diambil dari config di `~/nixos-config`:
- `home/rizz404/hyprland/modules/appearance.lua`
- `home/rizz404/hyprland/modules/animations.lua`
- `home/rizz404/hyprland/modules/layout.lua`
- `home/rizz404/hyprland/modules/keybindings.lua` (buat bagian live-resize gaps)

Referensi resmi: [wiki.hypr.land/Configuring/Basics/Variables](https://wiki.hypr.land/Configuring/Basics/Variables/)
dan type-stub `hl.meta.lua` yang dibundel sama paket Hyprland terpasang (0.55.4) —
dipakai buat mastiin nama field & tipe datanya sesuai versi yang benar-benar jalan
di mesin ini (bukan cuma nebak dari dokumentasi web).

---

## `general` — gaps, border, tearing, layout

```lua
general = {
    gaps_in = 4,
    gaps_out = 8,       -- diturunin dari 16, lihat catatan "Gaps" di bawah
    border_size = 1,
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle"
}
```

| Field | Fungsi |
|---|---|
| `gaps_in` | Jarak **antar window** yang bersebelahan dalam satu workspace. |
| `gaps_out` | Jarak **window ke tepi layar** (termasuk ke notch/bezel laptop). Ini yang kamu maksud "jarak antara layar laptop dan gap" — bener, ini yang perlu dikecilin. |
| `border_size` | Tebal border window dalam px. |
| `resize_on_border` | Kalau `true`, kamu bisa resize window dengan drag di area tepi (border) pakai mouse, gak perlu modifier key. Default `false` di config ini berarti resize cuma lewat `SUPER + drag RMB` (lihat `keybindings.lua`). |
| `allow_tearing` | Ngizinin *screen tearing* (frame ditampilin tanpa nunggu vsync) buat window yang eksplisit minta immediate present (biasanya game lewat opsi "unlock fps"/"disable vsync"). Manfaatnya latensi input lebih rendah, ongkosnya bisa keliatan robekan garis horizontal di layar pas frame rate tinggi. Di luar gaming biasanya gak kepake — `false` (default di sini) udah pas buat pemakaian umum. Kalaupun diaktifin di sini, tearing juga harus di-*allow* per-window lewat window rule `immediate` biar beneran nyala. |
| `layout` | Algoritma tiling yang dipakai. Ada 3 pilihan resmi, lihat bagian "Layout" di bawah. |

### Gaps — cara resize

**1. Statis (permanen, butuh rebuild/reload Hyprland config):**
edit langsung angkanya di `appearance.lua` (`gaps_in` / `gaps_out`), lalu
`home-manager switch` (atau reload config Hyprland-nya, tergantung setup kamu).
Ini udah aku turunin `gaps_out` dari `16` → `8` biar jarak ke tepi layar laptop
gak segede sebelumnya.

**2. Live/dinamis (langsung keliatan efeknya, gak permanen — reset kalau logout):**
aku tambahin keybinding baru di `keybindings.lua` yang manggil `hl.config()`
saat runtime (bukan cuma di-load sekali pas start), jadi bisa di-tweak on-the-fly:

| Keybind | Aksi |
|---|---|
| `CTRL + SUPER + =` | `gaps_out` & `gaps_in` nambah (`gaps_out` +4, `gaps_in` +2) |
| `CTRL + SUPER + -` | `gaps_out` & `gaps_in` berkurang (minimal 0) |
| `CTRL + SUPER + G` | Reset ke nilai default (nilai yang di-baca dari `appearance.lua` pas config di-load) |

Kalau abis eksperimen ketemu angka yang pas, pindahin aja nilainya ke `appearance.lua`
biar permanen (soalnya live-resize ini gak nulis balik ke file, cuma ubah state
Hyprland yang lagi jalan).

### Layout

Hyprland (versi terpasang, 0.55.4) punya 3 layout tiling resmi, masing-masing punya
section config sendiri (lihat `layout.lua`):

| Layout | Gaya | Section config |
|---|---|---|
| `dwindle` (dipakai di config ini) | *Binary space partitioning* — tiap window baru mecah window aktif jadi 2 (kiri/kanan atau atas/bawah, gantian arah). Mirip i3/bspwm. `SUPER + J` di config ini toggle arah split, khusus jalan di layout ini. | `dwindle.*` (mis. `preserve_split`) |
| `master` | Ada satu (atau lebih) "master window" gede di satu sisi, sisanya ("slave/stack") ditumpuk di sisi lain. Mirip layout dwm/XMonad. | `master.*` (mis. `new_status`) |
| `scrolling` | Kolom window disusun horizontal kayak PaperWM — scroll ke kanan/kiri buat pindah kolom, bukan dibagi-bagi space-nya kayak dwindle/master. | `scrolling.*` (mis. `fullscreen_on_one_column`) |

Ganti layout aktif tinggal ubah `general.layout` di `appearance.lua` jadi salah satu
dari `"dwindle"`, `"master"`, atau `"scrolling"`. Config section (`dwindle.*` /
`master.*` / `scrolling.*` di `layout.lua`) tetap boleh ada semua sekaligus — yang
kepake cuma section yang namanya cocok sama `general.layout` yang aktif.

---

## `decoration` — rounding, opacity, shadow, blur

```lua
decoration = {
    rounding = 8,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = { enabled = true, range = 4, render_power = 3, color = 0xee1a1a1a },
    blur = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 }
}
```

| Field | Fungsi |
|---|---|
| `rounding` | Radius sudut window dalam px. **Bener, ini yang dikecilin** kalau mau window kurang membulat — `0` = kotak lancip sepenuhnya. |
| `rounding_power` | Bentuk kurva sudutnya. `2` = lingkaran biasa (default). Makin gede angkanya makin ke arah bentuk "squircle"/rectangular (sudut lebih kotak tapi tetep ada lengkungan halus), makin kecil (mendekati 1) makin ke arah sudut potong lurus (chamfer/kotak). |
| `active_opacity` / `inactive_opacity` | Transparansi window yang lagi fokus vs. gak fokus. `1.0` = full opaque, makin kecil makin transparan. Beda `active` vs `inactive` sering dipakai buat nge-highlight window aktif secara visual. |
| `shadow.enabled` | Nyala/matiin drop shadow di sekitar window. |
| `shadow.range` | Seberapa jauh shadow nyebar keluar dari window (px). |
| `shadow.render_power` | Kualitas/kehalusan render shadow (makin tinggi makin halus, tapi lebih berat). |
| `shadow.color` | Warna shadow, format `AARRGGBB` (hex). `0xee1a1a1a` = hitam pekat (`1a1a1a`) dengan alpha `ee` (hampir opaque). |
| `blur.enabled` | Nyala/matiin blur di background yang tembus pandang (transparan window / layer shell semi-transparan kayak launcher, bar, dst). |
| `blur.size` | Radius blur — makin gede makin ngeblur tapi makin berat di GPU. |
| `blur.passes` | Jumlah iterasi blur — nambah pass bikin blur lebih halus/lembut, ongkosnya performa (biasanya 1-4 cukup). |
| `blur.vibrancy` | Nge-boost saturasi warna area yang di-blur biar gak keliatan pudar/abu-abu. |

---

## `animations`

```lua
animations = { enabled = true }
```

Cuma toggle nyala/mati semua animasi secara global. Detail tiap animasi (kecepatan,
kurva easing) di-define terpisah di `animations.lua` lewat `hl.curve()` (definisi
kurva bezier/spring) dan `hl.animation()` (assign kurva + speed ke tiap "leaf").

**Kurva (`hl.curve`)** — dua jenis:
- `type = "bezier"` + `points = {{x1,y1},{x2,y2}}` — kurva bezier klasik ala CSS
  `cubic-bezier()`.
- `type = "spring"` + `mass`/`stiffness`/`dampening` — animasi berbasis fisika
  (pegas), biasanya kerasa lebih "hidup"/bouncy dibanding bezier statis. Dipakai
  buat leaf `windows`/`windowsIn` di config ini (kurva `easy`).

**Leaf (`hl.animation`)** — tiap leaf ngatur bagian UI yang beda:

| Leaf | Yang dianimasiin |
|---|---|
| `global` | Fallback/multiplier speed buat semua animasi yang gak punya override sendiri. |
| `border` | Transisi warna border (mis. pas window pindah fokus). |
| `windows` / `windowsIn` / `windowsOut` | Window muncul (open), hilang (close), dan gerakan umum window. |
| `fadeIn` / `fadeOut` / `fade` | Transisi opacity window secara umum. |
| `layers` / `layersIn` / `layersOut` | Layer-shell surface (bar, launcher, notifikasi, dst — bukan window biasa). |
| `fadeLayersIn` / `fadeLayersOut` | Fade khusus buat layer-shell. |
| `workspaces` / `workspacesIn` / `workspacesOut` | Transisi pindah workspace. |
| `zoomFactor` | Animasi zoom cursor/layar (kalau dipakai fitur zoom). |

Field per-leaf: `speed` (durasi relatif, makin gede makin lambat), `bezier`/`spring`
(nama kurva yang di-define lewat `hl.curve`), dan `style` opsional (mis.
`"popin 87%"` = animasi muncul dari 87% ukuran, `"fade"` = cuma fade tanpa gerak).

---

*Sumber: file-file di atas, disilangkan dengan `hl.meta.lua` (type-stub resmi
Hyprland 0.55.4, `/nix/store/.../share/hypr/stubs/hl.meta.lua`) dan
[wiki.hypr.land/Configuring/Basics/Variables](https://wiki.hypr.land/Configuring/Basics/Variables/).*
