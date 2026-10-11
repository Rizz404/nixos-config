# Migrasi ThinkPad T14: NixOS → CachyOS

Tanggal inventaris dan pemeriksaan paket: **11 Oktober 2026**.
Target: **`lenovo-thinkpad-t14-personal`**, user **`rizz404`**, platform **x86_64**, GPU AMD.

Dokumen ini mencakup paket yang dideklarasikan, service, konfigurasi sistem dan desktop,
dotfile, aset di luar repo, urutan migrasi, dan lampiran isi lengkap source konfigurasi.
Scope mengikuti import ThinkPad di `flake.nix`, seluruh sharedModules aktif, dan
`home/rizz404/default.nix`. Paket dependency transitif/default bawaan modul Nix tidak
dihitung sebagai daftar paket eksplisit; komponen target penting dicatat terpisah.

Ini panduan dan checklist. Pembuatan dokumen ini tidak menginstal paket atau mengubah
service, bootloader, partisi, maupun konfigurasi aktif.

## Daftar isi

1. [Checklist pekerjaan](#1-checklist-pekerjaan)
2. [Daftar instalasi](#2-daftar-instalasi)
3. [Backup dan data di luar repo](#3-backup-dan-data-di-luar-repo)
4. [Konfigurasi sistem ThinkPad](#4-konfigurasi-sistem-thinkpad)
5. [Desktop, portal, wallet, dan login](#5-desktop-portal-wallet-dan-login)
6. [Hyprland dan Noctalia](#6-hyprland-dan-noctalia)
7. [Shell dan konfigurasi aplikasi](#7-shell-dan-konfigurasi-aplikasi)
8. [Plasma dan tema](#8-plasma-dan-tema)
9. [Database, container, dan gaming](#9-database-container-dan-gaming)
10. [Bagian Nix dan pengecekan hasil](#10-bagian-nix-dan-pengecekan-hasil)
11. [Lampiran konfigurasi native Noctalia](#11-lampiran-konfigurasi-native-noctalia)
12. [Lampiran source konfigurasi lengkap](#12-lampiran-source-konfigurasi-lengkap)
13. [Referensi](#13-referensi)

## 1. Checklist pekerjaan

- [ ] Backup repo `nixos-config` dan clone **`~/qylock`**; tema SDDM kustom ada di clone kedua.
- [ ] Export dotfile Home Manager sebagai **file biasa**, termasuk target symlink `/nix/store`.
- [ ] Backup runtime Noctalia, wallpaper/sticker, tema upstream, browser, wallet, dan kunci.
- [ ] Dump PostgreSQL/MySQL sebelum mengganti sistem.
- [ ] Instal CachyOS dengan setup AMD/Btrfs dan Limine sesuai kebutuhan layout disk target.
- [ ] Instal desktop Plasma + Hyprland + Noctalia dan driver/library 32-bit.
- [ ] Instal paket aplikasi, CLI, bahasa, database, gaming, dan font dari tabel.
- [ ] Terapkan TLP, charging threshold, charge-kick, logind, early KMS, dan Plymouth.
- [ ] Aktifkan service network, Bluetooth, SSH, Tailscale, printing, dan database.
- [ ] Restore konfigurasi Hyprland/Noctalia, portal Secret, wallet, SDDM, Plasma, shell, editor, media.
- [ ] Restore data dan validasi sesi Plasma maupun Hyprland.

## 2. Daftar instalasi

Setiap baris adalah item setup lama; ceklis sesudah item target terpasang atau padanannya
selesai dikonfigurasi. Item dengan beberapa paket membutuhkan semua paket yang ditulis.
Paket pendukung target menambahkan komponen yang sebelumnya ditarik otomatis oleh modul Nix.

**Status pemeriksaan:** `core/extra/multilib` diperiksa terhadap database paket Arch;
`cachyos` diperiksa terhadap database mirror resmi CachyOS; `AUR` diperiksa menggunakan
RPC AUR. Tabel memakai baseline Arch untuk paket yang ada di Arch, lalu repo `cachyos`
untuk kandidat di luar Arch yang tersedia di sana, lalu AUR. Repo optimized CachyOS
bisa menyediakan versi berbeda; versi terpasang mengikuti repositori target yang aktif.
Versi adalah snapshot pemeriksaan, bukan perintah pin seluruh sistem.

Sumber pemeriksaan: [database Arch](https://archlinux.org/packages/),
[mirror database Arch](https://geo.mirror.pkgbuild.com/),
[mirror resmi CachyOS](https://cdn77.cachyos.org/repo/x86_64/cachyos/), [AUR](https://aur.archlinux.org/).
Untuk paket versi khusus, tabel menautkan halaman paket yang relevan.

### Paket dasar

| Selesai | Deklarasi Nix / komponen | Instalasi di target | Sumber dan catatan |
|---|---|---|---|
| [ ] | `git` | [`git`](https://archlinux.org/packages/extra/x86_64/git/) | extra 2.56.0-1 |
| [ ] | `wget` | [`wget`](https://archlinux.org/packages/extra/x86_64/wget/) | extra 1.25.0-6 |
| [ ] | `curl` | [`curl`](https://archlinux.org/packages/core/x86_64/curl/) | core 8.22.0-1 |
| [ ] | `htop` | [`htop`](https://archlinux.org/packages/extra/x86_64/htop/) | extra 3.5.3-1 |
| [ ] | `tree` | [`tree`](https://archlinux.org/packages/extra/x86_64/tree/) | extra 2.3.2-1 |
| [ ] | `vim` | [`vim`](https://archlinux.org/packages/extra/x86_64/vim/) | extra 9.2.1164-2 |
| [ ] | `efibootmgr` | [`efibootmgr`](https://archlinux.org/packages/core/x86_64/efibootmgr/) | core 18-4 |

### Devtools, CLI, bahasa, dan aplikasi developer

| Selesai | Deklarasi Nix / komponen | Instalasi di target | Sumber dan catatan |
|---|---|---|---|
| [ ] | `bruno` | [`bruno-bin`](https://aur.archlinux.org/packages/bruno-bin) | AUR 4.2.1-1 |
| [ ] | `rustdesk-flutter` | [`rustdesk-bin`](https://aur.archlinux.org/packages/rustdesk-bin) | AUR 1.5.0-1 |
| [ ] | `vscode` | [`visual-studio-code-bin`](https://aur.archlinux.org/packages/visual-studio-code-bin) | AUR 1.141.0-1 |
| [ ] | `telegram-desktop` | [`telegram-desktop`](https://archlinux.org/packages/extra/x86_64/telegram-desktop/) | extra 7.2.9-2 |
| [ ] | `mpvScripts.mpris` | [`mpv-mpris`](https://archlinux.org/packages/extra/x86_64/mpv-mpris/) | extra 1.3-1; Ada sebagai paket di repo; audit apakah script MPRIS memang dimuat, bukan hanya terpasang. |
| [ ] | `llmAgents.claude-code` | [`claude-code`](https://packages.cachyos.org/package/cachyos/x86_64/claude-code) | cachyos 2.1.296-1; Sebelumnya dari llm-agents.nix; di target gunakan paket AUR terverifikasi atau installer upstream. |
| [ ] | `llmAgents.opencode` | [`opencode`](https://archlinux.org/packages/extra/x86_64/opencode/) | extra 2.0.26-1 |
| [ ] | `llmAgents.codex` | [`openai-codex`](https://archlinux.org/packages/extra/x86_64/openai-codex/) | extra 0.162.1-1 |
| [ ] | `gh` | [`github-cli`](https://archlinux.org/packages/extra/x86_64/github-cli/) | extra 2.102.0-1 |
| [ ] | `lazygit` | [`lazygit`](https://archlinux.org/packages/extra/x86_64/lazygit/) | extra 0.66.0-1 |
| [ ] | `micro` | [`micro`](https://archlinux.org/packages/extra/x86_64/micro/) | extra 2.0.15-3 |
| [ ] | `btop` | [`btop`](https://archlinux.org/packages/extra/x86_64/btop/) | extra 1.4.7-1 |
| [ ] | `chafa` | [`chafa`](https://archlinux.org/packages/extra/x86_64/chafa/) | extra 1.18.3-1 |
| [ ] | `duf` | [`duf`](https://archlinux.org/packages/extra/x86_64/duf/) | extra 0.9.1-1 |
| [ ] | `dust` | [`dust`](https://archlinux.org/packages/extra/x86_64/dust/) | extra 1.2.6-1 |
| [ ] | `fastfetch` | [`fastfetch`](https://archlinux.org/packages/extra/x86_64/fastfetch/) | extra 2.69.0-1 |
| [ ] | `plocate` | [`plocate`](https://archlinux.org/packages/extra/x86_64/plocate/) | extra 1.1.25-1; services.locate Nix bisa memilih paket backend lain; cukup gunakan satu timer updatedb yang sesuai. |
| [ ] | `ripgrep` | [`ripgrep`](https://archlinux.org/packages/extra/x86_64/ripgrep/) | extra 15.2.0-1 |
| [ ] | `fd` | [`fd`](https://archlinux.org/packages/extra/x86_64/fd/) | extra 10.5.0-3 |
| [ ] | `bat` | [`bat`](https://archlinux.org/packages/extra/x86_64/bat/) | extra 0.26.1-3 |
| [ ] | `jq` | [`jq`](https://archlinux.org/packages/extra/x86_64/jq/) | extra 1.8.2-1 |
| [ ] | `tesseract` | [`tesseract`](https://archlinux.org/packages/extra/x86_64/tesseract/) | extra 5.5.3-1 |
| [ ] | `xh` | [`xh`](https://archlinux.org/packages/extra/x86_64/xh/) | extra 0.26.2-1 |
| [ ] | `p7zip` | [`7zip`](https://archlinux.org/packages/extra/x86_64/7zip/) | extra 26.04-1 |
| [ ] | `unzip` | [`unzip`](https://archlinux.org/packages/extra/x86_64/unzip/) | extra 6.0-23 |
| [ ] | `zip` | [`zip`](https://archlinux.org/packages/extra/x86_64/zip/) | extra 3.0-14 |
| [ ] | `unrar` | [`unrar`](https://archlinux.org/packages/extra/x86_64/unrar/) | extra 1:7.3.1-1 |
| [ ] | `rclone` | [`rclone`](https://archlinux.org/packages/extra/x86_64/rclone/) | extra 1.75.2-1 |
| [ ] | `restic` | [`restic`](https://archlinux.org/packages/extra/x86_64/restic/) | extra 0.19.1-1 |
| [ ] | `yt-dlp` | [`yt-dlp`](https://archlinux.org/packages/extra/any/yt-dlp/) | extra 2026.08.19-1 |
| [ ] | `wl-clipboard` | [`wl-clipboard`](https://archlinux.org/packages/extra/x86_64/wl-clipboard/) | extra 1:2.3.0-1 |
| [ ] | `aspell` | [`aspell`](https://archlinux.org/packages/extra/x86_64/aspell/) | extra 0.60.8.2-2 |
| [ ] | `aspellDicts.en` | [`aspell-en`](https://archlinux.org/packages/extra/x86_64/aspell-en/) | extra 2026.02.25-1 |
| [ ] | `aspellDicts.id` | [`aspell-id`](https://aur.archlinux.org/packages/aspell-id) | AUR 1.2-1 |
| [ ] | `arch-install-scripts` | [`arch-install-scripts`](https://archlinux.org/packages/extra/any/arch-install-scripts/) | extra 31-2 |
| [ ] | `podman-compose` | [`podman-compose`](https://archlinux.org/packages/extra/any/podman-compose/) | extra 1.6.0-1 |
| [ ] | `podman-tui` | [`podman-tui`](https://aur.archlinux.org/packages/podman-tui) | AUR 2.0.0-1 |
| [ ] | `zellij` | [`zellij`](https://archlinux.org/packages/extra/x86_64/zellij/) | extra 0.45.1-1 |
| [ ] | `iw` | [`iw`](https://archlinux.org/packages/core/x86_64/iw/) | core 6.17-1 |
| [ ] | `pciutils` | [`pciutils`](https://archlinux.org/packages/core/x86_64/pciutils/) | core 3.15.0-1 |
| [ ] | `usbutils` | [`usbutils`](https://archlinux.org/packages/core/x86_64/usbutils/) | core 019-1 |
| [ ] | `aircrack-ng` | [`aircrack-ng`](https://archlinux.org/packages/extra/x86_64/aircrack-ng/) | extra 1.7-7 |
| [ ] | `reaverwps` | [`reaver`](https://archlinux.org/packages/extra/x86_64/reaver/) | extra 1.6.6-2 |
| [ ] | `bully` | [`bully`](https://archlinux.org/packages/extra/x86_64/bully/) | extra 1.4.00-1 |
| [ ] | `wpa_supplicant` | [`wpa_supplicant`](https://archlinux.org/packages/core/x86_64/wpa_supplicant/) | core 2:2.12-1 |
| [ ] | `wirelesstools` | [`wireless_tools`](https://archlinux.org/packages/extra/x86_64/wireless_tools/) | extra 30.pre9-5 |
| [ ] | `imagemagick` | [`imagemagick`](https://archlinux.org/packages/extra/x86_64/imagemagick/) | extra 7.1.2.33-1 |
| [ ] | `ffmpeg` | [`ffmpeg`](https://archlinux.org/packages/extra/x86_64/ffmpeg/) | extra 2:9.0.2-2 |
| [ ] | `stress-ng` | [`stress-ng`](https://archlinux.org/packages/extra/x86_64/stress-ng/) | extra 0.22.01-1 |
| [ ] | `linuxPackages.cpupower` | [`cpupower`](https://archlinux.org/packages/extra/x86_64/cpupower/) | extra 7.2.9-1 |
| [ ] | `evtest` | [`evtest`](https://archlinux.org/packages/extra/x86_64/evtest/) | extra 1.36-1 |
| [ ] | `libinput` | [`libinput`](https://archlinux.org/packages/extra/x86_64/libinput/) | extra 1.32.0-1 |
| [ ] | `alsa-utils` | [`alsa-utils`](https://archlinux.org/packages/extra/x86_64/alsa-utils/) | extra 1.2.16-1 |
| [ ] | `lm_sensors` | [`lm_sensors`](https://archlinux.org/packages/extra/x86_64/lm_sensors/) | extra 1:3.6.2-1 |
| [ ] | `ethtool` | [`ethtool`](https://archlinux.org/packages/extra/x86_64/ethtool/) | extra 1:7.1-1 |
| [ ] | `psmisc` | [`psmisc`](https://archlinux.org/packages/core/x86_64/psmisc/) | core 23.7-2 |
| [ ] | `bind` | [`bind`](https://archlinux.org/packages/extra/x86_64/bind/) | extra 9.20.29-1 |
| [ ] | `openssl` | [`openssl`](https://archlinux.org/packages/core/x86_64/openssl/) | core 3.6.5-1 |
| [ ] | `samba` | [`samba`](https://archlinux.org/packages/extra/x86_64/samba/) | extra 2:4.25.0-1 |
| [ ] | `pdfarranger` | [`pdfarranger`](https://archlinux.org/packages/extra/any/pdfarranger/) | extra 1.14.0-1 |
| [ ] | `qpdf` | [`qpdf`](https://archlinux.org/packages/extra/x86_64/qpdf/) | extra 12.4.2-1 |
| [ ] | `file` | [`file`](https://archlinux.org/packages/core/x86_64/file/) | core 5.48-1 |
| [ ] | `gallery-dl` | [`gallery-dl`](https://aur.archlinux.org/packages/gallery-dl) | AUR 1.32.16-1 |
| [ ] | `nvme-cli` | [`nvme-cli`](https://archlinux.org/packages/extra/x86_64/nvme-cli/) | extra 3.1-1 |
| [ ] | `gnupg` | [`gnupg`](https://archlinux.org/packages/core/x86_64/gnupg/) | core 2.4.9-3 |
| [ ] | `inetutils` | [`inetutils`](https://archlinux.org/packages/core/x86_64/inetutils/) | core 2.8-1 |
| [ ] | `lftp` | [`lftp`](https://archlinux.org/packages/extra/x86_64/lftp/) | extra 4.9.3-2 |
| [ ] | `filezilla` | [`filezilla`](https://archlinux.org/packages/extra/x86_64/filezilla/) | extra 3.71.1-1 |
| [ ] | `php` | [`php`](https://archlinux.org/packages/extra/x86_64/php/) | extra 8.5.11-1 |
| [ ] | `php.packages.composer` | [`composer`](https://archlinux.org/packages/extra/any/composer/) | extra 2.10.3-1 |
| [ ] | `python3 + pillow` | [`python`](https://archlinux.org/packages/core/x86_64/python/), [`python-pillow`](https://archlinux.org/packages/extra/x86_64/python-pillow/) | core 3.14.8-1; extra 12.3.0-1 |
| [ ] | `jdk25` | [`jdk25-openjdk`](https://archlinux.org/packages/extra/x86_64/jdk25-openjdk/) | extra 25.0.4.1.u1-1; Tetap JDK 25; jdk-openjdk saat pemeriksaan sudah mayor 27. |
| [ ] | `nodejs` | [`nodejs`](https://archlinux.org/packages/extra/x86_64/nodejs/) | extra 26.11.1-1 |
| [ ] | `go` | [`go`](https://archlinux.org/packages/extra/x86_64/go/) | extra 2:1.27.2-1 |
| [ ] | `golangci-lint` | [`golangci-lint`](https://archlinux.org/packages/extra/x86_64/golangci-lint/) | extra 2.14.0-1 |
| [ ] | `bun` | [`bun`](https://archlinux.org/packages/extra/x86_64/bun/) | extra 1.4.3-1 |
| [ ] | `maven` | [`maven`](https://archlinux.org/packages/extra/any/maven/) | extra 3.9.16-1 |
| [ ] | `dart` | [`dart`](https://archlinux.org/packages/extra/x86_64/dart/) | extra 3.13.5-1 |
| [ ] | `flutter` | [`flutter-bin`](https://aur.archlinux.org/packages/flutter-bin) | AUR 3.47.6-1; Padanan binary SDK; perhatikan Dart bawaan Flutter dan dart mandiri. |
| [ ] | `wp-cli` | [`wp-cli`](https://archlinux.org/packages/extra/any/wp-cli/) | extra 2.12.0-1 |

### Aplikasi desktop

| Selesai | Deklarasi Nix / komponen | Instalasi di target | Sumber dan catatan |
|---|---|---|---|
| [ ] | `brave` | [`brave-bin`](https://packages.cachyos.org/package/cachyos/x86_64/brave-bin) | cachyos 1:1.97.56-1 |
| [ ] | `chromium` | [`chromium`](https://archlinux.org/packages/extra/x86_64/chromium/) | extra 153.0.8010.52-1 |
| [ ] | `wezterm` | [`wezterm`](https://archlinux.org/packages/extra/x86_64/wezterm/) | extra 20240203.110809.5046fc22.r869.g76b606ec5-3 |
| [ ] | `onlyoffice-desktopeditors` | [`onlyoffice-bin`](https://packages.cachyos.org/package/cachyos/x86_64/onlyoffice-bin) | cachyos 9.4.0-1 |
| [ ] | `qbittorrent` | [`qbittorrent`](https://archlinux.org/packages/extra/x86_64/qbittorrent/) | extra 5.2.4-1 |
| [ ] | `scrcpy` | [`scrcpy`](https://archlinux.org/packages/extra/x86_64/scrcpy/) | extra 5.0.1-1 |
| [ ] | `android-tools` | [`android-tools`](https://archlinux.org/packages/extra/x86_64/android-tools/) | extra 37.0.0-5 |
| [ ] | `mpv` | [`mpv`](https://archlinux.org/packages/extra/x86_64/mpv/) | extra 1:0.41.0-6 |
| [ ] | `pavucontrol` | [`pavucontrol`](https://archlinux.org/packages/extra/x86_64/pavucontrol/) | extra 1:6.2-1 |
| [ ] | `varia` | [`varia`](https://aur.archlinux.org/packages/varia) | AUR 2026.8.5-1 |
| [ ] | `ab-download-manager` | [`ab-download-manager-bin`](https://aur.archlinux.org/packages/ab-download-manager-bin) | AUR 1.10.4-1 |
| [ ] | `adw-gtk3` | [`adw-gtk-theme`](https://archlinux.org/packages/extra/any/adw-gtk-theme/) | extra 6.5-1 |
| [ ] | `nwg-look` | [`nwg-look`](https://archlinux.org/packages/extra/x86_64/nwg-look/) | extra 1.1.2-1 |
| [ ] | `kdePackages.qt6ct` | [`qt6ct`](https://archlinux.org/packages/extra/x86_64/qt6ct/) | extra 0.11-9 |
| [ ] | `firefox` | [`firefox`](https://archlinux.org/packages/extra/x86_64/firefox/) | extra 157.0.1-1 |
| [ ] | `kate` | [`kate`](https://archlinux.org/packages/extra/x86_64/kate/) | extra 26.08.2-1 |

### Hyprland dan KDE

| Selesai | Deklarasi Nix / komponen | Instalasi di target | Sumber dan catatan |
|---|---|---|---|
| [ ] | `hyprlauncher` | [`hyprlauncher`](https://archlinux.org/packages/extra/x86_64/hyprlauncher/) | extra 0.1.6-9 |
| [ ] | `brightnessctl` | [`brightnessctl`](https://archlinux.org/packages/extra/x86_64/brightnessctl/) | extra 0.5.1-3 |
| [ ] | `playerctl` | [`playerctl`](https://archlinux.org/packages/extra/x86_64/playerctl/) | extra 2.4.1-5 |
| [ ] | `kdePackages.kwallet` | [`kwallet`](https://archlinux.org/packages/extra/x86_64/kwallet/) | extra 6.30.0-1 |
| [ ] | `kdePackages.kwallet-pam` | [`kwallet-pam`](https://archlinux.org/packages/extra/x86_64/kwallet-pam/) | extra 6.7.5-1 |
| [ ] | `udiskie` | [`udiskie`](https://archlinux.org/packages/extra/any/udiskie/) | extra 2.7.0-2 |
| [ ] | `xrdb` | [`xorg-xrdb`](https://archlinux.org/packages/extra/x86_64/xorg-xrdb/) | extra 1.2.3-1 |
| [ ] | `kdeconnect-kde` | [`kdeconnect`](https://archlinux.org/packages/extra/x86_64/kdeconnect/) | extra 26.08.2-1 |
| [ ] | `partitionmanager` | [`partitionmanager`](https://archlinux.org/packages/extra/x86_64/partitionmanager/) | extra 26.08.2-1 |

### Database

| Selesai | Deklarasi Nix / komponen | Instalasi di target | Sumber dan catatan |
|---|---|---|---|
| [ ] | `pgcli` | [`pgcli`](https://archlinux.org/packages/extra/any/pgcli/) | extra 4.7.1-1 |
| [ ] | `mycli` | [`mycli`](https://aur.archlinux.org/packages/mycli) | AUR 2.13.2-1 |
| [ ] | `postgresql_17` | [`postgresql17`](https://aur.archlinux.org/packages/postgresql17) | AUR 17.10-1; Pin mayor 17; paket postgresql resmi saat pemeriksaan mayor 18. Periksa layout/service paket AUR. |
| [ ] | `mysql84` | [`mysql84`](https://aur.archlinux.org/packages/mysql84) | AUR 8.4.8-1; Pin MySQL 8.4; mysql AUR saat pemeriksaan mayor 9.7. MariaDB bukan replika persis. |

### Gaming

| Selesai | Deklarasi Nix / komponen | Instalasi di target | Sumber dan catatan |
|---|---|---|---|
| [ ] | `itch` | Aset upstream / konfigurasi; lihat catatan | Gunakan installer Linux resmi itch.io; nama paket AUR itch tidak ditemukan saat pemeriksaan. |
| [ ] | `steam-run` | Aset upstream / konfigurasi; lihat catatan | Wrapper FHS khusus Nix; umumnya tidak perlu di CachyOS. |
| [ ] | `lutris` | [`lutris`](https://archlinux.org/packages/extra/any/lutris/) | extra 0.5.22-3 |
| [ ] | `wineWowPackages.stable` | [`wine`](https://archlinux.org/packages/extra/x86_64/wine/) | extra 11.19-1; Padanan fungsi; wine Arch rolling tidak menjamin versi/channel stable Nix sama. |
| [ ] | `winetricks` | [`winetricks`](https://archlinux.org/packages/extra/any/winetricks/) | extra 20260125-2 |
| [ ] | `prismlauncher` | [`prismlauncher`](https://archlinux.org/packages/extra/x86_64/prismlauncher/) | extra 11.1.1-1 |
| [ ] | `programs.steam` | [`steam`](https://archlinux.org/packages/multilib/x86_64/steam/), [`steam-devices`](https://archlinux.org/packages/multilib/x86_64/steam-devices/) | multilib 1.0.0.87-3; multilib 1.0.0.87-3 |
| [ ] | `proton-ge-bin` | [`proton-ge-custom-bin`](https://aur.archlinux.org/packages/proton-ge-custom-bin) | AUR 1:GE_Proton11_7-1 |
| [ ] | `programs.appimage` | [`fuse2`](https://archlinux.org/packages/extra/x86_64/fuse2/) | extra 2.9.9-6; fuse2 membantu AppImage; registrasi binfmt Nix tidak disalin otomatis. |

### Font

| Selesai | Deklarasi Nix / komponen | Instalasi di target | Sumber dan catatan |
|---|---|---|---|
| [ ] | `noto-fonts` | [`noto-fonts`](https://archlinux.org/packages/extra/any/noto-fonts/) | extra 1:2026.10.01-1 |
| [ ] | `noto-fonts-cjk-sans` | [`noto-fonts-cjk`](https://archlinux.org/packages/extra/any/noto-fonts-cjk/) | extra 20240730-1 |
| [ ] | `noto-fonts-color-emoji` | [`noto-fonts-emoji`](https://archlinux.org/packages/extra/any/noto-fonts-emoji/) | extra 1:2.051-1 |
| [ ] | `nerd-fonts.fira-code` | [`ttf-firacode-nerd`](https://archlinux.org/packages/extra/any/ttf-firacode-nerd/) | extra 3.5.1-2 |
| [ ] | `nerd-fonts.meslo-lg` | [`ttf-meslo-nerd`](https://archlinux.org/packages/extra/any/ttf-meslo-nerd/) | extra 3.5.1-2 |
| [ ] | `maple-mono.NF` | Aset upstream / konfigurasi; lihat catatan | Ambil varian NF dari release upstream Maple Mono; pastikan nama family Maple Mono NF. |
| [ ] | `nerd-fonts.caskaydia-cove` | [`ttf-cascadia-code-nerd`](https://archlinux.org/packages/extra/any/ttf-cascadia-code-nerd/) | extra 3.5.1-2 |
| [ ] | `nerd-fonts.comic-shanns-mono` | [`otf-comicshanns-nerd`](https://archlinux.org/packages/extra/any/otf-comicshanns-nerd/) | extra 3.5.1-2 |
| [ ] | `corefonts` | [`ttf-ms-fonts`](https://aur.archlinux.org/packages/ttf-ms-fonts) | AUR 2.0-12 |
| [ ] | `open-sans` | [`ttf-opensans`](https://archlinux.org/packages/extra/any/ttf-opensans/) | extra 3.003-1 |

### Paket Home Manager dan shell

| Selesai | Deklarasi Nix / komponen | Instalasi di target | Sumber dan catatan |
|---|---|---|---|
| [ ] | `fish` | [`fish`](https://archlinux.org/packages/extra/x86_64/fish/) | extra 4.9.3-1 |
| [ ] | `direnv` | [`direnv`](https://archlinux.org/packages/extra/x86_64/direnv/) | extra 2.38.2-1 |
| [ ] | `nix-direnv` | Aset upstream / konfigurasi; lihat catatan | Hanya jika tetap memakai Nix; direnv biasa tetap masuk checklist. |
| [ ] | `eza` | [`eza`](https://archlinux.org/packages/extra/x86_64/eza/) | extra 0.23.5-2 |
| [ ] | `fzf` | [`fzf`](https://archlinux.org/packages/extra/x86_64/fzf/) | extra 0.74.4-1 |
| [ ] | `zoxide` | [`zoxide`](https://archlinux.org/packages/extra/x86_64/zoxide/) | extra 0.10.0-1 |
| [ ] | `starship` | [`starship`](https://archlinux.org/packages/extra/x86_64/starship/) | extra 1.26.0-1 |
| [ ] | `delta` | [`git-delta`](https://archlinux.org/packages/extra/x86_64/git-delta/) | extra 0.20.1-1 |
| [ ] | `gnupg` | [`gnupg`](https://archlinux.org/packages/core/x86_64/gnupg/) | core 2.4.9-3 |
| [ ] | `pinentry-curses` | [`pinentry`](https://archlinux.org/packages/core/x86_64/pinentry/) | core 1.3.3-1 |
| [ ] | `papirus-icon-theme` | [`papirus-icon-theme`](https://archlinux.org/packages/extra/any/papirus-icon-theme/) | extra 20260801-1 |
| [ ] | `catppuccin-kde` | Aset upstream / konfigurasi; lihat catatan | Aset upstream; 4 flavor, 10 aksen, modern window decoration; bukan nama paket pacman terverifikasi. |
| [ ] | `Moe-Dark` | Aset upstream / konfigurasi; lihat catatan | Aset GitLab jomada/moe-dark, revision tercantum di lampiran. |
| [ ] | `WhiteSur-cursors` | Aset upstream / konfigurasi; lihat catatan | Aset GitHub vinceliuice/WhiteSur-cursors, revision tercantum di lampiran. |

### Desktop, service, dan driver yang diaktifkan modul

| Selesai | Deklarasi Nix / komponen | Instalasi di target | Sumber dan catatan |
|---|---|---|---|
| [ ] | `services.displayManager.sddm` | [`sddm`](https://archlinux.org/packages/extra/x86_64/sddm/) | extra 0.21.0-7 |
| [ ] | `services.desktopManager.plasma6` | [`plasma-meta`](https://archlinux.org/packages/extra/any/plasma-meta/), [`dolphin`](https://archlinux.org/packages/extra/x86_64/dolphin/), [`ark`](https://archlinux.org/packages/extra/x86_64/ark/), [`spectacle`](https://archlinux.org/packages/extra/x86_64/spectacle/), [`plasma-systemmonitor`](https://archlinux.org/packages/extra/x86_64/plasma-systemmonitor/) | extra 6.7-2; extra 26.08.2-1; extra 26.08.2-1; extra 1:6.7.5-1; extra 6.7.5-1 |
| [ ] | `services.xserver` | [`xorg-server`](https://archlinux.org/packages/extra/x86_64/xorg-server/) | extra 21.1.25-1 |
| [ ] | `programs.hyprland` | [`hyprland`](https://archlinux.org/packages/extra/x86_64/hyprland/), [`xorg-xwayland`](https://archlinux.org/packages/extra/x86_64/xorg-xwayland/) | extra 0.56.2-4; extra 24.1.14-1 |
| [ ] | `programs.noctalia` | [`noctalia`](https://archlinux.org/packages/extra/x86_64/noctalia/) | extra 5.2.1-1 |
| [ ] | `kernel target CachyOS` | [`linux-cachyos`](https://packages.cachyos.org/package/cachyos/x86_64/linux-cachyos) | cachyos 7.2.7-1; Komponen target dari installer CachyOS, bukan kernel CachyOS aktif yang dideklarasikan profil Nix. Headers hanya jika diperlukan untuk DKMS/build modul. |
| [ ] | `services.pipewire + rtkit` | [`pipewire`](https://archlinux.org/packages/extra/x86_64/pipewire/), [`pipewire-alsa`](https://archlinux.org/packages/extra/x86_64/pipewire-alsa/), [`pipewire-pulse`](https://archlinux.org/packages/extra/x86_64/pipewire-pulse/), [`wireplumber`](https://archlinux.org/packages/extra/x86_64/wireplumber/), [`rtkit`](https://archlinux.org/packages/extra/x86_64/rtkit/), [`lib32-alsa-lib`](https://archlinux.org/packages/multilib/x86_64/lib32-alsa-lib/), [`lib32-alsa-plugins`](https://archlinux.org/packages/multilib/x86_64/lib32-alsa-plugins/) | extra 1:1.6.9-1; extra 1:1.6.9-1; extra 1:1.6.9-1; extra 0.5.18-1; extra 0.14-1; multilib 1.2.16.1-1; multilib 1.2.12-1 |
| [ ] | `hardware.graphics AMD + 32-bit` | [`mesa`](https://archlinux.org/packages/extra/x86_64/mesa/), [`lib32-mesa`](https://archlinux.org/packages/multilib/x86_64/lib32-mesa/), [`vulkan-radeon`](https://archlinux.org/packages/extra/x86_64/vulkan-radeon/), [`lib32-vulkan-radeon`](https://archlinux.org/packages/multilib/x86_64/lib32-vulkan-radeon/) | extra 1:26.2.4-1; multilib 1:26.2.4-1; extra 1:26.2.4-1; multilib 1:26.2.4-1 |
| [ ] | `hardware.cpu.amd / firmware` | [`amd-ucode`](https://archlinux.org/packages/core/any/amd-ucode/), [`linux-firmware`](https://archlinux.org/packages/core/any/linux-firmware/) | core 20260916-1; core 20260916-1 |
| [ ] | `services.NetworkManager` | [`networkmanager`](https://archlinux.org/packages/extra/x86_64/networkmanager/) | extra 1.58.1-2 |
| [ ] | `hardware.bluetooth` | [`bluez`](https://archlinux.org/packages/extra/x86_64/bluez/), [`bluez-utils`](https://archlinux.org/packages/extra/x86_64/bluez-utils/) | extra 5.87-2; extra 5.87-2 |
| [ ] | `services.openssh` | [`openssh`](https://archlinux.org/packages/core/x86_64/openssh/) | core 10.6p1-1 |
| [ ] | `services.tailscale` | [`tailscale`](https://archlinux.org/packages/extra/x86_64/tailscale/) | extra 1.104.1-1 |
| [ ] | `services.upower` | [`upower`](https://archlinux.org/packages/extra/x86_64/upower/) | extra 1.91.5-1 |
| [ ] | `services.udisks2` | [`udisks2`](https://archlinux.org/packages/extra/x86_64/udisks2/) | extra 2.11.2-1 |
| [ ] | `security.polkit` | [`polkit`](https://archlinux.org/packages/extra/x86_64/polkit/) | extra 127-3 |
| [ ] | `services.printing` | [`cups`](https://archlinux.org/packages/extra/x86_64/cups/) | extra 2:2.4.20-1 |
| [ ] | `services.tlp + pd` | [`tlp`](https://archlinux.org/packages/extra/any/tlp/), [`tlp-pd`](https://archlinux.org/packages/extra/any/tlp-pd/) | extra 1.10.2-1; extra 1.10.2-1 |
| [ ] | `podman` | [`podman`](https://archlinux.org/packages/extra/x86_64/podman/) | extra 6.1.3-1 |
| [ ] | `waydroid-nftables` | [`waydroid`](https://archlinux.org/packages/extra/any/waydroid/) | extra 1.6.3-1; Padanan fungsi; periksa backend firewall dan dukungan binder kernel. Bukan bukti paket ini memakai patch nftables Nix. |
| [ ] | `wireshark` | [`wireshark-qt`](https://archlinux.org/packages/extra/x86_64/wireshark-qt/), [`wireshark-cli`](https://archlinux.org/packages/extra/x86_64/wireshark-cli/) | extra 4.7.4-1; extra 4.7.4-1 |
| [ ] | `boot.loader.limine` | [`limine`](https://archlinux.org/packages/extra/x86_64/limine/), [`limine-mkinitcpio-hook`](https://packages.cachyos.org/package/cachyos/x86_64/limine-mkinitcpio-hook) | extra 12.9.3-1; cachyos 1.40.0-1; limine-mkinitcpio-hook dari integrasi CachyOS; cek pacman -Si pada target. |
| [ ] | `boot.plymouth` | [`plymouth`](https://archlinux.org/packages/extra/x86_64/plymouth/) | extra 26.134.222-3 |
| [ ] | `catppuccin-plymouth` | Aset upstream / konfigurasi; lihat catatan | Aset upstream Catppuccin Plymouth, mocha. |
| [ ] | `portal desktop` | [`xdg-desktop-portal`](https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal/), [`xdg-desktop-portal-kde`](https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-kde/), [`xdg-desktop-portal-gtk`](https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-gtk/) | extra 1.22.1-2; extra 6.7.5-1; extra 1.15.3-1 |
| [ ] | `qylock-sddm-themes` | Aset upstream / konfigurasi; lihat catatan | Salin tema lokal ~/qylock/themes/noctalia-sync; qylock-lock tidak digunakan. |
| [ ] | `SDDM Qt modules` | [`qt6-5compat`](https://archlinux.org/packages/extra/x86_64/qt6-5compat/), [`qt6-multimedia`](https://archlinux.org/packages/extra/x86_64/qt6-multimedia/), [`qt6-svg`](https://archlinux.org/packages/extra/x86_64/qt6-svg/) | extra 6.12.0-1; extra 6.12.0-1; extra 6.12.0-1 |
| [ ] | `AB runtime Linux` | [`alsa-lib`](https://archlinux.org/packages/extra/x86_64/alsa-lib/), [`dbus`](https://archlinux.org/packages/core/x86_64/dbus/), [`fontconfig`](https://archlinux.org/packages/extra/x86_64/fontconfig/), [`freetype2`](https://archlinux.org/packages/extra/x86_64/freetype2/), [`libglvnd`](https://archlinux.org/packages/extra/x86_64/libglvnd/), [`libappindicator`](https://archlinux.org/packages/extra/x86_64/libappindicator/), [`wayland`](https://archlinux.org/packages/extra/x86_64/wayland/), [`libxkbcommon`](https://archlinux.org/packages/extra/x86_64/libxkbcommon/), [`libx11`](https://archlinux.org/packages/extra/x86_64/libx11/), [`libxext`](https://archlinux.org/packages/extra/x86_64/libxext/), [`libxi`](https://archlinux.org/packages/extra/x86_64/libxi/), [`libxrender`](https://archlinux.org/packages/extra/x86_64/libxrender/), [`libxtst`](https://archlinux.org/packages/extra/x86_64/libxtst/), [`zlib`](https://archlinux.org/packages/core/x86_64/zlib/) | extra 1.2.16.1-1; core 1.16.2-1; extra 2:2.18.3-2; extra 2.14.3-1; extra 1.7.0-3; extra 12.10.1-2; extra 1.26.0-1; extra 1.13.2-1; extra 1.8.13-2; extra 1.3.7-1; extra 1.8.3-1; extra 0.9.12-1; extra 1.2.5-1; core 1:1.3.2-3 |

### Cara memakai daftar

Jalankan perintah berikut **di CachyOS**, sesudah repositori target diperbarui.
Dokumen ini tidak mengeksekusi perintah-perintah tersebut.

```bash
sudo pacman -Syu
pacman -Si hyprland noctalia jdk25-openjdk
```

Untuk kelompok paket repo Arch/CachyOS, gunakan `sudo pacman -S --needed ...` dengan daftar di bawah.
`multilib` diperlukan untuk paket 32-bit; gunakan konfigurasi repositori milik installer
CachyOS. Pilih provider AMD ketika pacman meminta provider Vulkan.

Untuk AUR, gunakan helper yang tersedia pada target, misalnya `paru -S --needed ...`.
Daftar AUR dipisahkan agar tidak ikut dikirim ke pacman. Paket resmi CachyOS dengan nama
dan tujuan setara boleh dipilih setelah dicek dengan `pacman -Si`.

#### Nama paket repo Arch/CachyOS yang terverifikasi

```text
7zip adw-gtk-theme aircrack-ng alsa-lib alsa-utils amd-ucode android-tools arch-install-scripts
ark aspell aspell-en bat bind bluez bluez-utils brave-bin
brightnessctl btop bully bun chafa chromium claude-code composer
cpupower cups curl dart dbus direnv dolphin duf
dust efibootmgr ethtool evtest eza fastfetch fd ffmpeg
file filezilla firefox fish fontconfig freetype2 fuse2 fzf
git git-delta github-cli gnupg go golangci-lint htop hyprland
hyprlauncher imagemagick inetutils iw jdk25-openjdk jq kate kdeconnect
kwallet kwallet-pam lazygit lftp lib32-alsa-lib lib32-alsa-plugins lib32-mesa lib32-vulkan-radeon
libappindicator libglvnd libinput libx11 libxext libxi libxkbcommon libxrender
libxtst limine limine-mkinitcpio-hook linux-cachyos linux-firmware lm_sensors lutris maven
mesa micro mpv mpv-mpris networkmanager noctalia nodejs noto-fonts
noto-fonts-cjk noto-fonts-emoji nvme-cli nwg-look onlyoffice-bin openai-codex opencode openssh
openssl otf-comicshanns-nerd papirus-icon-theme partitionmanager pavucontrol pciutils pdfarranger pgcli
php pinentry pipewire pipewire-alsa pipewire-pulse plasma-meta plasma-systemmonitor playerctl
plocate plymouth podman podman-compose polkit prismlauncher psmisc python
python-pillow qbittorrent qpdf qt6-5compat qt6-multimedia qt6-svg qt6ct rclone
reaver restic ripgrep rtkit samba scrcpy sddm spectacle
starship steam steam-devices stress-ng tailscale telegram-desktop tesseract tlp
tlp-pd tree ttf-cascadia-code-nerd ttf-firacode-nerd ttf-meslo-nerd ttf-opensans udiskie udisks2
unrar unzip upower usbutils vim vulkan-radeon waydroid wayland
wezterm wget wine winetricks wireless_tools wireplumber wireshark-cli wireshark-qt
wl-clipboard wp-cli wpa_supplicant xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-kde xh xorg-server
xorg-xrdb xorg-xwayland yt-dlp zellij zip zlib zoxide
```

#### Nama paket AUR yang terverifikasi

```text
ab-download-manager-bin aspell-id bruno-bin flutter-bin gallery-dl mycli mysql84 podman-tui
postgresql17 proton-ge-custom-bin rustdesk-bin ttf-ms-fonts varia visual-studio-code-bin
```

### Versi dan padanan yang memerlukan perhatian

- **PostgreSQL:** setup lama 17; paket `postgresql` resmi saat pemeriksaan 18.6.
  `postgresql17` AUR terverifikasi 17.10. Pilih mayor sebelum inisialisasi atau restore.
- **MySQL:** setup lama 8.4; `mysql84` AUR terverifikasi 8.4.8. Paket `mysql` AUR saat
  pemeriksaan 9.7.1. MariaDB bukan pengganti identik MySQL untuk semua aplikasi.
- **Java:** setup lama 25; gunakan `jdk25-openjdk`, bukan sekadar `jdk-openjdk`.
- **Hyprland:** config repo memakai Lua. Wiki menjelaskan perpindahan ke Lua sejak 0.55;
  paket Arch saat pemeriksaan 0.56.2. Cocokkan dispatcher/rules dengan versi target.
  [Dokumentasi konfigurasi](https://wiki.hypr.land/Configuring/Start/).
- **Noctalia:** repo menggunakan model v5 (`noctalia`, TOML, `noctalia msg`). Instal
  `noctalia`, bukan setup legacy Quickshell v4. qylock juga tidak dipakai sebagai lockscreen.
  [Instalasi Noctalia](https://docs.noctalia.dev/noctalia/getting-started/installation/).
- **Waydroid:** `waydroid` target adalah padanan fungsi, bukan jaminan patch nftables
  yang sama dengan `waydroid-nftables` di Nix.
- **AppImage:** bawa perilaku menjalankan AppImage; registrasi binfmt Nix tidak otomatis
  dibuat dengan memasang `fuse2`.
- **AB Download Manager:** setup lama dan kandidat AUR sama-sama 1.10.4 saat pemeriksaan;
  wrapper Nix memakai `SKIKO_RENDER_API=SOFTWARE`, JRE sudah dibundel aplikasi.

## 3. Backup dan data di luar repo

| Item | Lokasi / cara membawa |
|---|---|
| Repo deklarasi | `~/nixos-config` |
| Tema SDDM kustom | `~/qylock/themes/noctalia-sync`; backup seluruh clone `~/qylock` |
| Config native Noctalia | `~/.config/noctalia/config.toml`, script, template |
| Widget dan perubahan GUI Noctalia | `~/.local/state/noctalia/settings.toml`; data runtime lain bila dibutuhkan |
| Wallpaper | `~/Pictures/Wallpapers` |
| Sticker | `~/Pictures/Liked Images Square` |
| Ikon launcher Plasma | `~/Pictures/miku-ghosling.ico` |
| Warna/wallpaper SDDM | `~/.config/qylock/colors.json`, `wallpaper.txt`; bisa digenerate lagi |
| Tema Moe-Dark | Direktori look-and-feel, desktoptheme, Aurorae, colors, wallpaper di `~/.local/share` |
| Cursor | `~/.icons/WhiteSur-cursors` |
| Font Itim tema login | `~/qylock/themes/noctalia-sync/font/Itim-Regular.ttf` |
| Plugin Micro hasil fetch | `~/.config/micro/plug` dan `colorschemes`, termasuk target symlink |
| Palette WezTerm | `~/.config/wezterm/colors/Noctalia.toml` |
| Wallet | `~/.local/share/kwalletd` dan/atau `~/.local/share/kwalletd6` yang memang ada |
| Browser | Profil Brave, Chromium, Firefox; tidak dideklarasikan oleh repo |
| Kunci dan kredensial | `~/.ssh`, `~/.gnupg`, login CLI yang dibutuhkan; simpan sebagai backup privat |
| VS Code | Settings/extensions/profil lokal; repo hanya menginstal aplikasi |
| Database | Logical dump PostgreSQL 17 dan MySQL 8.4, termasuk role/privilege |
| Game dan container | Save game, library Steam/Prism/Lutris, volume Podman, data Waydroid |

**Home Manager membuat symlink ke `/nix/store`.** Gunakan salinan dereference untuk
dotfile/aset yang ingin tetap dipakai setelah NixOS dihapus. Backup symlink saja tidak cukup.
Contoh export berikut dijalankan dari **Bash di NixOS sebelum migrasi**; tidak memodifikasi
file asli. Ini export terpilih, bukan backup penuh profil browser atau data database.

```bash
backup_root="$HOME/cachyos-thinkpad-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_root/config" "$backup_root/state" "$backup_root/share" "$backup_root/source"
chmod 700 "$backup_root"

for name in hypr noctalia qylock wezterm micro mpv fish udiskie; do
  if [ -e "$HOME/.config/$name" ]; then
    cp -aL "$HOME/.config/$name" "$backup_root/config/"
  fi
done

for name in starship.toml kdeglobals kwinrc kwinrulesrc kglobalshortcutsrc dolphinrc katerc spectaclerc kded5rc kwalletrc krunnerrc plasma-localerc plasmashellrc plasma-org.kde.plasma.desktop-appletsrc; do
  if [ -e "$HOME/.config/$name" ]; then
    cp -aL "$HOME/.config/$name" "$backup_root/config/"
  fi
done

if [ -d "$HOME/.local/state/noctalia" ]; then
  cp -aL "$HOME/.local/state/noctalia" "$backup_root/state/"
fi

for name in plasma color-schemes aurorae wallpapers kwalletd kwalletd6; do
  if [ -d "$HOME/.local/share/$name" ]; then
    cp -aL "$HOME/.local/share/$name" "$backup_root/share/"
  fi
done

if [ -e "$HOME/.icons/WhiteSur-cursors" ]; then
  mkdir -p "$backup_root/icons"
  cp -aL "$HOME/.icons/WhiteSur-cursors" "$backup_root/icons/"
fi

cp -a "$HOME/nixos-config" "$backup_root/source/"
cp -a "$HOME/qylock" "$backup_root/source/"
cp -a "$HOME/Pictures" "$backup_root/"
```

Simpan hasil export ke media yang akan tetap tersedia setelah instalasi. Restore Fish
dari konfigurasi native di bagian 7 atau audit hasil exportnya: beberapa integrasi shell
Home Manager bisa masih merujuk executable `/nix/store`. Jangan membawa `.gitconfig`
Nix tanpa memperbaiki path pager Delta.

## 4. Konfigurasi sistem ThinkPad

### Identitas, locale, user

| Pengaturan | Nilai |
|---|---|
| Hostname | `lenovo-thinkpad-t14-personal` |
| User / deskripsi | `rizz404` / `Rizqiansyah` |
| Timezone | `Asia/Jakarta` |
| Locale | `en_US.UTF-8` |
| Keyboard | `us`, variant kosong |
| Shell | `/usr/bin/fish` |
| Administrasi | Grup `wheel`; sudo mengikuti setup CachyOS |
| Network user group lama | `networkmanager`; pada target periksa grup yang tersedia dan otorisasi NetworkManager/Polkit |
| Permission home | `711`, untuk akses traverse SDDM ke aset wallpaper/warna |

```bash
sudo hostnamectl set-hostname lenovo-thinkpad-t14-personal
sudo timedatectl set-timezone Asia/Jakarta
# Aktifkan en_US.UTF-8 UTF-8 di /etc/locale.gen, kemudian:
sudo locale-gen
sudo localectl set-locale LANG=en_US.UTF-8
chsh -s /usr/bin/fish
chmod 711 "$HOME"
```

### Disk, kernel, dan early KMS

Setup sumber: root Btrfs, subvolume `home` pada `/home`, subvolume `nix` pada `/nix`,
ESP FAT pada `/boot`, swapfile 4 GiB di `/var/lib/swapfile`.
UUID lama tercantum pada lampiran hardware untuk referensi; **buat `/etc/fstab` dari
filesystem target**. `/nix` dibutuhkan hanya bila masih memakai Nix. Tidak ada konfigurasi
enkripsi atau resume hibernation yang dideklarasikan dalam profil sumber ini.

Instal microcode AMD dan firmware. GPU menggunakan `amdgpu`; virtualisasi menggunakan
`kvm-amd`. Modul initrd sumber tersedia: `nvme`, `ehci_pci`, `xhci_pci_renesas`, `xhci_pci`,
`usb_storage`, `sd_mod`, `rtsx_pci_sdmmc`; biarkan mkinitcpio mendeteksi kebutuhan host,
dengan `amdgpu` dimuat awal untuk Plymouth.

Tambahkan `amdgpu` ke array `MODULES` yang sudah ada di `/etc/mkinitcpio.conf` atau drop-in
target, tanpa menghapus modul installer. Contoh bila sebelumnya kosong:

```bash
MODULES=(amdgpu)
```

Untuk `kvm-amd`, kernel biasanya memuatnya ketika diperlukan; bila ingin eksplisit,
buat `/etc/modules-load.d/thinkpad-kvm.conf` dengan satu baris `kvm-amd`.

### Limine dan Plymouth

Pilih Limine dari setup CachyOS. Konfigurasi sumber memakai timeout `0` dan `quiet: yes`.
Periksa lokasi config aktif (`/boot/limine.conf` atau ESP). Parameter kernel dikelola
CachyOS melalui `/etc/default/limine`; **pertahankan parameter root, subvolume, dan resume
milik installer**, lalu tambahkan parameter tampilan dari Nix:

```text
quiet splash loglevel=3 rd.systemd.show_status=false rd.udev.log_level=3 udev.log_priority=3
```

Tambahkan hook Plymouth mengikuti urutan hook mkinitcpio target dan instal tema
Catppuccin Mocha. Sesudah theme/config siap:

```bash
sudo plymouth-set-default-theme catppuccin-mocha
sudo limine-mkinitcpio
```

Pastikan nama tema benar-benar muncul dalam `plymouth-set-default-theme -l`.
Untuk mempertahankan console log level Nix, gunakan `kernel.printk = 0 4 1 7` dalam
drop-in sysctl bila memang ingin console sepi; silent boot utama sudah ditangani command line.
`boot.initrd.verbose=false` adalah opsi Nix, padanannya mengikuti hook/initrd target.

Integrasi Limine CachyOS otomatis mengelola entry melalui `limine-mkinitcpio-hook`;
jangan menyalin path kernel `/nix/store` atau konfigurasi boot host lain.
[Panduan boot manager CachyOS](https://wiki.cachyos.org/configuration/boot_manager_configuration/).

### Swap

Target perilaku: **swap 4096 MiB**, tidak ada konfigurasi hibernation pada repo.
Jika installer sudah menyediakan swap/zram, tentukan apakah ingin tetap menyamai swapfile
lama. Untuk Btrfs, gunakan prosedur swapfile Btrfs yang mendukung NOCOW/no holes dan
daftarkan path target ke fstab; jangan membuat swap Btrfs dengan menyalin file biasa.
[Btrfs swapfile](https://btrfs.readthedocs.io/en/latest/Swapfile.html).

### Power button dan idle suspend

Buat `/etc/systemd/logind.conf.d/10-thinkpad.conf`:

```ini
[Login]
HandlePowerKey=suspend
IdleAction=suspend
IdleActionSec=15min
```

Aturan logind mencakup sebelum login/greeter. Idle Noctalia menambahkan dim, lock, dan
DPMS di dalam sesi; bukan service suspend terpisah. Terapkan logind saat reboot berikutnya.

### TLP dan charging

Buat `/etc/tlp.d/10-thinkpad.conf`:

```ini
START_CHARGE_THRESH_BAT0=50
STOP_CHARGE_THRESH_BAT0=90
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=off
```

```bash
# Jalankan disable hanya bila service ini memang terpasang/aktif:
sudo systemctl disable --now power-profiles-daemon.service
sudo systemctl enable --now tlp.service tlp-pd.service
sudo tlp start
tlp-stat -s
tlp-stat -b
```

`tlp-pd` menyediakan integrasi profil daya GUI; kedua service diperlukan untuk perilaku
yang sama. [Dokumentasi service TLP](https://linrunner.de/tlp/faq/installation.html).

Charge-kick sumber dijalankan setelah boot/resume untuk kondisi `Not charging` padahal
capacity belum mencapai stop threshold. Simpan script berikut di
`/usr/local/bin/tlp-charge-kick` dan beri mode `755`:

```bash
#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin

# kasih waktu subsistem power_supply update status setelah resume/boot
sleep 3

for bat_dir in /sys/class/power_supply/BAT*; do
  [ -d "$bat_dir" ] || continue
  status_file="$bat_dir/status"
  cap_file="$bat_dir/capacity"
  stop_file="$bat_dir/charge_control_end_threshold"
  [ -r "$status_file" ] && [ -r "$cap_file" ] || continue

  status=$(cat "$status_file")
  capacity=$(cat "$cap_file")
  stop_thresh=$(cat "$stop_file" 2>/dev/null || echo 100)

  if [ "$status" = "Not charging" ] && [ "$capacity" -lt "$((stop_thresh - 1))" ]; then
    logger -t tlp-charge-kick "$(basename "$bat_dir") nyangkut di $capacity% (status=Not charging, stop=$stop_thresh%), kick charging"
    tlp chargeonce || true
    sleep 2
    tlp start || true
  fi
done
```

Buat `/etc/systemd/system/tlp-charge-kick-boot.service`:

```ini
[Unit]
Description=Restore ThinkPad charging after boot
After=tlp.service
Wants=tlp.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/tlp-charge-kick

[Install]
WantedBy=multi-user.target
```

Buat `/etc/systemd/system/tlp-charge-kick-resume.service`:

```ini
[Unit]
Description=Restore ThinkPad charging after resume
Before=sleep.target
After=tlp-sleep.service
StopWhenUnneeded=yes

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/true
ExecStop=/usr/local/bin/tlp-charge-kick

[Install]
WantedBy=sleep.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable tlp-charge-kick-boot.service tlp-charge-kick-resume.service
```

`After=tlp-sleep.service` mengikuti source Nix; cek apakah nama unit TLP target sama,
dan sesuaikan ordering bila packaging target berbeda. Uji reboot dan suspend/resume.

## 5. Desktop, portal, wallet, dan login

### Service

| Komponen | Unit / pengaturan target |
|---|---|
| NetworkManager | `NetworkManager.service` |
| Bluetooth | `bluetooth.service` |
| SSH | `sshd.service` |
| Tailscale | `tailscaled.service` |
| Printing | `cups.service` |
| Display manager | `sddm.service` |
| UPower, UDisks2, Polkit | Service D-Bus/system; sering aktif otomatis ketika dibutuhkan |
| Audio | PipeWire, WirePlumber, pipewire-pulse pada user session; ALSA dan 32-bit support |
| Locate | Timer updatedb milik plocate; cek unit yang disediakan paket |
| GPG agent | User socket/service paket GnuPG, pinentry curses |
| Udiskie | User service di bawah; automount aktif |

```bash
sudo systemctl enable --now NetworkManager.service bluetooth.service sshd.service tailscaled.service cups.service
sudo systemctl enable sddm.service
```

Jalankan hanya satu display manager. Installer CachyOS bisa memakai display manager
lain untuk Plasma; sesuaikan ke SDDM bila ingin memakai tema sumber ini.

Buat `/etc/systemd/system/tailscaled.service.d/10-stop-timeout.conf`:

```ini
[Service]
TimeoutStopSec=5s
```

### Portal dan wallet

Instal backend KDE/GTK/Hyprland; buat `~/.config/xdg-desktop-portal/portals.conf`:

```ini
[preferred]
default=*
org.freedesktop.impl.portal.Secret=kwallet
```

Ini mempertahankan pilihan Secret KWallet lintas Plasma/Hyprland, penting untuk
encryption key Brave sync. Pertahankan pemilihan screencast/screenshot backend Hyprland
dari config desktop/package; jangan menimpa interface lain dengan backend Secret.

Instal `kwallet` dan `kwallet-pam`. SDDM biasanya sudah menyediakan baris PAM wallet;
periksa file paket sebelum menambah baris. Untuk Plasma 6, bentuk yang didokumentasikan:

```text
auth       optional pam_kwallet5.so
session    optional pam_kwallet5.so auto_start kwalletd=/usr/bin/ksecretd
```

Untuk login TTY, konfigurasi `login` dapat membutuhkan `force_run`; ikuti konfigurasi
PAM target. Hyprland juga menjalankan **`/usr/lib/pam_kwallet_init`** saat startup.
Placeholder `@KWALLET_PAM_INIT@` dalam source harus diganti dengan path executable target.
Wallet auto-unlock mengikuti password user dan jenis wallet yang didukung PAM.
[KDE Wallet pada Arch](https://wiki.archlinux.org/title/KDE_Wallet).

### Menu aplikasi Dolphin pada Hyprland

Source menetapkan `XDG_MENU_PREFIX=hyprland-`; buat
`/etc/xdg/menus/hyprland-applications.menu`:

```xml
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
<Menu>
  <Name>Applications</Name>
  <DefaultAppDirs/>
  <DefaultDirectoryDirs/>
  <DefaultMergeDirs/>
</Menu>
```

### SDDM noctalia-sync

Salin folder **`~/qylock/themes/noctalia-sync`** berikut fontnya ke
`/usr/share/sddm/themes/noctalia-sync`. Buat `/etc/sddm.conf.d/10-noctalia-sync.conf`:

```ini
[Theme]
Current=noctalia-sync

[General]
GreeterEnvironment=QML_XHR_ALLOW_FILE_READ=1
```

Jika ada `GreeterEnvironment` lain dari target, gabungkan nilainya. Theme membaca path
hardcoded `/home/rizz404/.config/qylock/colors.json` dan `wallpaper.txt`;
ubah Main.qml bila username/home berubah. Pastikan user `sddm` dapat traverse seluruh
parent dan membaca file wallpaper/JSON/font; mode home `711` saja belum menjamin semua
subdirektori dapat dibaca. Script dan template Noctalia menghasilkan kedua file tersebut.

Theme memerlukan Qt6 dan impor `Qt5Compat.GraphicalEffects`; paket pendukung ada di
daftar instalasi. **Jangan instal/aktifkan qylock-lock** untuk mengganti lockscreen sesi:
repo memakai lockscreen native Noctalia. Font binary Itim perlu disalin dari clone,
isi QML/config theme dilampirkan dalam dokumen ini.

## 6. Hyprland dan Noctalia

### Pemetaan seluruh file

Path sumber relatif terhadap root `nixos-config`.

| Source | Tujuan CachyOS |
|---|---|
| `home/rizz404/hyprland/hyprland.lua` + `home/rizz404/noctalia/noctalia.lua` | Gabung menjadi `~/.config/hypr/hyprland.lua`, bagian Hyprland lebih dulu |
| `home/rizz404/hyprland/modules/*.lua` | `~/.config/hypr/modules/hyprland/` |
| `home/rizz404/noctalia/modules/*.lua` | `~/.config/hypr/modules/noctalia/` |
| `home/rizz404/hyprland/*.sh` | `~/.config/hypr/`, executable |
| `home/rizz404/noctalia/*.sh` | `~/.config/noctalia/`, executable |
| `home/rizz404/noctalia/qylock-colors.json.tmpl` | `~/.config/noctalia/templates/qylock-colors.json.tmpl` |
| Native `~/.config/noctalia/config.toml` | Path sama; isi lengkap ada di bagian 11 |
| Runtime `~/.local/state/noctalia/settings.toml` | Path sama; membawa layout widget dan override GUI |

Contoh restore source (Bash, pada target, dengan repo di `~/nixos-config`). Tujuan sebaiknya
file biasa; jika masih ada symlink Home Manager, ganti dengan salinan hasil backup terlebih
dahulu. Script ini menimpa file konfigurasi target yang disebutkan.

```bash
repo="$HOME/nixos-config"
mkdir -p "$HOME/.config/hypr/modules/hyprland" "$HOME/.config/hypr/modules/noctalia"
mkdir -p "$HOME/.config/noctalia/templates" "$HOME/.config/qylock"

cat "$repo/home/rizz404/hyprland/hyprland.lua" "$repo/home/rizz404/noctalia/noctalia.lua" > "$HOME/.config/hypr/hyprland.lua"
cp "$repo/home/rizz404/hyprland/modules/"*.lua "$HOME/.config/hypr/modules/hyprland/"
cp "$repo/home/rizz404/noctalia/modules/"*.lua "$HOME/.config/hypr/modules/noctalia/"
cp "$repo/home/rizz404/hyprland/"*.sh "$HOME/.config/hypr/"
cp "$repo/home/rizz404/noctalia/"*.sh "$HOME/.config/noctalia/"
cp "$repo/home/rizz404/noctalia/qylock-colors.json.tmpl" "$HOME/.config/noctalia/templates/"

# Verifikasi path berikut tersedia dari paket kwallet-pam di target:
test -x /usr/lib/pam_kwallet_init
sed -i 's|@KWALLET_PAM_INIT@|/usr/lib/pam_kwallet_init|g' "$HOME/.config/hypr/modules/hyprland/autostart.lua"
chmod +x "$HOME/.config/hypr/"*.sh "$HOME/.config/noctalia/"*.sh
```

Restore `config.toml` dari export NixOS atau salin isi native bagian 11. Tidak cukup hanya
menyalin `default.nix`: file itu membutuhkan Nix untuk menghasilkan TOML.

### Nilai Hyprland yang dipertahankan

| Modul | Pengaturan |
|---|---|
| Monitors | Output default, preferred mode, position auto, scale auto |
| Programs | WezTerm, Dolphin, hyprlauncher |
| Autostart | Hentikan socket DrKonqi jika ada; init KWallet; `Xft.dpi: 144` via xrdb |
| Environment | Cursor size 24; menu prefix `hyprland-`; Qt KDE platform theme dikomentari |
| Permissions | Kosong |
| Appearance | Dwindle; gaps 4/4; border 1; rounding 8/power 2; opacity 1/1; shadow range 4/render power 3/color `0xee1a1a1a`; blur size 3/pass 1/vibrancy 0.1696; tearing dan resize-on-border mati |
| Animations | Enabled; Bézier easeOutQuint/easeInOutCubic dan spring `easy`; parameter tiap leaf ada pada source lengkap |
| Layout | Dwindle preserve_split; master new_status=master; scrolling fullscreen_on_one_column |
| Misc | Default mascot/logo dimatikan; XWayland force_zero_scaling |
| Input | US; follow_mouse 1; sensitivity 0; natural scroll; tap map lmr; swipe 3 jari horizontal jarak 150 |
| Window rules | Suppress maximize request; WezTerm noanim; XWayland drag no_focus; hyprland-run floating; file picker 960×680; auto-maximize dengan pengecualian; Dolphin floating; Waydroid fullscreen |
| No-blur rules | Steam, ONLYOFFICE, Brave, Chromium, VS Code, itch, RustDesk, AB Download Manager, Telegram dibuat opaque/no_blur |
| RustDesk | Submap otomatis saat window remote aktif, shortcut diteruskan ke remote |
| Script | Peek desktop, compact workspace 1–10, smart focus tiling↔floating, swap seluruh isi workspace |

Monitor source menggunakan `scale=auto`; `Xft.dpi=144` mengasumsikan kebutuhan skala 1.5
dari setup lama. Uji monitor target sebelum mempertahankan DPI tersebut. Komentar
workaround adalah catatan historis repo, bukan bukti bug masih ada di versi target.

### Shortcut Hyprland/Noctalia

| Shortcut | Aksi |
|---|---|
| Ctrl+Alt+T | Terminal |
| Alt+F4 / Super+Q | Tutup window |
| Super+M / Super+Shift+M | Peek desktop |
| Super+E | Dolphin |
| F11 / Super+F | Fullscreen toggle |
| Super+R | hyprlauncher |
| Super+P / Super+J | Pseudo / toggle split |
| Super+Shift+Space | Toggle floating; saat floating resize 900×600 dan center |
| Super+panah | Smart focus |
| Super+Shift+panah | Resize ±40 px |
| Super+Alt+panah | Swap posisi window |
| Ctrl+Super+kiri/kanan | Workspace sebelumnya/berikutnya |
| Super+angka / Ctrl+Super+angka | Workspace 1–10 (0=10) |
| Super+Shift+angka | Pindahkan window ke workspace |
| Super+Ctrl+Shift+angka | Tukar seluruh isi workspace |
| Super+S / Super+Shift+S | Toggle scratchpad magic / pindahkan window ke scratchpad |
| Super+Shift+G | Rapikan workspace |
| Super+scroll | Workspace existing sebelumnya/berikutnya |
| Super+drag kiri/kanan | Move/resize window |
| Ctrl+Super+= / - / G | Tambah/kurangi/reset gaps |
| Alt+Space / Super+Space | Launcher Noctalia |
| Super+N / Super+, | Control center / settings Noctalia |
| Super+L | Lock |
| Alt+Tab | Window switcher MRU |
| Ctrl+Alt+Delete | Session menu |
| Print / Super+Print / Super+Shift+Print | Screenshot penuh / region / annotate |
| Super+V | Clipboard |
| Super+W / Super+Shift+W / Super+Alt+W | Wallpaper next / previous / random |
| Super+Ctrl+W | Notifikasi path wallpaper aktif |
| Tombol volume/mic | wpctl, langkah volume 5%, limit 100% |
| Tombol brightness | brightnessctl, langkah 5% |
| Tombol media | playerctl |

### Nilai Noctalia

| Bagian | Pengaturan |
|---|---|
| Startup | Melalui event `hyprland.start`; tidak dijalankan sebagai service global lintas desktop |
| Font / switcher | Maple Mono NF; MRU |
| Screenshot | `~/Pictures/Screenshots`, show_cursor true |
| Theme | mode/shell_mode auto; source wallpaper; builtin Catppuccin; community Oxocarbon; scheme m3-content |
| Builtin templates | hyprland, wezterm, gtk3, gtk4, qt, kcolorscheme, btop |
| Community templates | brave, bat, fastfetch, fzf, lazygit, telegram, zellij, claude-code, steam, prismlauncher |
| Template custom | qylock-colors → `~/.config/qylock/colors.json` |
| Wallpaper | Folder Wallpapers; transition wipe; transition_on_startup; auto setiap 3600 detik |
| Lockscreen | Aktif; blurred_desktop false; blur 0.6; tint 0.35 |
| Nightlight/location | Nightlight mati; auto_locate aktif |
| Bar | Top; thickness 32; radius 16; margin edge 4/ends 0/opposite 0; background 0; capsule opacity 0.55 |
| Grup bar | Nav: launcher/taskbar; media: media/notifications; sys: network/bluetooth/volume/battery/tray/control-center dengan opacity 0.85 |
| Clock | `{:%H:%M} · {:%a, %d %b}`, tooltip `{:%A, %d %B %Y}` |
| Taskbar | Grup ikon per workspace; satu ikon per app; workspace kosong tersembunyi; semua workspace terisi terlihat; label corner; capsule per grup; icon_scale 0.9; active/inactive opacity 1/0.75 |
| Taskbar output/color | show_all_outputs false; focused_output_only false; active/focused primary; occupied on_surface; empty outline; urgent error |
| Widgets | Enabled; definisi dan posisi aktual ada di runtime settings.toml |
| Notification/OSD | opacity 0.8; scale 0.85; OSD bottom_center; filter screenshot duration 2500 ms |
| Layer rules | Blur dan blur_popups, ignore_alpha 0.5, no_anim untuk surface shell tertentu |
| Settings window | Floating 1080×920 |
| Theme Hyprland | `require("noctalia").apply_theme()` |
| Power | Dim ke 20% | Lock + DPMS off |
|---|---|---|
| AC | 300 detik | 870 detik |
| Battery | 150 detik | 570 detik |

`idle-power.sh` mengecek mode power, menyimpan/memulihkan brightness, dan menggabungkan
DPMS-off lalu lock. `on-colors-changed.sh` menerapkan color scheme KDE `noctalia` dan
menulis wallpaper aktif untuk SDDM. `sticker-random.sh` mengacak sticker dari folder gambar.

Restore runtime `settings.toml` untuk layout widget. File tersebut mengoverride config
manual; jika hasil berbeda dari tabel, periksa override. Sesudah restore jalankan
`noctalia config validate` untuk menemukan perubahan schema versi target.
[Model konfigurasi Noctalia](https://docs.noctalia.dev/noctalia/configuration/).

## 7. Shell dan konfigurasi aplikasi

### Fish

Buat `~/.config/fish/conf.d/thinkpad.fish`:

```fish
if status is-interactive
    function fish_greeting
    end

    alias ls 'eza --icons'
    alias ll 'eza -l --icons --git --group-directories-first'
    alias la 'eza -la --icons --git --group-directories-first'
    alias tree 'eza --tree --icons'

    starship init fish | source
    zoxide init fish | source
    direnv hook fish | source
    fzf --fish | source
end
```

Jika paket Fish/FZF target sudah memuat integrasi yang sama secara otomatis, hilangkan
inisialisasi duplikat. `nix-direnv` hanya dibutuhkan bila tetap memakai dev shell Nix.

### Git dan Delta

Isi deklarasi setara untuk `~/.gitconfig` (gabungkan dengan config lokal yang ingin dibawa):

```gitconfig
[user]
    name = Rizqiansyah
    email = rizzthenotable@gmail.com
[init]
    defaultBranch = main
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
```

### Pemetaan dotfile

| Source | Tujuan |
|---|---|
| `home/rizz404/starship/starship.toml` | `~/.config/starship.toml` |
| `home/rizz404/wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` |
| `home/rizz404/micro/settings.json` | `~/.config/micro/settings.json` |
| `home/rizz404/micro/bindings.json` | `~/.config/micro/bindings.json` |
| `home/rizz404/micro/colorschemes/*.micro` | `~/.config/micro/colorschemes/` |
| Micro plugins hasil export/fetch | `~/.config/micro/plug/<plugin>/` |
| `home/rizz404/mpv/mpv.conf` | `~/.config/mpv/mpv.conf` |
| `home/rizz404/mpv/input.conf` | `~/.config/mpv/input.conf` |
| `home/rizz404/mpv/scripts/autoload.lua` | `~/.config/mpv/scripts/autoload.lua` |

**Starship:** prompt dua baris, ikon OS, directory dan status Git; command timeout 5000 ms;
directory truncation 3, package module mati; simbol bahasa hanyalah tampilan prompt.

**WezTerm:** FiraCode Nerd Font 10 pt, ukuran awal 116×32, blinking bar cursor,
animation_fps 1, scrollbar, single tab bar tersembunyi, opacity 0.85,
`color_scheme='Noctalia'`. Bawa/generate palette `colors/Noctalia.toml` sebelum membuka
terminal. Ctrl+Shift+A select-all, Ctrl+Shift+backslash split kanan,
Ctrl+Shift+- split bawah, Ctrl+Shift+Q tutup pane dengan konfirmasi.

**Micro:** seluruh boolean/setting berada pada JSON lampiran: autoclose, autoindent,
clipboard external, cursorline, diffgutter, hlsearch, keepautoindent, mkparents, mouse,
rmtrailingws, ruler, savecursor, saveundo, scrollbar, softwrap, statusline, tabmovement,
tabsize 4, tabstospaces, wordwrap. Settings source tidak memilih colorscheme tertentu;
bawa pilihan tema runtime bila ingin persis.

Plugin Micro yang dipin:

| Plugin | Repository |
|---|---|
| bookmark | `haqk/micro-bookmark` |
| editorconfig | `10sr/editorconfig-micro` |
| filemanager | `micro-editor/updated-plugins`, subdir `filemanager-plugin` |
| fzf | `micro-editor/updated-plugins`, subdir `fzf` |
| jump | `terokarvinen/micro-jump` |
| lsp | `AndCake/micro-plugin-lsp` |
| manipulator | `NicolaiSoeborg/manipulator-plugin` |
| quoter | `deusnefum/micro-quoter` |
| snippets | `micro-editor/updated-plugins`, subdir `micro-snippets-plugin` |
| wc | `adamnpeace/micro-wc-plugin` |

Revision/hash lengkap ada di `home/rizz404/micro/default.nix` dalam lampiran. Gunakan
export plugin terpasang agar sama dengan setup lama; khusus filemanager/FZF/snippets,
jangan mengganti fork yang sudah diperbarui dengan versi lama tanpa uji kompatibilitas.
Tema berasal dari `catppuccin/micro` dan empat file transparan lokal.

**MPV:** source menyimpan playback position, profile kondisional saat EOF mematikan
save-position. Source juga mendeklarasikan `gpu-hq`, full output range dan auto-safe hwdec.
Letaknya sesudah `[eof-reached]`, sehingga scope profile perlu diuji bila ingin quality
options berlaku global. Uji dukungan opsi target. Autoload mengisi playlist dari direktori;
Enter fullscreen, PgDown/PgUp playlist next/previous, Up/Down volume ±5.
Paket MPRIS ada pada daftar tetapi tidak ada deklarasi load script MPRIS eksplisit di file ini.

### Udiskie

Buat `~/.config/udiskie/config.yml`:

```yaml
program_options:
  automount: true
  notify: true
  tray: auto
```

Buat `~/.config/systemd/user/udiskie.service`:

```ini
[Unit]
Description=Udiskie automount and tray
After=graphical-session.target
PartOf=graphical-session.target

[Service]
ExecStart=/usr/bin/udiskie
Restart=on-failure

[Install]
WantedBy=graphical-session.target
```

Aktifkan user service dan pastikan desktop mengaktifkan graphical-session.target.
Jika Hyprland target tidak mengaktifkan target tersebut, jalankan `udiskie` melalui
autostart Hyprland; gunakan satu jalur startup supaya tidak dobel.

### GPG

Set `pinentry-program /usr/bin/pinentry-curses` di `~/.gnupg/gpg-agent.conf`.
Paket Arch bisa memakai `pinentry` untuk menyediakan executable ini, sehingga cek
`pacman -Si pinentry` dan `command -v pinentry-curses`. Hindari menyalin path Nix.
Untuk terminal, pastikan agent menerima GPG_TTY yang sesuai sesi saat dibutuhkan.

## 8. Plasma dan tema

Source Plasma Manager tidak dapat disalin sebagai `.nix` lalu dibaca Plasma secara
langsung. Dua jalur: restore hasil export native `.config/*rc` dari bagian 3 untuk
hasil paling dekat, atau gunakan nilai sumber/lampiran untuk menerapkan ulang setting.
Restore config panel saat Plasma berhenti, lalu login kembali agar tidak ditimpa state sesi.

| File | Konfigurasi sumber |
|---|---|
| `kdeglobals` | Papirus-Dark; contrast 4; frameContrast 0.2; dialog file DetailTree, breadcrumb, dirs first, inline previews, hidden files mati, speedbar width 140, preview panel mati |
| `kwinrc` | Desktop Number=1, Rows=1, Xwayland Scale=1 |
| `kwinrulesrc` | RustDesk Remote Shortcuts: disableglobalshortcuts=true/rule 2 untuk title remote spesifik source |
| `kglobalshortcutsrc` | Seluruh shortcut dari `kde/shortcuts.nix`; export native untuk mempertahankan serialisasi KDE |
| `dolphinrc` | GlobalViewProps false; places icon 16; admin risk warning false; plugin thumbnail lengkap pada source |
| `katerc` | Save metadata true/30 days; menu/status/tab/url bar aktif; file tree listMode false, shading true, toolbar true dan setting lain source |
| `spectaclerc` | Auto-save image; PostScreenshotCopyImage; Screenshots/Screencasts |
| `kded5rc` | browserintegrationreminder dan device_automounter autoload false |
| `kwalletrc` | Wallet First Use=false |
| `krunnerrc` | General FreeFloating=true |
| `plasma-localerc` | Formats LANG=en_US.UTF-8 |
| `plasmashellrc` | Panel floating; panel 190 thickness 40, length 1536; panel 2 thickness 44 |
| `plasma-org.kde.plasma.desktop-appletsrc` | Panel launcher/spacers/icon task manager/tray/clock; desktop widgets disk/CPU/RAM/network; slideshow 7201 detik; asset dan disk sensor ID mengikuti source |

Shortcut Plasma mencakup layout keyboard, CopyQ, aksesibilitas, volume/mic, lock/logout,
overview/grid/expose, fokus/move/tile window, desktop/activity, media, power/brightness,
clipboard, screenshot, system monitor, dan WezTerm. Daftar semua kombinasi ada pada
lampiran `kde/shortcuts.nix`. Shortcut CopyQ **tidak berarti CopyQ dipasang oleh repo**.

### Aset tema

Tema utama: **Moe-Dark**; ikon: **Papirus-Dark**; cursor: **WhiteSur-cursors**.
Catppuccin KDE juga terpasang sebagai tema tambahan: mocha, macchiato, frappe, latte;
aksen blue, rosewater, pink, mauve, red, peach, green, teal, sapphire, lavender; dekorasi modern.

| Source aset | Tujuan |
|---|---|
| `jomada/moe-dark` → `look-and-feel/Moe-Dark` | `~/.local/share/plasma/look-and-feel/Moe-Dark` |
| `color-schemes/MoeDark.colors` | `~/.local/share/color-schemes/MoeDark.colors` |
| `Moe-Dark` | `~/.local/share/plasma/desktoptheme/Moe-Dark` |
| `aurorae/MoeDark` | `~/.local/share/aurorae/themes/MoeDark` |
| `Wallpapers/MoeDark-DarkSouls` | `~/.local/share/wallpapers/MoeDark-DarkSouls` |
| `vinceliuice/WhiteSur-cursors` → `dist` | `~/.icons/WhiteSur-cursors` |

Moe-Dark revision `1e9dcd6d89a58f1de61e13cc361f563e01dd1c26`;
WhiteSur revision `e190baf618ed95ee217d2fd45589bd309b37672b`.
Source/hash ada pada lampiran. Sesudah aset tersedia, terapkan global theme `Moe-Dark`
melalui System Settings atau `plasma-apply-lookandfeel -a Moe-Dark`, lalu pilihan ikon
Papirus-Dark. Jangan memaksa ulang bundle tema setiap login Hyprland: Noctalia mengatur
warna KDE berdasarkan wallpaper di sesi tersebut.

## 9. Database, container, dan gaming

### PostgreSQL 17

Sumber mengaktifkan PostgreSQL 17, membuat role/database **`rizz404`**, role menjadi pemilik.
Tidak ada deklarasi password atau custom authentication pada modul repo.

1. Backup logical dump memakai client yang sesuai versi server lama.
2. Instal/siapkan **mayor 17** jika mempertahankan versi; kandidat `postgresql17` AUR
   terverifikasi. Periksa path binary, data directory dan nama unit pada paket tersebut.
3. Inisialisasi hanya bila data directory baru masih kosong, dengan locale en_US.UTF-8.
4. Buat role login `rizz404` dan database `rizz404` dengan owner tersebut, atau restore
   role/database dari dump; jangan membuat ulang objek yang sudah direstore.
5. Verifikasi login lokal user `rizz404` dan ownership database.

Contoh SQL untuk database baru:

```sql
CREATE ROLE rizz404 LOGIN;
CREATE DATABASE rizz404 OWNER rizz404;
```

Jika sengaja memilih PostgreSQL 18, lakukan upgrade/restore yang didukung, bukan menyalin
data directory 17 lalu menjalankannya dengan 18. [Dokumentasi upgrade PostgreSQL](https://www.postgresql.org/docs/current/upgrading.html).

### MySQL 8.4

Sumber mengaktifkan MySQL 8.4, bind TCP **127.0.0.1**, database **`rizz404`**, user lokal
**`rizz404`** melalui Unix socket, privilege **ALL pada `rizz404.*`**.

Gunakan paket `mysql84` AUR atau environment MySQL 8.4 yang tetap mempertahankan versi.
Periksa layout file config dan unit service milik paket tersebut sebelum inisialisasi.
Pada config MySQL target, tambahkan:

```ini
[mysqld]
bind-address=127.0.0.1
```

Untuk instalasi baru, konfigurasi plugin `auth_socket` agar login OS user `rizz404`
sesuai sumber. Plugin harus tersedia/aktif terlebih dahulu; jangan menjalankan CREATE
USER dengan plugin yang belum tersedia. Bentuk SQL setelah plugin siap:

```sql
CREATE DATABASE IF NOT EXISTS rizz404;
CREATE USER IF NOT EXISTS 'rizz404'@'localhost' IDENTIFIED WITH auth_socket;
GRANT ALL PRIVILEGES ON rizz404.* TO 'rizz404'@'localhost';
```

Restore dump serta account/plugin grants yang diperlukan sebelum menguji aplikasi.
[MySQL socket authentication](https://dev.mysql.com/doc/refman/8.4/en/socket-pluggable-authentication.html).

### Podman dan Waydroid

- Podman aktif, dengan podman-compose dan podman-tui; tidak ada Docker daemon pada deklarasi.
- Source policy default `insecureAcceptAnything`. Untuk kesetaraan, gabungkan default
  tersebut dengan policy target pada `/etc/containers/policy.json` atau policy user;
  jangan menghapus transport rules bawaan yang masih dibutuhkan.
- Bentuk default policy sumber: `{"default":[{"type":"insecureAcceptAnything"}]}`.
- Podman rootless tidak memerlukan daemon selalu aktif; periksa mapping subuid/subgid.
- Waydroid source memakai paket nftables dan interface `waydroid0` dipercaya firewall.
- Pada CachyOS, verifikasi kernel/binder dan backend firewall paket Waydroid, lalu
  inisialisasi/start container sesuai paket target. Jangan menyalin asumsi iptables-legacy
  dari package lain tanpa memeriksa kernel.
- Terapkan kepercayaan `waydroid0` menggunakan firewall target yang dipilih; jangan
  menganggap NixOS firewall.trustedInterfaces berubah otomatis menjadi aturan target.

### Gaming

- Steam, steam-devices/controller rules, Proton GE.
- itch, Lutris, Wine, Winetricks, Prism Launcher.
- Mesa/Vulkan AMD dan library 32-bit, dukungan ALSA 32-bit.
- Steam Remote Play firewall dibuka; dedicated-server firewall tetap tidak dibuka.
  Cocokkan aturan/port dengan Steam target dan firewall yang digunakan.
- Proton GE dipasang sebagai compatibility tool Steam dan dipilih per game bila perlu.
- AppImage dapat dijalankan; registrasi binfmt lama adalah perilaku Nix tersendiri.
- `steam-run` adalah wrapper Nix dan tidak perlu direplikasi sebagai paket native Arch.
- Restore game saves, instance Prism, prefix Wine/Lutris dan library Steam secara terpisah.

## 10. Bagian Nix dan pengecekan hasil

### Opsi Nix yang dicatat sebagai arsip

| Pengaturan sumber | Nasib pada CachyOS |
|---|---|
| Flakes + nix-command | Hanya bila Nix tetap dipasang |
| Registry nixpkgs mengikuti flake | Hanya untuk Nix |
| keep-outputs/keep-derivations | Hanya untuk Nix |
| Cache Lantian, lokal `~/nix-cache`, Noctalia Cachix, Numtide + trusted keys | Hanya untuk Nix; nilai lengkap dalam source |
| Build ThinkPad max-jobs=2, cores=10 | Opsi Nix; berbeda dari MAKEFLAGS/package build Arch |
| GC mingguan, persistent, delay acak 30 menit; simpan 5 generasi | Hanya untuk Nix; bukan kebijakan snapshot Btrfs/pacman |
| nix-ld dan library steam-run | Compatibility Nix; native binary CachyOS mengikuti library target |
| allowUnfree=true | Kebijakan nixpkgs |
| stateVersion 26.05 | Metadata kompatibilitas NixOS/Home Manager |
| Home Manager global/user pkgs, suffix .backup; plasma-manager | Mekanisme deklaratif Nix; hasil dotfile dibawa sebagai file biasa |
| Input nix-cachyos-kernel | Ada, tetapi **modules/system/kernel.nix tidak diimpor** pada source; jangan menganggap kernel Nix aktif adalah CachyOS LTS |

Inputs sumber: nixpkgs nixos-26.05, Home Manager release-26.05, Plasma Manager, Noctalia,
llm-agents, nix-cachyos-kernel, qylock lokal. `flake.lock` tetap dibawa melalui backup repo
agar revision upstream bisa ditelusuri. Hanya profil ThinkPad yang digunakan panduan ini.

### Checklist verifikasi

- [ ] Boot sampai SDDM dengan Limine/Plymouth dan driver amdgpu.
- [ ] Login Plasma dan Hyprland tersedia; hanya satu Noctalia aktif pada sesi Hyprland.
- [ ] Locale, timezone, Fish default, sudo, NetworkManager, Bluetooth, audio dan printing benar.
- [ ] TLP threshold 50/90 terbaca, Wi-Fi power saving mati, profil daya GUI berfungsi.
- [ ] Power button suspend; idle suspend logind 15 menit.
- [ ] Charge-kick bekerja setelah reboot/suspend bila kondisi stuck terjadi.
- [ ] Wallpaper, sticker, bar/taskbar, palette WezTerm/KDE dan SDDM tersinkron.
- [ ] Idle dim/lock/DPMS berbeda antara AC dan battery, kembali normal setelah aktivitas.
- [ ] KWallet unlock, portal Secret, Brave sync tetap tersimpan lintas sesi.
- [ ] Dolphin Open With, dialog file picker dan USB automount bekerja.
- [ ] Shortcut dan RustDesk remote shortcut forwarding sesuai source.
- [ ] Micro plugin/tema dan MPV autoload berfungsi.
- [ ] JDK 25, PostgreSQL 17, MySQL 8.4 benar; data dan privilege sudah direstore.
- [ ] Podman rootless, Waydroid binder/firewall, Steam/Proton/controller berfungsi.
- [ ] Dotfile hasil restore tidak menyisakan path executable `/nix/store` yang diperlukan.

Contoh pemeriksaan pada target:

```bash
hostnamectl
timedatectl
locale
hyprctl version
hyprctl configerrors
noctalia config validate
tlp-stat -s
tlp-stat -b
wpctl status
java -version
systemctl --failed
systemctl --user --failed
rg -n '/nix/store|@KWALLET_PAM_INIT@' ~/.config/hypr ~/.config/fish ~/.config/noctalia ~/.gitconfig
```

Panduan native belum diuji pada instalasi CachyOS target; checklist dan status verifikasi
paket dibedakan dari keberhasilan boot/login/service sesudah migrasi.

## 11. Lampiran konfigurasi native Noctalia

Berikut **hasil konfigurasi deklaratif yang aktif pada ThinkPad**,
dibaca dari `~/.config/noctalia/config.toml` saat dokumen dibuat. Ini konfigurasi native
yang bisa disimpan pada path yang sama di CachyOS; tidak termasuk runtime override/widget
layout dari `settings.toml`. Isi telah diperiksa terhadap setting deklaratif repo.
Path home tetap `/home/rizz404`; sesuaikan bila user/path berubah.

```toml
[bar.default]
background_opacity = 0.0
capsule = true
capsule_opacity = 0.55
center = ["clock"]
enabled = true
end = ["group:media", "group:sys"]
margin_edge = 4
margin_ends = 0
margin_opposite_edge = 0
position = "top"
radius = 16
start = ["group:nav"]
thickness = 32

[[bar.default.capsule_group]]
fill = "surface_variant"
id = "nav"
members = ["launcher", "taskbar"]
opacity = 0.55

[[bar.default.capsule_group]]
fill = "surface_variant"
id = "media"
members = ["media", "notifications"]
opacity = 0.55

[[bar.default.capsule_group]]
fill = "primary"
foreground = "on_primary"
id = "sys"
members = ["network", "bluetooth", "volume", "battery", "tray", "control-center"]
opacity = 0.85

[desktop_widgets]
enabled = true

[hooks]
colors_changed = "/home/rizz404/.config/noctalia/on-colors-changed.sh"
wallpaper_changed = "/home/rizz404/.config/noctalia/sticker-random.sh"

[idle]
pre_action_fade_seconds = 0

[idle.behavior.dim-ac]
action = "command"
command = "/home/rizz404/.config/noctalia/idle-power.sh ac dim start"
enabled = true
resume_command = "/home/rizz404/.config/noctalia/idle-power.sh ac dim resume"
timeout = 300

[idle.behavior.dim-battery]
action = "command"
command = "/home/rizz404/.config/noctalia/idle-power.sh battery dim start"
enabled = true
resume_command = "/home/rizz404/.config/noctalia/idle-power.sh battery dim resume"
timeout = 150

[idle.behavior.lock-ac]
action = "command"
command = "/home/rizz404/.config/noctalia/idle-power.sh ac lock start"
enabled = true
resume_command = "/home/rizz404/.config/noctalia/idle-power.sh ac lock resume"
timeout = 870

[idle.behavior.lock-battery]
action = "command"
command = "/home/rizz404/.config/noctalia/idle-power.sh battery lock start"
enabled = true
resume_command = "/home/rizz404/.config/noctalia/idle-power.sh battery lock resume"
timeout = 570

[location]
auto_locate = true

[lockscreen]
blur_intensity = 0.6
blurred_desktop = false
enabled = true
tint_intensity = 0.35

[nightlight]
enabled = false

[notification]
background_opacity = 0.8
scale = 0.85

[notification.filter.screenshot]
enabled = true
match_content = "[Ss]creenshot"
override_duration = 2500

[osd]
background_opacity = 0.8
position = "bottom_center"
scale = 0.85

[shell]
font_family = "Maple Mono NF"

[shell.screenshot]
directory = "~/Pictures/Screenshots"
show_cursor = true

[shell.window_switcher]
mru = true

[theme]
builtin = "Catppuccin"
community_palette = "Oxocarbon"
mode = "auto"
shell_mode = "auto"
source = "wallpaper"
wallpaper_scheme = "m3-content"

[theme.templates]
builtin_ids = [
    "hyprland",
    "wezterm",
    "gtk3",
    "gtk4",
    "qt",
    "kcolorscheme",
    "btop",
]
community_ids = [
    "brave",
    "bat",
    "fastfetch",
    "fzf",
    "lazygit",
    "telegram",
    "zellij",
    "claude-code",
    "steam",
    "prismlauncher",
]
enable_builtin_templates = true
enable_community_templates = true

[theme.templates.user.qylock-colors]
input_path = "/home/rizz404/.config/noctalia/templates/qylock-colors.json.tmpl"
output_path = "/home/rizz404/.config/qylock/colors.json"

[wallpaper]
directory = "~/Pictures/Wallpapers"
transition = ["wipe"]
transition_on_startup = true

[wallpaper.automation]
enabled = true
interval_seconds = 3600

[widget.clock]
format = "{:%H:%M} · {:%a, %d %b}"
tooltip_format = "{:%A, %d %B %Y}"

[widget.taskbar]
active_indicator_color = "primary"
active_opacity = 1.0
empty_color = "outline"
focused_color = "primary"
focused_output_only = false
group_by_workspace = true
group_single_icon_per_app = true
hide_empty_workspaces = true
icon_scale = 0.9
inactive_opacity = 0.75
occupied_color = "on_surface"
only_active_workspace = false
show_active_indicator = true
show_all_outputs = false
show_workspace_label = true
urgent_color = "error"
workspace_group_capsule = true
workspace_group_content = "icons"
workspace_label_placement = "corner"
```

## 12. Lampiran source konfigurasi lengkap

Setiap blok di bawah merupakan snapshot isi file asli, bukan pseudocode. File `.nix`
adalah referensi deklarasi; gunakan bagian native/export untuk konfigurasi target.
Seluruh file `home/rizz404`, modul sistem/desktop aktif, package AB, dan dua file host
ThinkPad disertakan. Modul kernel tidak aktif hanya dicatat pada bagian 10. Isi flake
global dan profil host lain tidak dimasukkan ke lampiran fokus ThinkPad.

File lampiran diberi path asal dan SHA-256 agar snapshot dapat dicocokkan dengan source.
Binary font/aset/gambar tidak dapat disertakan sebagai konfigurasi teks Markdown.

### `hosts/lenovo-thinkpad-t14-personal/configuration.nix`

SHA-256: `2508a4529877f12eeb7b119f1bdcf5e3b5637a2d1c800aaf7324a65f5cbb8177`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ config, lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # biar nixos-rebuild gak cuma pakai 2 dari 12 thread yang ada, override swap.nix
  nix.settings = {
    max-jobs = lib.mkForce 2;
    cores = lib.mkForce 10;
  };

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.loader.limine.enable = true;
  # * timeout: 0 cuma auto-pilih entry instan, UI Limine tetap sempat kerender
  #   sekilas - quiet: yes nekan semua output layar Limine biar transisi ke
  #   Plymouth bener-bener mulus tanpa flash.
  boot.loader.limine.extraConfig = "quiet: yes\n";

  # * Load amdgpu di initrd (early KMS) biar Plymouth langsung pakai driver asli
  #   sejak awal, bukan simpledrm generik yang baru diganti amdgpu ~5 detik
  #   setelah switch-root - pergantian itu yang bikin layar blank sekilas.
  boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "lenovo-thinkpad-t14-personal";
  networking.networkmanager.enable = true;

  # * Power button buat sleep saat aktif bukan langsung poweroff
  services.logind.settings.Login.HandlePowerKey = "suspend";

  # * Jaring pengaman di level systemd-logind (jalan bahkan sebelum login,
  #   termasuk pas nongkrong di greeter SDDM) - idle rule Noctalia
  #   (dim/lock/screen-off) cuma jalan di DALAM sesi Hyprland yang udah
  #   login, jadi kalau lupa gak jadi login abis nyalain laptop, layar bakal
  #   nyala terus tanpa batas. Auto-suspend abis 15 menit idle nutup celah itu.
  services.logind.settings.Login = {
    IdleAction = "suspend";
    IdleActionSec = "15min";
  };

  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  services.printing.enable = true;

  users.users.rizz404 = {
    isNormalUser = true;
    description = "Rizqiansyah";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [ kdePackages.kate ];
    # * 711 (bukan default 700) - biar user "sddm" (greeter, uid terpisah dari rizz404)
    #   bisa traverse ke ~/Pictures/Wallpapers & ~/.config/qylock buat baca wallpaper +
    #   warna live. Isi folder tetap gak ke-list ke user lain, cuma traverse ke path
    #   yang udah tau namanya.
    homeMode = "711";
  };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  # * Pakai qylock cuma buat infra install theme SDDM - theme-nya sendiri
  #   (noctalia-sync) ditulis dari nol, niru visual lockscreen native Noctalia
  #   (blur+tint di atas wallpaper aktif) biar login screen & lockscreen
  #   konsisten. Lockscreen-nya sendiri gak pakai qylock sama sekali, pakai
  #   native Noctalia (programs.noctalia.settings.lockscreen di
  #   home/rizz404/noctalia/default.nix).
  programs.qylock = {
    enable = true;
    theme = "noctalia-sync";
    quickshell.enable = false;
  };

  # * Qt6 default-nya blokir XMLHttpRequest baca file lokal - dibutuhin theme
  #   noctalia-sync buat baca ~/.config/qylock/{colors.json,wallpaper.txt}.
  services.displayManager.sddm.settings.General.GreeterEnvironment = "QML_XHR_ALLOW_FILE_READ=1";

  system.stateVersion = "26.05";
}
```

</details>

### `hosts/lenovo-thinkpad-t14-personal/hardware-configuration.nix`

SHA-256: `21f9ec8e9960245cfa5906ca4b9b457117ef5c123d7b3bdd33cc23c24d8a0501`

<details>
<summary>Lihat isi lengkap</summary>

```nix
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci_renesas" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/df4439ea-0398-4436-bd81-5ea832a4415c";
      fsType = "btrfs";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/df4439ea-0398-4436-bd81-5ea832a4415c";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/df4439ea-0398-4436-bd81-5ea832a4415c";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/88AB-7344";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

</details>

### `modules/system/battery.nix`

SHA-256: `e5b3b6a1448dc64331a808c086c61adc6ea011a9e6598ca06c8786f310f7ca40`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, lib, ... }:
let
  # TLP hanya menulis ulang charge threshold ke sysfs kalau nilainya beda dari
  # yang sedang aktif (lihat batdrv_write_thresholds di tlp/bat.d/05-thinkpad).
  # Setelah suspend/resume atau reboot, EC ThinkPad kadang "lupa" sedang di
  # tengah siklus charging walau capacity masih di bawah stop threshold, jadi
  # baterai nyangkut di status "Not charging" walau angka threshold di sysfs
  # sudah benar (50/90) — makanya restart TLP normal tidak menolong.
  # `tlp chargeonce` menulis nilai start threshold sementara yang beda dari
  # yang aktif, sehingga TLP benar-benar menulis ke sysfs dan nge-"kick" EC
  # supaya mulai charging lagi; setelah itu `tlp start` mengembalikan
  # threshold sesuai konfigurasi (50/90).
  chargeKickScript = pkgs.writeShellScript "tlp-charge-kick" ''
    set -euo pipefail
    export PATH=${lib.makeBinPath [ pkgs.tlp pkgs.coreutils pkgs.util-linux ]}:$PATH

    # kasih waktu subsistem power_supply update status setelah resume/boot
    sleep 3

    for bat_dir in /sys/class/power_supply/BAT*; do
      [ -d "$bat_dir" ] || continue
      status_file="$bat_dir/status"
      cap_file="$bat_dir/capacity"
      stop_file="$bat_dir/charge_control_end_threshold"
      [ -r "$status_file" ] && [ -r "$cap_file" ] || continue

      status=$(cat "$status_file")
      capacity=$(cat "$cap_file")
      stop_thresh=$(cat "$stop_file" 2>/dev/null || echo 100)

      if [ "$status" = "Not charging" ] && [ "$capacity" -lt "$((stop_thresh - 1))" ]; then
        logger -t tlp-charge-kick "$(basename "$bat_dir") nyangkut di $capacity% (status=Not charging, stop=$stop_thresh%), kick charging"
        tlp chargeonce || true
        sleep 2
        tlp start || true
      fi
    done
  '';
in
{
  services.tlp = {
    enable = true;
    pd.enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 50;
      STOP_CHARGE_THRESH_BAT0 = 90;

      # * Default TLP nyalain WiFi power-save di baterai - radio jadi sleep/wake
      #   berkala buat hemat daya, tapi ini bikin sering CTRL-EVENT-BEACON-LOSS
      #   (kelewat beacon dari AP/hotspot pas radio lagi sleep) yang manifest
      #   sebagai koneksi macet sesaat, termasuk sesi SSH yang jadi freeze total.
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";
    };
  };

  services.power-profiles-daemon.enable = false;

  systemd.services.tlp-charge-kick-boot = {
    description = "Kick TLP charging kalau nyangkut Not charging setelah boot/reboot";
    after = [ "tlp.service" ];
    wants = [ "tlp.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${chargeKickScript}";
    };
  };

  systemd.services.tlp-charge-kick-resume = {
    description = "Kick TLP charging kalau nyangkut Not charging setelah resume dari sleep";
    before = [ "sleep.target" ];
    after = [ "tlp-sleep.service" ];
    unitConfig.StopWhenUnneeded = "yes";
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = "${chargeKickScript}";
    };
  };
}
```

</details>

### `modules/system/containers.nix`

SHA-256: `d148071b4219f05d97467390aa08c4f772c7d80c0d283b61bed6a19ecc993ad2`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  virtualisation.podman.enable = true;
  virtualisation.containers.policy.default = [{ type = "insecureAcceptAnything"; }];
  virtualisation.waydroid.enable = true;

  # Kernel >=6.17 nixpkgs default gak nyertain modul ip_tables lagi,
  # tapi package waydroid biasa masih hardcode ke iptables-legacy yang butuh itu.
  # waydroid-nftables pakai nft langsung, gak butuh ip_tables sama sekali.
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
}
```

</details>

### `modules/system/core.nix`

SHA-256: `d29ca44bbd5537a02886f6699f620bab55eb4b28b5ed54f4d77d3395365647ff`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, inputs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.extra-substituters = [
    "https://attic.xuyh0120.win/lantian"
    "file:///home/rizz404/nix-cache"
    "https://noctalia.cachix.org"
    "https://cache.numtide.com"
    ];
  nix.settings.trusted-public-keys = [
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.settings.keep-outputs = true;
  nix.settings.keep-derivations = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    htop
    tree
    vim
    efibootmgr
  ];
}
```

</details>

### `modules/system/databases.nix`

SHA-256: `89f29f823a07c89d8e50bac9a12e78ed585b29223fda50fd5ad152001bc32101`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pgcli
    mycli
  ];

  # Pin versi mayor; patch mengikuti nixpkgs di flake.lock.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    ensureDatabases = [ "rizz404" ];
    ensureUsers = [
      {
        name = "rizz404";
        ensureDBOwnership = true;
      }
    ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mysql84; # MySQL 8.4 LTS
    settings.mysqld.bind-address = "127.0.0.1";
    ensureDatabases = [ "rizz404" ];
    # Login lokal sebagai user sistem rizz404 melalui Unix socket.
    ensureUsers = [
      {
        name = "rizz404";
        ensurePermissions = {
          "rizz404.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
```

</details>

### `modules/system/devtools.nix`

SHA-256: `bd9747e575c298ed39b1df4db68eddb268ad405f16491446aae562c63d15e1fe`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, inputs, ... }:
let
  # * claude-code, opencode, codex diambil dari llm-agents (update harian) karena
  #   nixpkgs stabil telat versinya, jadi model baru gak bisa diakses
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # biar command `locate` punya database yang ke-update otomatis (dipakai plocate)
  services.locate.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  environment.systemPackages = with pkgs; [
    # desktop
    bruno
    rustdesk-flutter
    vscode
    telegram-desktop
    mpvScripts.mpris

    # cli tools
    llmAgents.claude-code
    llmAgents.opencode
    llmAgents.codex
    gh
    lazygit
    micro
    btop
    chafa
    duf
    dust
    fastfetch
    plocate
    ripgrep
    fd
    bat
    jq
    tesseract
    xh
    p7zip
    unzip
    zip
    unrar
    rclone
    restic
    yt-dlp
    wl-clipboard
    aspell
    aspellDicts.en
    aspellDicts.id
    arch-install-scripts
    podman-compose
    podman-tui
    zellij
    iw
    pciutils
    usbutils
    aircrack-ng
    reaverwps
    bully
    wpa_supplicant
    wirelesstools
    imagemagick
    ffmpeg
    stress-ng
    linuxPackages.cpupower
    evtest
    libinput
    alsa-utils
    lm_sensors
    ethtool
    psmisc
    bind
    openssl
    samba
    pdfarranger
    qpdf
    file
    gallery-dl
    nvme-cli
    gnupg
    inetutils
    lftp
    filezilla

    # programming language
    php
    php.packages.composer
    # * withPackages pillow - dibutuhin script theming Brave-nya Noctalia buat proses gambar
    (python3.withPackages (ps: [ ps.pillow ]))
    jdk25
    nodejs
    go
    golangci-lint
    bun
    maven
    dart
    flutter

    # wordpress site management
    wp-cli
  ];
}
```

</details>

### `modules/system/gc.nix`

SHA-256: `f7a264447a2132481a003252ba21ffcd257547cfa7f776ce3fb12a266325f3a0`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  # keep 5 generations
  system.activationScripts.trimGenerations = {
    text = ''
      ${pkgs.nix}/bin/nix-env \
        -p /nix/var/nix/profiles/system \
        --delete-generations +5
    '';
    deps = [ ];
  };

  # GC hanya dijalankan oleh timer.
  systemd.services.nix-gc-async = {
    description = "Reclaim unused Nix store paths";

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      ${pkgs.nix}/bin/nix-collect-garbage
    '';
  };

  systemd.timers.nix-gc-async = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
}
```

</details>

### `modules/system/network.nix`

SHA-256: `7b2aef0a7efc41041257b82cbf24c74409fbc63be980fd3a8b58654ecc3d727f`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:
{
  hardware.bluetooth.enable = true;
  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.upower.enable = true;
  systemd.services.tailscaled.serviceConfig.TimeoutStopSec = "5s";
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
}
```

</details>

### `modules/system/nix-ld.nix`

SHA-256: `f583d55b63ffd981185ec4a1020627bad9bf3ebd472818555b5f8aeecb50dba3`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = pkgs.steam-run.args.multiPkgs pkgs;
}
```

</details>

### `modules/system/plymouth.nix`

SHA-256: `81ce050e7c34c689dfd6481826d080dc501227d98a8c1a2cee96fcb7b8cdd624`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  # * Ganti pesan boot/shutdown putih-hijau khas Linux dengan splash grafis
  #   Catppuccin Mocha - selaras sama theme.builtin Noctalia (home/rizz404/noctalia/default.nix)
  boot.plymouth = {
    enable = true;
    theme = "catppuccin-mocha";
    themePackages = [
      (pkgs.catppuccin-plymouth.override { variant = "mocha"; })
    ];
  };

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];
}
```

</details>

### `modules/system/shell.nix`

SHA-256: `bd6457b28de3ee562ca93e6b4c4f9e8282caa440b971d43b54d6daba34089cd2`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:
{
  programs.fish.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```

</details>

### `modules/system/swap.nix`

SHA-256: `2ded5810122d761234c58efae73a65f1a41ef5d6ff94ac0bd42880425aac543f`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:
{
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4096;
    }
  ];

  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };
}
```

</details>

### `modules/desktop/apps.nix`

SHA-256: `6425165a60251b01409423f9ab48d11a0d3f3ef0caa92ec9e606c801447fe2f5`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    chromium
    wezterm
    onlyoffice-desktopeditors
    qbittorrent
    scrcpy
    android-tools # nyediain `adb` yang dipakai scrcpy buat konek ke HP
    mpv
    pavucontrol
    varia
    (pkgs.callPackage ../../pkgs/ab-download-manager.nix { })

    # * Dibutuhin biar template GTK3/GTK4 & QT Noctalia (lihat
    # * home/rizz404/noctalia/default.nix) beneran keliatan efeknya di app
    adw-gtk3 # tema GTK3/GTK4 yang dipasangin Noctalia lewat gsettings
    nwg-look # GUI buat cek/atur tema GTK kalau apply.sh Noctalia gak cukup
    kdePackages.qt6ct # color scheme "noctalia (KColorScheme)" / "noctalia" QT butuh ini
  ];
}
```

</details>

### `modules/desktop/fonts.nix`

SHA-256: `ad35a1b89561409ace8daa7659a44da3b5502c10e44b139d7cec159b95c1e5da`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
    maple-mono.NF
    nerd-fonts.caskaydia-cove
    nerd-fonts.comic-shanns-mono
    corefonts
    open-sans
  ];
}
```

</details>

### `modules/desktop/gaming.nix`

SHA-256: `54e4aa3496936e89e2df55ec37ce3726265c89060c449d34affe1d231424cde5`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{pkgs, ...}:
{
  # Steam — declarative, otomatis urus 32-bit lib, udev rules controller, port firewall, dst.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;       # kalau mau streaming ke device lain di jaringan
    dedicatedServer.openFirewall = false; # cuma perlu kalau mau host game server sendiri
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  hardware.steam-hardware.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true; # bisa langsung `./game.AppImage` tanpa wrapper manual
  };

  environment.systemPackages = with pkgs; [
    itch               # client resmi itch.io
    steam-run          # FHS sandbox buat binary Linux sembarangan (non-AppImage, non-Steam)
    lutris             # kelola game Windows-only dari luar Steam (GOG installer, itch, dll)
    wineWowPackages.stable
    winetricks
    prismlauncher
  ];
}
```

</details>

### `modules/desktop/hyprland.nix`

SHA-256: `1ba51cb47dbe84a4d93ce2175e72e458be8f6e432c4c74d804365ec9f9d9a6bd`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, lib, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    configPackages = [ pkgs.hyprland ];
  };

  security.polkit.enable = true;
  services.udisks2.enable = true;

  # * Biar app tetap auth saat pindah ke hyprland dari plasma
  security.pam.services.login.kwallet = lib.mkDefault {
    enable = true;
    package = pkgs.kdePackages.kwallet-pam;
  };

  # * Open with dialog buat manual gak minjem plasma
  environment.etc."xdg/menus/hyprland-applications.menu".text = ''
    <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
      "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
    <Menu>
      <Name>Applications</Name>
      <DefaultAppDirs/>
      <DefaultDirectoryDirs/>
      <DefaultMergeDirs/>
    </Menu>
  '';

  environment.systemPackages = with pkgs; [
    # * Bar, launcher, notifikasi, wallpaper, lockscreen, idle, polkit agent,
    hyprlauncher   # * menu/app launcher bawaan Hypr ecosystem, dipakai di SUPER+R
    brightnessctl  # * tombol brightness laptop
    playerctl      # * tombol media next/prev/play-pause
    # * Pakai wallet plasma buat nyimpen kredensial dan tetap ada walau nantinya plasma hilang
    kdePackages.kwallet
    kdePackages.kwallet-pam
    udiskie # * Auto-mount + notifikasi + kasih menu eject pada usb drive
    xrdb    # * Set Xft.dpi biar app XWayland (steam, dll) gak kekecilan/blur di monitor scale 1.5 (lihat modules/hyprland/autostart.lua)
  ];
}
```

</details>

### `modules/desktop/kde-apps.nix`

SHA-256: `b8e538968fd68f6320c83cf4cf8d687f34fa9f3bc9f2097969daa2573436f58f`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs.kdePackages; [
    kdeconnect-kde
    partitionmanager
  ];
}
```

</details>

### `modules/desktop/plasma.nix`

SHA-256: `188c4f6f7f581588c703f00d70d8bc7cb599ed61942760edc557169007485dd4`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
```

</details>

### `home/rizz404/default.nix`

SHA-256: `bcee89f3d4b1ecc2e7a07a0cb32ecf2be72e890e48beb207207f6dbdba23388c`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  imports = [
    ./fish
    ./starship
    ./git
    ./wezterm
    ./micro
    ./hyprland
    ./noctalia
    ./kde
    ./mpv
    ./udiskie
    ./gnupg
  ];

  home.stateVersion = "26.05";
}
```

</details>

### `home/rizz404/fish/default.nix`

SHA-256: `f98cc399e198294a9e4b3a437a11feaafb7d221239800fdf55308fb87e89fd23`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:

{
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
      end
    '';
    shellAliases = {
      ls = "eza --icons";
      ll = "eza -l --icons --git --group-directories-first";
      la = "eza -la --icons --git --group-directories-first";
      tree = "eza --tree --icons";
    };
  };
}
```

</details>

### `home/rizz404/git/default.nix`

SHA-256: `b83bbfaf6e265b9fa67ac89ad4d7d9a2450b370a57741ba631b5738d02c884f6`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Rizqiansyah";
        email = "rizzthenotable@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
```

</details>

### `home/rizz404/gnupg/default.nix`

SHA-256: `4f729ab8ba1208d3178022a8b6d89bfb185b79296e0dd74a85f87faa20cabaa6`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };
}
```

</details>

### `home/rizz404/hyprland/compact-workspaces.sh`

SHA-256: `3fd5ba05f26ec23559ee14a24ec48be395bea0269c3144c68c14990ce5c4972f`

<details>
<summary>Lihat isi lengkap</summary>

```bash
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
```

</details>

### `home/rizz404/hyprland/default.nix`

SHA-256: `dd126f40dae7d8849b2e99c72f280a9026632edb62677e7a665bb8dc5f285b3c`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = null; # paket sudah disediakan system-wide lewat modules/desktop/hyprland.nix
    configType = "lua";
    extraConfig = builtins.readFile ./hyprland.lua;
  };
  xdg.portal.config.common = {
    default = "*";

    # Fix "Brave sync chain putus / minta kode ulang tiap ganti sesi".
    # Root cause-nya BUKAN cuma soal KWallet ke-unlock atau nggak — Brave
    # minta encryption key-nya lewat portal org.freedesktop.impl.portal.Secret
    # (dicek: ~/.config/BraveSoftware/.../Local State -> os_crypt.portal ada
    # "prev_init_success": false). Satu-satunya portal yang implement Secret
    # di sistem ini itu kwallet.portal (dari paket kwallet), tapi file itu
    # nulis `UseIn=kde` — jadi kalau default (wildcard "*" di atas) yang
    # nentuin, dia di-skip pas XDG_CURRENT_DESKTOP=Hyprland (cuma cocok pas
    # =KDE/Plasma). Brave gak dapet backend Secret sama sekali → gagal diem-
    # diem → key sync chain-nya gak ke-simpan/ke-baca konsisten.
    #
    # Override eksplisit di sini nembus batasan UseIn= itu (beda dari
    # wildcard "*", preferensi per-interface yang dinamain gini emang gak
    # dicek ulang ke UseIn= oleh xdg-desktop-portal), jadi Secret SELALU
    # diarahin ke kwallet apapun desktop-nya — Plasma tetap kwallet juga
    # (gak ada bedanya buat sesi Plasma), Hyprland sekarang ikut dapet.
    "org.freedesktop.impl.portal.Secret" = [ "kwallet" ];
  };

  xdg.configFile = {
    "hypr/peek-desktop.sh" = {
      source = ./peek-desktop.sh;
      executable = true;
    };

    "hypr/compact-workspaces.sh" = {
      source = ./compact-workspaces.sh;
      executable = true;
    };

    "hypr/smart-focus.sh" = {
      source = ./smart-focus.sh;
      executable = true;
    };

    "hypr/swap-workspaces.sh" = {
      source = ./swap-workspaces.sh;
      executable = true;
    };

    "hypr/modules/hyprland/monitors.lua".source = ./modules/monitors.lua;
    "hypr/modules/hyprland/programs.lua".source = ./modules/programs.lua;

    # Placeholder @KWALLET_PAM_INIT@ diganti path binary pam_kwallet_init
    # yang asli (buat auto-unlock KWallet/ksecretd, lihat komentar di
    # modules/autostart.lua). Ditulis begini (bukan hardcode path store-nya)
    # biar tetap valid walau hash-nya berubah pas kwallet-pam ke-update.
    "hypr/modules/hyprland/autostart.lua".text = builtins.replaceStrings
      [ "@KWALLET_PAM_INIT@" ]
      [ "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init" ]
      (builtins.readFile ./modules/autostart.lua);

    "hypr/modules/hyprland/environment.lua".source = ./modules/environment.lua;
    "hypr/modules/hyprland/permissions.lua".source = ./modules/permissions.lua;
    "hypr/modules/hyprland/appearance.lua".source = ./modules/appearance.lua;
    "hypr/modules/hyprland/animations.lua".source = ./modules/animations.lua;
    "hypr/modules/hyprland/layout.lua".source = ./modules/layout.lua;
    "hypr/modules/hyprland/misc.lua".source = ./modules/misc.lua;
    "hypr/modules/hyprland/input.lua".source = ./modules/input.lua;
    "hypr/modules/hyprland/keybindings.lua".source = ./modules/keybindings.lua;
    "hypr/modules/hyprland/windowrules.lua".source = ./modules/windowrules.lua;
    "hypr/modules/hyprland/rustdesk.lua".source = ./modules/rustdesk.lua;
  };

}
```

</details>

### `home/rizz404/hyprland/hyprland.lua`

SHA-256: `2a3e295e75964f92e5487d750ea192dc8dc675b8846e167d759edf32ad02dc28`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-- Entry point config Hyprland (Lua). Tiap section dipecah ke modules/,
-- di-import di sini pakai require(), lihat https://wiki.hypr.land/Configuring/Start/
-- Path modul di-symlink oleh home-manager (lihat default.nix -> xdg.configFile),
-- rooted di ~/.config/hypr, jadi "modules.hyprland.xxx" -> modules/hyprland/xxx.lua
require("modules.hyprland.monitors")
require("modules.hyprland.autostart")
require("modules.hyprland.environment")
require("modules.hyprland.permissions")
require("modules.hyprland.appearance")
require("modules.hyprland.animations")
require("modules.hyprland.layout")
require("modules.hyprland.misc")
require("modules.hyprland.input")
require("modules.hyprland.keybindings")
require("modules.hyprland.windowrules")
require("modules.hyprland.rustdesk")
```

</details>

### `home/rizz404/hyprland/modules/animations.lua`

SHA-256: `4927454f568e974ba61160d470b43ba5c4e4149900efda16f242f486499e588b`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-----------------------
---- ANIMATIONS  ----
---- Preset: Smooth ----
-----------------------
hl.curve("easeOutQuint", {
    type = "bezier",
    points = {{0.23, 1}, {0.32, 1}}
})
hl.curve("easeInOutCubic", {
    type = "bezier",
    points = {{0.65, 0.05}, {0.36, 1}}
})

-- Spring dipakai buat window - kesan "settle" halus, bukan cuma ease linear
hl.curve("easy", {
    type = "spring",
    mass = 1,
    stiffness = 71.2633,
    dampening = 15.8273644
})

hl.animation({
    leaf = "global",
    enabled = true,
    speed = 10,
    bezier = "default"
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 5.39,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4.79,
    spring = "easy"
})
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 4.1,
    spring = "easy",
    style = "popin 80%"
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 2.5,
    bezier = "easeInOutCubic",
    style = "popin 80%"
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 2.5,
    bezier = "easeInOutCubic"
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 2.2,
    bezier = "easeInOutCubic"
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3.5,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 3.81,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4,
    bezier = "easeOutQuint",
    style = "fade"
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 2.2,
    bezier = "easeInOutCubic",
    style = "fade"
})
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 2.3,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 2,
    bezier = "easeInOutCubic"
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 3.2,
    bezier = "easeOutQuint",
    style = "slide"
})
hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 3.2,
    bezier = "easeOutQuint",
    style = "slide"
})
hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 3.2,
    bezier = "easeOutQuint",
    style = "slide"
})
hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 7,
    bezier = "easeOutQuint"
})
```

</details>

### `home/rizz404/hyprland/modules/appearance.lua`

SHA-256: `5e4040316423a0ec2275f7677de98f27e063648a25879a7592efd62b23cbccf3`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 4,

        border_size = 1,

        resize_on_border = false,

        allow_tearing = false,

        layout = "dwindle"
    },

    decoration = {
        rounding = 8,
        rounding_power = 2,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696
        }
    },

    animations = {
        enabled = true
    }
})
```

</details>

### `home/rizz404/hyprland/modules/autostart.lua`

SHA-256: `bc1336ddb9dd02bfe666cd1e0249f4d09ecef9b8b67b6be95d03f1ff870afd58`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-------------------
---- AUTOSTART ----
-------------------
-- * Udah ada noctalia gak usah rakit dari awal
-- * Noctalia sendiri sudah di-autostart dari modules/noctalia/autostart.lua, gak perlu diulang di sini

-- * Matiin drkonqi-coredump-launcher.socket pas Hyprland nyala biar gak ngebug crash
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user stop drkonqi-coredump-launcher.socket")
end)

-- * Pinjem kwallet untuk hyprland buat simpen credentials
hl.on("hyprland.start", function()
    hl.exec_cmd("@KWALLET_PAM_INIT@")
end)

-- Monitor scale 1.5 (fractional) + XWayland gak support fractional scaling
-- native (`xrandr --query` selalu lapor 1280x720, bukan 1920x1080 fisik,
-- gak peduli xwayland.force_zero_scaling di modules/hyprland/misc.lua).
-- Xft.dpi = 144 (96 * 1.5) ini yang paling reliable dites langsung: app
-- CEF/GTK yang lewat XWayland (steam, dkk — cek `hyprctl clients -j | grep
-- xwayland`) baca resource ini buat nentuin device scale factor sendiri,
-- hasilnya pas ukuran DAN tajam (beda dari GDK_SCALE/QT_SCALE_FACTOR yang
-- sempat dicoba di modules/hyprland/environment.lua, dibuang lagi karena
-- korbanin ketajaman). Qt (ONLYOFFICE) gak ikut baca resource ini — belum
-- ketemu fix bersihnya, lihat catatan di environment.lua.
hl.on("hyprland.start", function()
    hl.exec_cmd("sh -c 'echo \"Xft.dpi: 144\" | xrdb -merge -'")
end)
```

</details>

### `home/rizz404/hyprland/modules/environment.lua`

SHA-256: `91bd478e31b2d31d89e440d5f4210bba69566ecdcbac0dc80ff1f0fd24816236`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- * Harusnya gak usah dijelasin env itu apa, beberapa juga self explanatory
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- CATATAN SOAL SCALING XWAYLAND (baca modules/misc.lua buat konteks
-- force_zero_scaling): sempat dicoba GDK_SCALE/QT_SCALE_FACTOR=2 di sini
-- buat kompensasi ukuran, tapi DIBUANG lagi setelah dites langsung:
--   - `xrandr --query` nunjukin XWayland tetap lapor resolusi 1280x720
--     (bukan 1920x1080 fisik) ke app walau force_zero_scaling aktif — jadi
--     app yang auto-detect scale dari situ (Qt, via mm fisik ÷ resolusi ini)
--     tetap dapet angka kekecilan (~1.09x, bukan 1.5x).
--   - QT_SCALE_FACTOR manual "nutupin" ukurannya, TAPI ini post-render
--     stretch kasar (didokumentasikan di Qt sendiri), bukan native re-render
--     — kanvas dokumen ONLYOFFICE (dirender CEF, bukan Qt widget biasa)
--     jadi keliatan blur lagi walau ukurannya udah bener.
--   - GDK_SCALE gak kepakai app manapun yang beneran GTK-XWayland di sistem
--     ini, jadi gak ada gunanya juga dipertahanin.
-- Fix yang beneran kepake taruh di Xft.dpi (lihat modules/autostart.lua) —
-- itu yang kebukti bikin Steam (CEF) pas ukuran + tajam tanpa env var Qt di
-- atas. ONLYOFFICE spesifik masih belum ketemu fix yang bersih (env var Qt
-- selalu ujungnya trade-off ukuran vs blur di kanvas dokumennya) — untuk
-- sementara pakai fitur Zoom bawaan ONLYOFFICE (pojok kanan bawah) buat
-- kanvas dokumennya, itu native re-render jadi tetep tajam di zoom berapa
-- pun.

-- * Biar bisa open with di dolphin jadi buat manual
hl.env("XDG_MENU_PREFIX", "hyprland-")

-- * Tanpa ini, app KDE (Dolphin dkk) gak load plugin KDEPlasmaPlatformTheme6,
--   jadi gak masuk jalur yang baca AccentColor/ColorScheme buat recolor icon dinamis
-- * Dicomment sementara (2026-09-16): diduga jadi penyebab UI dialog extract
--   Dolphin/Ark ke-corrupt (Options panel numpuk, tombol Extract gak kepencet).
--   Plugin KDEPlasmaPlatformTheme6 diduga punya popup-repaint bug di Hyprland.
--   Test: uncomment lagi kalau home-manager switch abis ini bug-nya ilang.
-- hl.env("QT_QPA_PLATFORMTHEME", "kde6")
```

</details>

### `home/rizz404/hyprland/modules/input.lua`

SHA-256: `a1c5463b977165790305ce7751ee576123730d1e91fe0f8f6af9884d6029c145`

<details>
<summary>Lihat isi lengkap</summary>

```lua
---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
            -- * Default libinput "lrm" bikin tap 3 jari = klik tengah = paste
            --   primary selection. Kepencet gak sengaja pas swipe 3 jari
            --   workspace kecepetan/kependekan (jatuh ke tap-detection,
            --   bukan gesture). "lmr" bikin tap 3 jari jadi klik kanan --
            --   masih ada efeknya, tapi gak nyisipin teks nyasar kayak paste.
            tap_button_map = "lmr"
        }
    },

    -- * Default 300px kerasa kejauhan buat trackpad kecil -- harus geser
    --   hampir sepanjang trackpad baru workspace-nya pindah. Diturunin biar
    --   lebih "sat set" (snappier), gak perlu swipe penuh.
    gestures = {
        workspace_swipe_distance = 150
    }
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})
```

</details>

### `home/rizz404/hyprland/modules/keybindings.lua`

SHA-256: `2b961bbc9e1e7eda7bce262f563ea201518dbe0d76765832d4a3f32f3320a5f6`

<details>
<summary>Lihat isi lengkap</summary>

```lua
---------------------
---- KEYBINDINGS ----
---------------------
-- * Keybindings lebih bervariasi jadi gak usah pakai variable
-- * Beberapa udah self explanatory
local programs = require("modules.hyprland.programs")

hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(programs.terminal))
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + M", hl.dsp.exec_cmd("~/.config/hypr/peek-desktop.sh"))
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("~/.config/hypr/peek-desktop.sh"))
hl.bind("SUPER + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind("F11", hl.dsp.window.fullscreen({
    action = "toggle"
}))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({
    action = "toggle"
}))
-- * Kayak WINDOWS + R
hl.bind("SUPER + R", hl.dsp.exec_cmd(programs.menu))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Toggle window fokus antara floating <-> tiling
-- * Window yang di-toggle jadi floating otomatis di-resize ke ukuran wajar
--   (900x600) + di-center, bukan ngewarisin ukuran tiled-nya yang sering
--   nyaris fullscreen (auto-maximize) -- biar kalau ada beberapa window
--   di-float bareng gak langsung numpuk penuh nutupin layar
hl.bind("SUPER + SHIFT + SPACE", function()
    hl.dispatch(hl.dsp.window.float({
        action = "toggle"
    }))
    local win = hl.get_active_window()
    if win and win.floating then
        hl.dispatch(hl.dsp.window.resize({
            x = 900,
            y = 600
        }))
        hl.dispatch(hl.dsp.window.center())
    end
end)

-- Move focus with SUPER + arrow keys
-- * smart-focus.sh: fokus terarah bawaan Hyprland gak nyebrang antara
--   window tiling & floating (dua domain terpisah, gak ada config buat
--   nyatuin) -- script ini coba fokus arah biasa dulu, baru fallback nyari
--   window terdekat di domain sebaliknya kalau gak ada tetangga di domain
--   yang sama
hl.bind("SUPER + left", hl.dsp.exec_cmd("~/.config/hypr/smart-focus.sh left"))
hl.bind("SUPER + right", hl.dsp.exec_cmd("~/.config/hypr/smart-focus.sh right"))
hl.bind("SUPER + up", hl.dsp.exec_cmd("~/.config/hypr/smart-focus.sh up"))
hl.bind("SUPER + down", hl.dsp.exec_cmd("~/.config/hypr/smart-focus.sh down"))

-- Resize focused window with SUPER + SHIFT + arrow keys
-- * Cuma kerasa efeknya kalau ada window lain buat di-resize bareng di
--   workspace yang sama (window tunggal yang udah fullscreen/maximize gak
--   punya boundary buat digeser)
-- * relative = true wajib ada -- tanpa itu x/y dibaca sebagai ukuran
--   absolut (window bisa error "Invalid size" kalau x/y ke-set 0), bukan
--   delta pixel kayak resizeactive classic
local resize_step = 40
hl.bind("SUPER + SHIFT + left", hl.dsp.window.resize({
    x = -resize_step,
    y = 0,
    relative = true
}), {
    repeating = true
})
hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize({
    x = resize_step,
    y = 0,
    relative = true
}), {
    repeating = true
})
hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({
    x = 0,
    y = -resize_step,
    relative = true
}), {
    repeating = true
})
hl.bind("SUPER + SHIFT + down", hl.dsp.window.resize({
    x = 0,
    y = resize_step,
    relative = true
}), {
    repeating = true
})

-- Tukar posisi window fokus dengan window di arah panah, SUPER + ALT + arrow
-- * direction pakai kata penuh ("left"/"right"/dst), bukan singkatan l/r/u/d
--   kayak classic swapwindow -- singkatan bikin dispatcher gak nemu window
--   tetangganya sama sekali
-- * Cuma kerasa efeknya kalau ada 2+ window tiled di workspace yang sama
hl.bind("SUPER + ALT + left", hl.dsp.window.swap({
    direction = "left"
}))
hl.bind("SUPER + ALT + right", hl.dsp.window.swap({
    direction = "right"
}))
hl.bind("SUPER + ALT + up", hl.dsp.window.swap({
    direction = "up"
}))
hl.bind("SUPER + ALT + down", hl.dsp.window.swap({
    direction = "down"
}))

hl.bind("CTRL + SUPER + right", hl.dsp.focus({
    workspace = "+1"
}))
hl.bind("CTRL + SUPER + left", hl.dsp.focus({
    workspace = "-1"
}))

for i = 1, 10 do
    local key = i % 10
    hl.bind("CTRL + SUPER + " .. key, hl.dsp.focus({
        workspace = i
    }))
end

-- Switch workspaces with "SUPER" + [0-9]
-- Move active window to a workspace with "SUPER" + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key, hl.dsp.focus({
        workspace = i
    }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({
        workspace = i
    }))
end

-- Tukar SEMUA window antara workspace aktif dengan workspace [0-9], SUPER +
-- CTRL + SHIFT + [0-9]
-- * Beda dari SUPER+SHIFT+n (cuma mindahin window aktif) -- ini nuker isi
--   dua workspace sekaligus, kayak "workspace 1 dan 2 saling tukar semua
--   window"-nya
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + CTRL + SHIFT + " .. key, hl.dsp.exec_cmd("~/.config/hypr/swap-workspaces.sh " .. i))
end

-- Example special workspace (scratchpad)
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({
    workspace = "special:magic"
}))

-- * Rapetin workspace 1-10: tutup celah kosong
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("~/.config/hypr/compact-workspaces.sh"))

-- Scroll through existing workspaces with "SUPER" + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({
    workspace = "e+1"
}))
hl.bind("SUPER + mouse_up", hl.dsp.focus({
    workspace = "e-1"
}))

-- Move/resize windows with "SUPER" + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), {
    mouse = true
})
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), {
    mouse = true
})

-- * Live-resize gaps tanpa reload config
local default_gaps_out = tonumber(hl.get_config("general.gaps_out")) or 8
local default_gaps_in = tonumber(hl.get_config("general.gaps_in")) or 4

local function resize_gaps(step)
    return function()
        local gaps_out = tonumber(hl.get_config("general.gaps_out")) or default_gaps_out
        local gaps_in = tonumber(hl.get_config("general.gaps_in")) or default_gaps_in
        hl.config({
            general = {
                gaps_out = math.max(0, math.floor(gaps_out + step)),
                gaps_in = math.max(0, math.floor(gaps_in + step / 2))
            }
        })
    end
end

hl.bind("CTRL + SUPER + equal", resize_gaps(4))
hl.bind("CTRL + SUPER + minus", resize_gaps(-4))
hl.bind("CTRL + SUPER + G", function()
    hl.config({
        general = {
            gaps_out = default_gaps_out,
            gaps_in = default_gaps_in
        }
    })
end)

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
    locked = true,
    repeating = true
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), {
    locked = true,
    repeating = true
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), {
    locked = true,
    repeating = true
})

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
    locked = true
})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true
})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
    locked = true
})
```

</details>

### `home/rizz404/hyprland/modules/layout.lua`

SHA-256: `c32d0c2678582065b4b04cd209d25ec6ee610775c753d9db479afe303bb99018`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-----------------
---- LAYOUT  ----
-----------------
hl.config({
    dwindle = {
        preserve_split = true
    }
})

hl.config({
    master = {
        new_status = "master"
    }
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true
    }
})
```

</details>

### `home/rizz404/hyprland/modules/misc.lua`

SHA-256: `0900d7ecce8e6b9492f49f023f2169054edf4811a0718281fa8cbc0177c572e4`

<details>
<summary>Lihat isi lengkap</summary>

```lua
----------------
----  MISC  ----
----------------
-- * Wallpaper Hyprland sendiri gak pernah keliatan (selalu ketutup layer
-- * wallpaper Noctalia, lihat home/rizz404/noctalia/default.nix), tapi
-- * dimatiin eksplisit di sini biar gak ada proses render/load sia-sia dan
-- * gak ada kemungkinan sempet keliatan (mis. pas Noctalia belum start).
hl.config({
    misc = {
        force_default_wallpaper = 0, -- 0 atau 1 = disable anime mascot wallpaper (-1 = random, termasuk mascot)
        disable_hyprland_logo = true -- Disable random hyprland logo / anime girl background
    }
})

-- Monitor kita scale 1.5 (fractional). XWayland gak support fractional
-- scaling secara native, jadi app yang jalan lewat XWayland (steam,
-- ONLYOFFICE, dll — cek `hyprctl clients -j | grep xwayland`) di-render di
-- scale 1x lalu di-upscale bilinear sama Hyprland ke 1.5x, hasilnya teks
-- keliatan soft/blur walau decoration.blur dimatiin sekalipun (sudah
-- dites langsung: matiin decoration.blur.enabled gak ngubah apa-apa, tapi
-- render Steam pakai GDK_SCALE=2 + force_zero_scaling langsung jadi tajam).
-- force_zero_scaling bikin XWayland ngaku scale=1 (dimensi = resolusi fisik
-- monitor, bukan resolusi logical yang udah dibagi 1.5), jadi Hyprland gak
-- perlu upscale sama sekali buat nampilin surface-nya 1:1 piksel.
hl.config({
    xwayland = {
        force_zero_scaling = true
    }
})
```

</details>

### `home/rizz404/hyprland/modules/monitors.lua`

SHA-256: `0a8627424a1ebecb2743134c6dedb7f07bc3a345d460631cbb748bd3101321e1`

<details>
<summary>Lihat isi lengkap</summary>

```lua
------------------
---- MONITORS ----
------------------
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto"
})
```

</details>

### `home/rizz404/hyprland/modules/permissions.lua`

SHA-256: `5129407bf79907573e216842ec82ff4fe2401686daa134a834ff2da94ace2d8e`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-----------------------
----- PERMISSIONS -----
-----------------------
-- * Belum ada permission yang mau ditambahin
```

</details>

### `home/rizz404/hyprland/modules/programs.lua`

SHA-256: `4bd5b6391c602443ffe51f049be0275fc957670e99b8ffbb43738a1720143279`

<details>
<summary>Lihat isi lengkap</summary>

```lua
---------------------
---- MY PROGRAMS ----
---------------------
-- * Tambahin variable nya biar gampang
-- * Dipakai di modules/keybindings.lua lewat require("modules.hyprland.programs")
return {
    terminal = "wezterm",
    fileManager = "dolphin",
    menu = "hyprlauncher"
}
```

</details>

### `home/rizz404/hyprland/modules/rustdesk.lua`

SHA-256: `1a07b9e949f4329c9d05d6f9eff1c5d97c7d239b278c2f6a6c0481b509e7c638`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-------------------
---- RUSTDESK -----
-------------------
-- * Portingan dari kwinrulesrc "disableglobalshortcuts" di Plasma (lihat
--   home/rizz404/kde/kwin.nix) -- di sana window rule-nya statis, cuma
--   nge-match satu title spesifik ("519095509@fujiyama - ..."). Di Hyprland
--   dibikin lebih umum: submap kosong yang di-toggle otomatis lewat event
--   window.active, jadi berlaku buat SEMUA target remote, gak cuma fujiyama
-- * Submap kosong = semua bind normal (termasuk mouse bind) berhenti
--   nyantol selama submap ini aktif -- keystroke/klik jadi langsung
--   diteruskan ke window RustDesk yang fokus, RustDesk forward ke device
--   remote, jadi keybinding yang kepake punya device remote-nya, bukan
--   punya Hyprland lokal
-- * define_submap butuh minimal 1 bind biar submap-nya beneran ke-
--   register -- submap yang isinya kosong total gak dianggap valid sama
--   Hyprland (dicoba: dispatch-nya error "submap doesn't exist (wasn't
--   registered!)"). Makanya dikasih 1 bind dummy (no_op) ke kombinasi yang
--   mustahil ke-pencet manusia -- key lain yang gak di-bind di submap ini
--   otomatis fallthrough diteruskan ke aplikasi (perilaku default Hyprland
--   untuk key yang gak dikenali di dalam submap manapun)
hl.define_submap("rustdesk", function()
    hl.bind("CTRL + ALT + SHIFT + SUPER + F12", hl.dsp.no_op())
end)

-- * Window utama RustDesk (list device) title-nya cuma "RustDesk", beda
--   sama window sesi remote yang aktif ("<id>@<host> - Remote Desktop -
--   RustDesk") -- match title-nya biar gak ke-disable pas cuma buka list
local function is_rustdesk_session(win)
    return win ~= nil and win.class == "rustdesk" and win.title ~= nil and
        win.title:find("Remote Desktop - RustDesk", 1, true) ~= nil
end

local function sync_rustdesk_submap()
    local in_session = is_rustdesk_session(hl.get_active_window())
    local current_submap = hl.get_current_submap()

    if in_session and current_submap ~= "rustdesk" then
        hl.dispatch(hl.dsp.submap("rustdesk"))
    elseif not in_session and current_submap == "rustdesk" then
        hl.dispatch(hl.dsp.submap("reset"))
    end
end

hl.on("window.active", sync_rustdesk_submap)
-- * Jaga-jaga kalau window sesi remote-nya ditutup duluan sebelum window
--   lain sempat fokus (window.active gak selalu ke-trigger di kondisi ini)
hl.on("window.close", sync_rustdesk_submap)
```

</details>

### `home/rizz404/hyprland/modules/windowrules.lua`

SHA-256: `0e85030e1f389a9c78a375d037e04985b7d4e20ad6d5db0beb3e359446c53357`

<details>
<summary>Lihat isi lengkap</summary>

```lua
--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name = "suppress-maximize-events",
    match = {
        class = ".*"
    },

    suppress_event = "maximize"
})

-- WezTerm (class org.wezfurlong.wezterm, dicek via `hyprctl clients -j`) render
-- ulang tiap terima event resize dari compositor. Pas dia kena tile (mis. buka
-- window kedua bikin dwindle ngebagi split), animasi "windows"/"windowsIn" di
-- modules/hyprland/animations.lua ngirim BANYAK event resize perantara sepanjang
-- animasi (bukan cuma satu lompatan ke ukuran akhir). Reflow scrollback WezTerm
-- ke tiap ukuran perantara itu ngerusak baris yang punya karakter lebar (nerd
-- font icon/ASCII art fastfetch) kalau tergilas ke lebih sempit lalu balik lebar
-- lagi pas animasi settle — window yang UDAH kebuka sebelum tile jadi "rusak".
-- Window yang BARU dibuka pas tiling juga bisa keburu render (mis. fastfetch)
-- sebelum animasi selesai ke ukuran final, jadi teksnya kepotong.
-- Matiin animasi resize/gerak khusus buat WezTerm (bukan global) bikin tiling
-- langsung lompat ke ukuran akhir tanpa event perantara, ngilangin race
-- condition ini tanpa ngorbanin animasi window app lain.
hl.window_rule({
    name = "no-resize-anim-wezterm",
    match = {
        class = "^(org\\.wezfurlong\\.wezterm)$"
    },

    animation = "noanim"
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false
    },

    no_focus = true
})

-- Hyprland-run windowrule
hl.window_rule({
    name = "move-hyprland-run",
    match = {
        class = "hyprland-run"
    },

    move = "20 monitor_h-120",
    float = true
})

-- Dialog file picker (Open/Save) dari portal xdg-desktop-portal-gtk/kde.
-- Title-nya selalu "<app/site> wants to open/save" apapun app pemanggilnya
-- (browser, electron, dll) — dipakai buat identifikasi karena class-nya ikut
-- app pemanggil (mis. Brave munculin class "brave", beda dari window utama
-- "brave-browser"), jadi gak bisa diandalkan lintas app.
-- Dialog ini didesain fixed-size oleh GTK; kalau ikut kena "auto-maximize"
-- di bawah, dia dipaksa gede sepenuh layar dan layoutnya berantakan (tombol
-- Open/Cancel bisa ke-push keluar canvas).
hl.window_rule({
    name = "float-file-picker",
    match = {
        title = ".*wants to (open|save).*"
    },
    float = true,
    size = {960, 680}
})

hl.window_rule({
    name = "auto-maximize",
    match = {
        class = "^(?!dev\\.noctalia\\.Noctalia$|hyprland-run$|org\\.kde\\.dolphin$).*$",
        title = "^(?!.*wants to (open|save)).*$"
    },
    maximize = true
})

-- Dolphin (class org.kde.dolphin) sering ke-trigger buka bukan cuma dari
-- SUPER+E manual, tapi juga dari app lain lewat aksi "show in file
-- manager"/"open containing folder" (mis. dari Brave downloads, qBittorrent,
-- AB Download Manager) yang shell out ke dolphin. Kalau instance itu kena
-- "auto-maximize" di atas, window-nya kadang ngebug parah (gagal ke-render/
-- gak bisa kebuka sama sekali) — diduga terkait bug repaint yang sama yang
-- disebut di modules/hyprland/environment.lua soal Qt KDEPlasmaPlatformTheme6
-- di Hyprland. Excluded dari auto-maximize di atas + di-float paksa di sini
-- biar Dolphin selalu jadi window normal (resizable, gak dipaksa fullscreen)
-- apapun yang men-trigger dia.
hl.window_rule({
    name = "float-dolphin",
    match = {
        class = "^(org\\.kde\\.dolphin)$"
    },
    float = true
})

-- Waydroid full UI (`waydroid show-full-ui`, class "Waydroid") ngunci ukuran
-- display Android dari ukuran window pertama kali muncul dan gak ngikutin
-- resize sesudahnya. Kalau dia kena "auto-maximize" / di-tile setengah layar
-- bareng window lain, Android tetap ngira ukurannya yang lama → layout
-- kepotong / gak pas sama window. Dipaksa fullscreen biar ukurannya selalu
-- konsisten = ukuran monitor. Window per-app mode multi_windows punya class
-- "waydroid.<package>" jadi gak kena rule ini.
hl.window_rule({
    name = "fullscreen-waydroid",
    match = {
        class = "^(Waydroid)$"
    },
    fullscreen = true
})

-- Sebagian app render window-nya ke buffer ARGB yang punya alpha channel di
-- hampir semua piksel (antialiasing teks, rounded corner, shadow client-side)
-- walau window-nya niatnya opaque penuh. decoration.blur.enabled global di
-- appearance.lua nge-blur berdasarkan alpha AKTUAL di buffer, bukan niat
-- app-nya, jadi seluruh window keliatan "berkabut"/hazy alih-alih cuma
-- background-nya. KDE Plasma gak kena karena KWin cuma blur region yang
-- di-hint eksplisit lewat _KDE_NET_WM_BLUR_BEHIND_REGION, dan app-app ini
-- gak set hint itu. Class dikonfirmasi langsung lewat `hyprctl clients -j`
-- (bukan cuma nebak dari desktop file), kecuali chromium-browser yang
-- disamakan pola-nya dengan brave-browser (codebase sama, StartupWMClass
-- terverifikasi cocok 1:1 antara live class Brave vs desktop file-nya).
--
-- Terkonfirmasi kena (CEF/Chromium, Flutter, atau Compose Desktop — semua
-- ini dikenal alokasi surface ARGB penuh di Linux Wayland):
--   - steam, ONLYOFFICE (CEF, sumber laporan awal)
--   - brave-browser, chromium-browser, code (VS Code), itch — Chromium/CEF
--   - rustdesk — Flutter (linux embedder-nya juga selalu pakai ARGB surface)
--   - com-abdownloadmanager-desktop-AppKt — Kotlin Compose Desktop (Skiko)
--   - org.telegram.desktop — Qt tapi window/shadow-nya digambar sendiri
--     (custom CSD), isu "TelegramDesktop blurry" ini umum dilaporkan di
--     Hyprland. Sengaja TIDAK termasuk: qBittorrent (Qt Widgets standar
--     tanpa custom shadow/rounding, kemungkinan gak kena — belum ada bukti).
for _, entry in ipairs({
    { name = "steam", class = "steam" },
    { name = "onlyoffice", class = "ONLYOFFICE" },
    { name = "brave", class = "brave-browser" },
    { name = "chromium", class = "chromium-browser" },
    { name = "vscode", class = "code" },
    { name = "itch", class = "itch" },
    { name = "rustdesk", class = "rustdesk" },
    { name = "ab-download-manager", class = "com-abdownloadmanager-desktop-AppKt" },
    { name = "telegram", class = "org\\.telegram\\.desktop" }
}) do
    hl.window_rule({
        name = "no-blur-" .. entry.name,
        match = {
            class = "^(" .. entry.class .. ")$"
        },
        no_blur = true,
        opaque = true
    })
end
```

</details>

### `home/rizz404/hyprland/peek-desktop.sh`

SHA-256: `d2f0f95630c7b18f3536c965c7759e80fd0164eaa831c120995bb8cb5ae3631a`

<details>
<summary>Lihat isi lengkap</summary>

```bash
#!/usr/bin/env bash
# Toggle "peek desktop": stash semua window di workspace aktif ke special
# workspace tersembunyi (jadi keliatan desktop kosong), atau balikin lagi
# kalau udah di-stash.
#
# Hyprland versi ini (config Lua) bikin `hyprctl dispatch` expect syntax Lua
# (`hl.dsp.*`), bukan syntax classic "dispatcher arg1,arg2" lagi — makanya
# dipanggil lewat hl.dsp.window.move(), bukan movetoworkspacesilent mentah.
#
# Window yang dipindah pakai `follow = false` gak otomatis dapet fokus
# keyboard (input.follow_mouse=1 di hyprland.lua bikin fokus cuma nempel
# kalau kursor digerakin ke atasnya), jadi window yang tadi fokus sebelum
# di-peek disimpen ke state_file, terus di-fokusin eksplisit lagi pas balik.

state_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-peek-focus"
active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
stashed=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "special:peek")] | length')

if [ "$stashed" -gt 0 ]; then
    mapfile -t addrs < <(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:peek") | .address')
    for addr in "${addrs[@]}"; do
        hyprctl dispatch "hl.dsp.window.move({ window = \"address:$addr\", workspace = $active_ws, follow = false })"
    done

    if [ -s "$state_file" ]; then
        prev_addr=$(cat "$state_file")
        hyprctl dispatch "hl.dsp.focus({ window = \"address:$prev_addr\" })"
        rm -f "$state_file"
    fi
else
    focused_addr=$(hyprctl activewindow -j | jq -r '.address // empty')
    if [ -n "$focused_addr" ]; then
        printf '%s' "$focused_addr" > "$state_file"
    else
        rm -f "$state_file"
    fi

    mapfile -t addrs < <(hyprctl clients -j | jq -r --argjson ws "$active_ws" '.[] | select(.workspace.id == $ws) | .address')
    for addr in "${addrs[@]}"; do
        hyprctl dispatch "hl.dsp.window.move({ window = \"address:$addr\", workspace = \"special:peek\", follow = false })"
    done
fi
```

</details>

### `home/rizz404/hyprland/smart-focus.sh`

SHA-256: `043a84a0b7bc956957c996c9a89fe4cef57623c23b1c9644ab91401cfbe8b5cd`

<details>
<summary>Lihat isi lengkap</summary>

```bash
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
```

</details>

### `home/rizz404/hyprland/swap-workspaces.sh`

SHA-256: `5f1fe90d237af25047919b558019123a3f8965cb92ccd4143200e72bdb1fa7a8`

<details>
<summary>Lihat isi lengkap</summary>

```bash
#!/usr/bin/env bash
# Tukar semua window antara workspace aktif dengan workspace tujuan ($1).
# Dipanggil oleh SUPER+CTRL+SHIFT+[0-9] (lihat modules/hyprland/keybindings.lua).
#
# Beda dari "move to workspace" (SUPER+SHIFT+n) yang cuma mindahin window
# aktif doang -- ini nuker ISI dua workspace: semua window di workspace
# aktif pindah ke workspace tujuan, dan sebaliknya. Nomor workspace aktif
# gak berubah (fokus gak ikut window), cuma kontennya yang ketuker.

set -uo pipefail

target_ws="$1"
active_ws=$(hyprctl activeworkspace -j | jq -r '.id')

[ "$target_ws" -eq "$active_ws" ] && exit 0

clients_json=$(hyprctl clients -j)

active_addrs=$(jq -r --argjson ws "$active_ws" '.[] | select(.workspace.id == $ws) | .address' <<< "$clients_json")
target_addrs=$(jq -r --argjson ws "$target_ws" '.[] | select(.workspace.id == $ws) | .address' <<< "$clients_json")

if [ -z "$active_addrs" ] && [ -z "$target_addrs" ]; then
    exit 0
fi

while IFS= read -r addr; do
    [ -z "$addr" ] && continue
    hyprctl dispatch "hl.dsp.window.move({ window = 'address:$addr', workspace = $target_ws, follow = false })"
done <<< "$active_addrs"

while IFS= read -r addr; do
    [ -z "$addr" ] && continue
    hyprctl dispatch "hl.dsp.window.move({ window = 'address:$addr', workspace = $active_ws, follow = false })"
done <<< "$target_addrs"
```

</details>

### `home/rizz404/kde/apps.nix`

SHA-256: `8d548a749ea79a9b098ad7aec49cd5ed62cb55a275e497c33c7277ce0142df7c`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:

{
  programs.plasma.configFile = {
    dolphinrc = {
      General.GlobalViewProps = false;

      "KFileDialog Settings" = {
        "Places Icons Auto-resize" = false;
        "Places Icons Static Size" = 16;
      };

      "Notification Messages".warnAboutRisksBeforeActingAsAdmin = false;

      PlacesPanel.IconSize = 16;

      PreviewSettings.Plugins =
        "ffmpegthumbnailer,appimagethumbnail,audiothumbnail,glycin-heif,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,glycin-image-rs,jpegthumbnail,glycin-jxl,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,glycin-svg,svgthumbnail,ffmpegthumbs,gsf-office";
    };

    katerc = {
      General = {
        "Days Meta Infos" = 30;
        "Save Meta Infos" = true;
        "Show Full Path in Title" = false;
        "Show Menu Bar" = true;
        "Show Status Bar" = true;
        "Show Tab Bar" = true;
        "Show Url Nav Bar" = true;
      };

      filetree = {
        listMode = false;
        middleClickToClose = false;
        shadingEnabled = true;
        showCloseButton = false;
        showFullPathOnRoots = false;
        showToolbar = true;
        sortRole = 0;
      };
    };

    spectaclerc = {
      General = {
        autoSaveImage = true;
        clipboardGroup = "PostScreenshotCopyImage";
      };

      ImageSave.translatedScreenshotsFolder = "Screenshots";
      VideoSave.translatedScreencastsFolder = "Screencasts";
    };
  };
}
```

</details>

### `home/rizz404/kde/default.nix`

SHA-256: `998631f0b731fd03bb48f63577fb0c47e924e9f7ad7e182bcb162d45e2a27b0d`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:

let
  catppuccin-kde = pkgs.catppuccin-kde.override {
    flavour = [
      "mocha"
      "macchiato"
      "frappe"
      "latte"
    ];

    accents = [
      "blue"
      "rosewater"
      "pink"
      "mauve"
      "red"
      "peach"
      "green"
      "teal"
      "sapphire"
      "lavender"
    ];

    winDecStyles = [ "modern" ];
  };
in
{
  imports = [
    ./workspace.nix
    ./shortcuts.nix
    ./kwin.nix
    ./apps.nix
    ./misc.nix
    ./theme.nix
  ];

  home.packages = [
    pkgs.papirus-icon-theme
    catppuccin-kde
  ];

  programs.plasma = {
    enable = true;

    # Tetap false selama panel/widgets belum dimigrasikan.
    overrideConfig = false;
  };

  # Temporary.
  # Nanti dihapus setelah panel/widgets dipindahkan ke Plasma Manager.
  xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc".source =
    ./plasma-org.kde.plasma.desktop-appletsrc;

  xdg.configFile."plasmashellrc".source =
    ./plasmashellrc;
}
```

</details>

### `home/rizz404/kde/kwin.nix`

SHA-256: `0de9c22bcc0ac3b15787f9da7d4d7b83c47dfefaa66fd09586b0410c2c8fa5ca`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:

{
  programs.plasma.configFile = {
    kwinrc = {
      Desktops = {
        Number = 1;
        Rows = 1;
      };

      Xwayland.Scale = 1;
    };

    kwinrulesrc = {
      "02ecdb93-7a4d-498b-8db1-aaa70b65d17f" = {
        Description = "RustDesk Remote Shortcuts";
        disableglobalshortcuts = true;
        disableglobalshortcutsrule = 2;
        title = "519095509@fujiyama - Remote Desktop - RustDesk";
        titlematch = 2;
        wmclass = "rustdesk";
        wmclassmatch = 1;
      };

      General = {
        count = 1;
        rules = "02ecdb93-7a4d-498b-8db1-aaa70b65d17f";
      };
    };
  };
}
```

</details>

### `home/rizz404/kde/misc.nix`

SHA-256: `71b634d0b196b9560419efaf58ced77f849ed6f25fc41407e17f8d458b1f186f`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:

{
  programs.plasma.configFile = {
    kded5rc = {
      Module-browserintegrationreminder.autoload = false;
      Module-device_automounter.autoload = false;
    };

    kwalletrc.Wallet."First Use" = false;
  };
}
```

</details>

### `home/rizz404/kde/plasma-org.kde.plasma.desktop-appletsrc`

SHA-256: `4312254f5ab1bce955775de628562279faa2dcce42ecf069909fd21bc5bbea1b`

<details>
<summary>Lihat isi lengkap</summary>

```ini
[ActionPlugins][0]
MiddleButton;NoModifier=org.kde.paste
RightButton;NoModifier=org.kde.contextmenu

[ActionPlugins][1]
RightButton;NoModifier=org.kde.contextmenu

[Containments][189]
ItemGeometries-1366x768=Applet-262:928,240,208,208,0;Applet-255:928,448,208,256,0;Applet-258:1136,192,208,304,0;Applet-259:1136,496,224,240,0;
ItemGeometriesHorizontal=Applet-262:928,240,208,208,0;Applet-255:928,448,208,256,0;Applet-258:1136,192,208,304,0;Applet-259:1136,496,224,240,0;
activityId=d1b358ab-0c58-49cb-9b8f-0df08b21891d
formfactor=0
immutability=1
lastScreen=0
location=0
plugin=org.kde.plasma.folder
wallpaperplugin=org.kde.slideshow

[Containments][189][/Wallpaper/org.kde.image/General]
Image=file:///home/lara/Imágenes/stretched-1366-768-320259.jpg

[Containments][189][Applets][255]
immutability=1
plugin=org.kde.plasma.systemmonitor.diskusage

[Containments][189][Applets][255][Configuration]
CurrentPreset=org.kde.plasma.systemmonitor

[Containments][189][Applets][255][Configuration][Appearance]
chartFace=org.kde.ksysguard.horizontalbars
title=Disk Usage

[Containments][189][Applets][255][Configuration][ConfigDialog]
DialogHeight=630
DialogWidth=810

[Containments][189][Applets][255][Configuration][SensorColors]
disk/.*/usedPercent=73,77,100
disk/all/usedPercent=77,100,73
disk/bd74beaa-c72c-4a4a-ba70-ad602f145601/usedPercent=73,77,100
disk/f77c515d-f778-460a-83de-bde615749005/usedPercent=100,73,77

[Containments][189][Applets][255][Configuration][Sensors]
highPrioritySensorIds=["disk/.*/usedPercent"]
lowPrioritySensorIds=["disk/all/total"]
totalSensors=["disk/all/usedPercent"]

[Containments][189][Applets][258]
immutability=1
plugin=org.kde.plasma.systemmonitor.cpucore

[Containments][189][Applets][258][Configuration]
CurrentPreset=org.kde.plasma.systemmonitor

[Containments][189][Applets][258][Configuration][Appearance]
chartFace=org.kde.ksysguard.barchart
title=Individual Core Usage

[Containments][189][Applets][258][Configuration][SensorColors]
cpu/cpu.*/usage=73,77,100
cpu/cpu0/usage=73,77,100
cpu/cpu1/usage=100,73,91
cpu/cpu2/usage=100,96,73
cpu/cpu3/usage=73,100,82

[Containments][189][Applets][258][Configuration][Sensors]
highPrioritySensorIds=["cpu/cpu.*/usage"]
totalSensors=["cpu/all/usage"]

[Containments][189][Applets][259]
immutability=1
plugin=org.kde.plasma.systemmonitor.memory

[Containments][189][Applets][259][Configuration]
CurrentPreset=org.kde.plasma.systemmonitor

[Containments][189][Applets][259][Configuration][Appearance]
chartFace=org.kde.ksysguard.piechart
title=Memory Usage

[Containments][189][Applets][259][Configuration][SensorColors]
memory/physical/used=73,77,100

[Containments][189][Applets][259][Configuration][Sensors]
highPrioritySensorIds=["memory/physical/used"]
lowPrioritySensorIds=["memory/physical/total"]
totalSensors=["memory/physical/usedPercent"]

[Containments][189][Applets][262]
immutability=1
plugin=org.kde.plasma.systemmonitor.net

[Containments][189][Applets][262][Configuration]
CurrentPreset=org.kde.plasma.systemmonitor

[Containments][189][Applets][262][Configuration][Appearance]
chartFace=org.kde.ksysguard.linechart
title=Network Speed

[Containments][189][Applets][262][Configuration][ConfigDialog]
DialogHeight=630
DialogWidth=810

[Containments][189][Applets][262][Configuration][SensorColors]
network/all/download=73,77,100
network/all/upload=100,96,73

[Containments][189][Applets][262][Configuration][Sensors]
highPrioritySensorIds=["network/all/download","network/all/upload"]

[Containments][189][ConfigDialog]
DialogHeight=630
DialogWidth=810

[Containments][189][Wallpaper][org.kde.slideshow][General]
Image=file:///home/rizz404/Pictures/Wallpapers/akemi-homura.jpg
SlideInterval=7201
SlidePaths=/home/rizz404/Pictures/Wallpapers/

[Containments][190]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=4
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][190][Applets][191]
immutability=1
plugin=org.kde.plasma.kickoff

[Containments][190][Applets][191][Configuration]
popupHeight=553
popupWidth=709

[Containments][190][Applets][191][Configuration][/Configuration/General]
icon=cachyos

[Containments][190][Applets][191][Configuration][ConfigDialog]
DialogHeight=630
DialogWidth=810

[Containments][190][Applets][191][Configuration][General]
favoritesPortedToKAstats=true
icon=/home/rizz404/Pictures/miku-ghosling.ico
systemFavorites=suspend\\,hibernate\\,reboot\\,shutdown

[Containments][190][Applets][191][Configuration][Shortcuts]
global=Alt+F1

[Containments][190][Applets][191][Shortcuts]
global=Alt+F1

[Containments][190][Applets][192]
immutability=1
plugin=org.kde.plasma.panelspacer

[Containments][190][Applets][193]
immutability=1
plugin=org.kde.plasma.icontasks

[Containments][190][Applets][193][Configuration][ConfigDialog]
DialogHeight=630
DialogWidth=810

[Containments][190][Applets][193][Configuration][General]
launchers=preferred://filemanager,applications:systemsettings.desktop,preferred://browser,applications:org.wezfurlong.wezterm.desktop,applications:code.desktop

[Containments][190][Applets][194]
immutability=1
plugin=org.kde.plasma.panelspacer

[Containments][190][Applets][195]
activityId=
formfactor=0
immutability=1
lastScreen=-1
location=0
plugin=org.kde.plasma.systemtray
popupHeight=464
popupWidth=464
wallpaperplugin=org.kde.image

[Containments][190][Applets][195][Applets][196]
immutability=1
plugin=org.kde.kdeconnect

[Containments][190][Applets][195][Applets][197]
immutability=1
plugin=org.kde.plasma.cameraindicator

[Containments][190][Applets][195][Applets][198]
immutability=1
plugin=org.kde.plasma.clipboard

[Containments][190][Applets][195][Applets][199]
immutability=1
plugin=org.kde.plasma.devicenotifier

[Containments][190][Applets][195][Applets][200]
immutability=1
plugin=org.kde.plasma.manage-inputmethod

[Containments][190][Applets][195][Applets][201]
immutability=1
plugin=org.kde.plasma.notifications

[Containments][190][Applets][195][Applets][202]
immutability=1
plugin=org.kde.plasma.keyboardindicator

[Containments][190][Applets][195][Applets][203]
immutability=1
plugin=org.kde.plasma.weather

[Containments][190][Applets][195][Applets][204]
immutability=1
plugin=org.kde.kscreen

[Containments][190][Applets][195][Applets][205]
immutability=1
plugin=org.kde.plasma.keyboardlayout

[Containments][190][Applets][195][Applets][206]
immutability=1
plugin=org.kde.plasma.networkmanagement

[Containments][190][Applets][195][Applets][206][Configuration][General]
currentDetailsTab=details

[Containments][190][Applets][195][Applets][207]
immutability=1
plugin=org.kde.plasma.volume

[Containments][190][Applets][195][Applets][207][Configuration][General]
migrated=true

[Containments][190][Applets][195][Applets][209]
immutability=1
plugin=org.kde.plasma.brightness

[Containments][190][Applets][195][Applets][210]
immutability=1
plugin=org.kde.plasma.battery

[Containments][190][Applets][195][Applets][211]
immutability=1
plugin=org.kde.plasma.mediacontroller

[Containments][190][Applets][195][Applets][212]
immutability=1
plugin=org.kde.plasma.bluetooth

[Containments][190][Applets][195][General]
extraItems=org.kde.kdeconnect,org.kde.plasma.bluetooth,org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.devicenotifier,org.kde.plasma.manage-inputmethod,org.kde.plasma.mediacontroller,org.kde.plasma.notifications,org.kde.plasma.keyboardindicator,org.kde.plasma.weather,org.kde.kscreen,org.kde.plasma.battery,org.kde.plasma.brightness,org.kde.plasma.keyboardlayout,org.kde.plasma.networkmanagement,org.kde.plasma.volume
knownItems=org.kde.kdeconnect,org.kde.plasma.bluetooth,org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.devicenotifier,org.kde.plasma.manage-inputmethod,org.kde.plasma.mediacontroller,org.kde.plasma.notifications,org.kde.plasma.keyboardindicator,org.kde.plasma.weather,org.kde.kscreen,org.kde.plasma.battery,org.kde.plasma.brightness,org.kde.plasma.keyboardlayout,org.kde.plasma.networkmanagement,org.kde.plasma.volume

[Containments][190][Applets][208]
immutability=1
plugin=org.kde.plasma.digitalclock

[Containments][190][Applets][208][Configuration]
popupHeight=400
popupWidth=560

[Containments][190][Applets][208][Configuration][/]
showDate=false

[Containments][190][Applets][208][Configuration][Appearance]
showDate=false

[Containments][190][General]
AppletOrder=191;194;193;192;195;208

[ScreenMapping]
itemsOnDisabledScreens=
screenMapping=
```

</details>

### `home/rizz404/kde/plasmashellrc`

SHA-256: `09f23f0cb45eaa37dccbc81db027bda8ce7fdbd1639ef62f5fa2b4879c17fedc`

<details>
<summary>Lihat isi lengkap</summary>

```ini
[PlasmaViews][Panel 190]
alignment=132
floating=1
floatingApplets=0
panelLengthMode=0
panelOpacity=0
panelVisibility=0
shell=org.kde.plasma.desktop

[PlasmaViews][Panel 190][Defaults]
maxLength=1536
minLength=1536
offset=0
thickness=40

[PlasmaViews][Panel 2]
floating=1

[PlasmaViews][Panel 2][Defaults]
thickness=44

[Updates]
performed=/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/containmentactions_middlebutton.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/digitalclock_migrate_font_settings.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/digitalclock_migrate_showseconds_setting.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/digitalclock_rename_timezonedisplay_key.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/folderview_fix_recursive_screenmapping.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/keyboardlayout_migrateiconsetting.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/keyboardlayout_remove_shortcut.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/klipper_clear_config.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/maintain_existing_desktop_icon_sizes.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/mediaframe_migrate_useBackground_setting.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/migrate_font_weights.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/move_desktop_layout_config.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/no_middle_click_paste_on_panels.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/systemloadviewer_systemmonitor.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/unlock_widgets.js,/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/taskmanager_configUpdate_wheelEnabled.js
```

</details>

### `home/rizz404/kde/shortcuts.nix`

SHA-256: `1e31976a846815dfc4ca007de4c78827a385d2ccf1b8331004963fa62548182f`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:

{
  programs.plasma.shortcuts = {
    "KDE Keyboard Layout Switcher" = {
      "Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
      "Switch to Next Keyboard Layout" = "Meta+Alt+K";
    };

    "com.github.hluk.copyq"."LOGO+V||Show/hide main window" = "Meta+Shift+V";

    kaccess."Toggle Screen Reader On and Off" = "Meta+Alt+S";

    kmix = {
      decrease_microphone_volume = "Microphone Volume Down";
      decrease_volume = "Volume Down";
      decrease_volume_small = "Shift+Volume Down";
      increase_microphone_volume = "Microphone Volume Up";
      increase_volume = "Volume Up";
      increase_volume_small = "Shift+Volume Up";
      mic_mute = [
        "Microphone Mute"
        "Meta+Volume Mute"
      ];
      mute = "Volume Mute";
    };

    ksmserver = {
      "Lock Session" = [
        "Screensaver"
        "Meta+L"
      ];
      "Log Out" = "Ctrl+Alt+Del";
    };

    kwin = {
      "Activate Window Demanding Attention" = "Meta+Ctrl+A";
      "Edit Tiles" = "Meta+T";

      Expose = [
        "Ctrl+F9"
        "Meta+F9"
      ];

      ExposeAll = [
        "Launch (C)"
        "Ctrl+F10"
        "Meta+F10"
      ];

      ExposeClass = [
        "Ctrl+F7"
        "Meta+F7"
      ];

      "Grid View" = "Meta+G";
      "Kill Window" = "Meta+Ctrl+Esc";
      MoveMouseToCenter = "Meta+F6";
      MoveMouseToFocus = "Meta+F5";
      Overview = "Meta+Tab";
      "Show Desktop" = "Meta+D";

      "Switch One Desktop Down" = "Meta+Ctrl+Down";
      "Switch One Desktop Up" = "Meta+Ctrl+Up";
      "Switch One Desktop to the Left" = "Meta+Ctrl+Left";
      "Switch One Desktop to the Right" = "Meta+Ctrl+Right";

      "Switch Window Down" = "Meta+Alt+Down";
      "Switch Window Left" = "Meta+Alt+Left";
      "Switch Window Right" = "Meta+Alt+Right";
      "Switch Window Up" = "Meta+Alt+Up";

      "Switch to Desktop 1" = [
        "Ctrl+F1"
        "Meta+F1"
      ];

      "Switch to Desktop 2" = [
        "Ctrl+F2"
        "Meta+F2"
      ];

      "Switch to Desktop 3" = [
        "Ctrl+F3"
        "Meta+F3"
      ];

      "Switch to Desktop 4" = [
        "Ctrl+F4"
        "Meta+F4"
      ];

      "Walk Through Windows" = "Alt+Tab";

      "Walk Through Windows (Reverse)" = [
        "Alt+Shift+Tab"
        "Meta+Shift+Tab"
      ];

      "Walk Through Windows of Current Application" = [
        "Alt+`"
        "Meta+`"
      ];

      "Walk Through Windows of Current Application (Reverse)" = [
        "Alt+~"
        "Meta+~"
      ];

      "Window Close" = "Alt+F4";
      "Window Maximize" = "Meta+PgUp";
      "Window Minimize" = "Meta+PgDown";

      "Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
      "Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
      "Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
      "Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";

      "Window Operations Menu" = "Alt+F3";

      "Window Quick Tile Bottom" = "Meta+Down";
      "Window Quick Tile Left" = "Meta+Left";
      "Window Quick Tile Right" = "Meta+Right";
      "Window Quick Tile Top" = "Meta+Up";

      "Window Restore" = "Meta+Backspace";

      "Window to Next Screen" = "Meta+Shift+Right";
      "Window to Previous Screen" = "Meta+Shift+Left";

      disableInputCapture = "Meta+Shift+Esc";
      view_actual_size = "Meta+0";

      view_zoom_in = [
        "Meta++"
        "Meta+="
      ];

      view_zoom_out = "Meta+-";
    };

    mediacontrol = {
      nextmedia = "Media Next";
      pausemedia = "Media Pause";
      playpausemedia = "Media Play";
      previousmedia = "Media Previous";
      seekbackwardmedia = "Media Rewind";
      seekforwardmedia = "Media Fast Forward";
      stopmedia = "Media Stop";
    };

    org_kde_powerdevil = {
      "Decrease Keyboard Brightness" = "Keyboard Brightness Down";
      "Decrease Screen Brightness" = "Monitor Brightness Down";
      "Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
      Hibernate = "Hibernate";
      "Increase Keyboard Brightness" = "Keyboard Brightness Up";
      "Increase Screen Brightness" = "Monitor Brightness Up";
      "Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
      PowerDown = "Power Down";
      PowerOff = "Power Off";
      Sleep = "Sleep";
      "Toggle Keyboard Backlight" = "Keyboard Light On/Off";

      powerProfile = [
        "Battery"
        "Meta+B"
      ];
    };

    plasmashell = {
      "activate application launcher" = [
        "Meta"
        "Alt+F1"
      ];

      "activate task manager entry 1" = "Meta+1";
      "activate task manager entry 2" = "Meta+2";
      "activate task manager entry 3" = "Meta+3";
      "activate task manager entry 4" = "Meta+4";
      "activate task manager entry 5" = "Meta+5";
      "activate task manager entry 6" = "Meta+6";
      "activate task manager entry 7" = "Meta+7";
      "activate task manager entry 8" = "Meta+8";
      "activate task manager entry 9" = "Meta+9";

      clipboard_action = "Meta+Ctrl+X";
      cycle-panels = "Meta+Alt+P";
      "manage activities" = "Meta+Q";
      "next activity" = "Meta+A";
      "previous activity" = "Meta+Shift+A";

      "show dashboard" = [
        "Ctrl+F12"
        "Meta+M"
      ];

      # Clipboard history ala Windows.
      show-on-mouse-pos = "Meta+V";
    };

    "services/org.kde.plasma-systemmonitor.desktop"._launch =
      "Ctrl+Shift+Esc";

    "services/org.kde.spectacle.desktop" = {
      ActiveWindowScreenShot = "Shift+Print";
      FullScreenScreenShot = "Meta+Print";
    };

    "services/org.wezfurlong.wezterm.desktop"._launch =
      "Ctrl+Alt+T";
  };
}
```

</details>

### `home/rizz404/kde/theme.nix`

SHA-256: `4bedb5bc3a38c0e00c632ddac7e185e498ad1bc782ce4b3f0de440b0399fb46e`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, ... }:

# The "Moe-Dark" global theme (KDE Store, by jomada) is what's actually
# active in the live Plasma session. It's not packaged in nixpkgs, so we
# fetch it straight from the author's source repos and pin exact revisions
# -- same approach as the plugins/colorschemes in ../micro/default.nix --
# instead of committing the theme's binary assets into this repo.
#
# Only `lookAndFeel` is declared: setting it alone lets Plasma's own
# `plasma-apply-lookandfeel` apply the whole bundle (cursor, color scheme,
# window decoration, wallpaper, plasma theme) the same way picking it in
# System Settings would. plasma-manager warns against also setting
# windowDecorations/splashScreen/etc separately, since the look-and-feel
# package's own defaults already cover those and would fight with it.
#
# NOTE: this only takes effect via an autostart script that runs once per
# Plasma session login (not immediately on `home-manager switch`), and is
# skipped entirely if its content hash hasn't changed since last run. After
# switching, log out and back in to actually see it applied.
let
  moeDark = pkgs.fetchFromGitLab {
    owner = "jomada";
    repo = "moe-dark";
    rev = "1e9dcd6d89a58f1de61e13cc361f563e01dd1c26";
    hash = "sha256-bQMbOKsHsaoEC4UJ5aIYD+D/GGkEAd7txYG8+VdaTV8=";
  };

  # Cursor theme isn't part of jomada's repo (it's a separate KNS
  # dependency of the look-and-feel package), so it's fetched from its own
  # upstream project.
  whiteSurCursors = pkgs.fetchFromGitHub {
    owner = "vinceliuice";
    repo = "WhiteSur-cursors";
    rev = "e190baf618ed95ee217d2fd45589bd309b37672b";
    hash = "sha256-hFtfq8F6KeqUEBlypPCr/EKq6rif/g868vJd8c06c1I=";
  };
in
{
  programs.plasma.workspace.lookAndFeel = "Moe-Dark";

  xdg.dataFile = {
    "plasma/look-and-feel/Moe-Dark".source = "${moeDark}/look-and-feel/Moe-Dark";
    "color-schemes/MoeDark.colors".source = "${moeDark}/color-schemes/MoeDark.colors";
    "plasma/desktoptheme/Moe-Dark".source = "${moeDark}/Moe-Dark";
    "aurorae/themes/MoeDark".source = "${moeDark}/aurorae/MoeDark";
    "wallpapers/MoeDark-DarkSouls".source = "${moeDark}/Wallpapers/MoeDark-DarkSouls";
  };

  # Cursor themes are looked up under ~/.icons, not ~/.local/share/icons.
  home.file.".icons/WhiteSur-cursors".source = "${whiteSurCursors}/dist";
}
```

</details>

### `home/rizz404/kde/workspace.nix`

SHA-256: `7f94ebaac217458e3ea7def2859f059c38713ba6b6ced56ca457d1dd33b46f21`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:

{
  programs.plasma = {
    workspace = {
      iconTheme = "Papirus-Dark";
    };

    configFile = {
      kdeglobals = {
        KDE = {
          contrast = 4;
          frameContrast = 0.2;
        };

        "KFileDialog Settings" = {
          "Allow Expansion" = false;
          "Automatically select filename extension" = true;
          "Breadcrumb Navigation" = true;
          "Decoration position" = 2;
          "Show Full Path" = false;
          "Show Inline Previews" = true;
          "Show Preview" = false;
          "Show Speedbar" = true;
          "Show hidden files" = false;
          "Sort by" = "Name";
          "Sort directories first" = true;
          "Sort hidden files last" = false;
          "Sort reversed" = false;
          "Speedbar Width" = 140;
          "View Style" = "DetailTree";
        };
      };

      krunnerrc.General.FreeFloating = true;

      plasma-localerc.Formats.LANG = "en_US.UTF-8";
    };
  };
}
```

</details>

### `home/rizz404/micro/bindings.json`

SHA-256: `fac544bcc582e0f19b0b62e8c6c8dbe343d9a7350349fad4b3c24efbcc64f795`

<details>
<summary>Lihat isi lengkap</summary>

```json
{
  "Ctrl-b": "command:tree",
  "Ctrl-p": "command:fzf",
  "Ctrl-w": "Quit",
  "Ctrl-t": "AddTab",
  "Ctrl-Tab": "NextTab",
  "Ctrl-Shift-Tab": "PreviousTab",
  "Alt-Left": "PreviousTab",
  "Alt-Right": "NextTab",
  "Alt-Up": "MoveLinesUp",
  "Alt-Down": "MoveLinesDown",
  "Alt-/": "command:comment",
  "CtrlUnderscore": "command:comment",
  "Ctrl-g": "JumpLine",
  "Ctrl-Shift-p": "CommandMode",
  "Alt-j": "command:jump"
}
```

</details>

### `home/rizz404/micro/colorschemes/catppuccin-frappe-transparent.micro`

SHA-256: `5b826e1159465649d750c6c2f6be01cea9e16dbfdf887766976244e1526b6c04`

<details>
<summary>Lihat isi lengkap</summary>

```text
color-link default "#c6d0f5"
color-link comment "#949cbb"
color-link selection "#c6d0f5,#51576d"
color-link hlsearch "#81c8be"

color-link identifier "#8caaee"
color-link identifier.class "#8caaee"
color-link identifier.var "#8caaee"

color-link constant "#ef9f76"
color-link constant.number "#ef9f76"
color-link constant.string "#a6d189"

color-link symbol "#f4b8e4"
color-link symbol.brackets "#eebebe"
color-link symbol.tag "#8caaee"

color-link type "#8caaee"
color-link type.keyword "#e5c890"

color-link special "#f4b8e4"
color-link statement "#ca9ee6"
color-link preproc "#f4b8e4"

color-link underlined "#99d1db"
color-link error "bold #e78284"
color-link todo "bold #e5c890"

color-link diff-added "#a6d189"
color-link diff-modified "#e5c890"
color-link diff-deleted "#e78284"

color-link gutter-error "#e78284"
color-link gutter-warning "#e5c890"

color-link scrollbar "#949cbb"
color-link statusline "#c6d0f5,#292c3c"
color-link tabbar "#c6d0f5,#292c3c"
color-link indent-char "#51576d"
color-link line-number "#51576d"
color-link current-line-number "#babbf1"

color-link cursor-line "#414559,#c6d0f5"
color-link color-column "#414559"
color-link type.extended "default"
```

</details>

### `home/rizz404/micro/colorschemes/catppuccin-latte-transparent.micro`

SHA-256: `183af9e2651addb75cbe550aa21587114af569d0362c720ede8ffacb42fa7c2e`

<details>
<summary>Lihat isi lengkap</summary>

```text
color-link default "#4c4f69"
color-link comment "#7c7f93"
color-link selection "#4c4f69,#bcc0cc"
color-link hlsearch "#179299"

color-link identifier "#1e66f5"
color-link identifier.class "#1e66f5"
color-link identifier.var "#1e66f5"

color-link constant "#fe640b"
color-link constant.number "#fe640b"
color-link constant.string "#40a02b"

color-link symbol "#ea76cb"
color-link symbol.brackets "#dd7878"
color-link symbol.tag "#1e66f5"

color-link type "#1e66f5"
color-link type.keyword "#df8e1d"

color-link special "#ea76cb"
color-link statement "#8839ef"
color-link preproc "#ea76cb"

color-link underlined "#04a5e5"
color-link error "bold #d20f39"
color-link todo "bold #df8e1d"

color-link diff-added "#40a02b"
color-link diff-modified "#df8e1d"
color-link diff-deleted "#d20f39"

color-link gutter-error "#d20f39"
color-link gutter-warning "#df8e1d"

color-link scrollbar "#7c7f93"
color-link statusline "#4c4f69,#e6e9ef"
color-link tabbar "#4c4f69,#e6e9ef"
color-link indent-char "#bcc0cc"
color-link line-number "#bcc0cc"
color-link current-line-number "#7287fd"

color-link cursor-line "#ccd0da,#4c4f69"
color-link color-column "#ccd0da"
color-link type.extended "default"
```

</details>

### `home/rizz404/micro/colorschemes/catppuccin-macchiato-transparent.micro`

SHA-256: `83be61127e00ed44afd24bd59217721550a244f042bc63f91fc7cee7672c1a4c`

<details>
<summary>Lihat isi lengkap</summary>

```text
color-link default "#cad3f5"
color-link comment "#939ab7"
color-link selection "#cad3f5,#494d64"
color-link hlsearch "#8bd5ca"

color-link identifier "#8aadf4"
color-link identifier.class "#8aadf4"
color-link identifier.var "#8aadf4"

color-link constant "#f5a97f"
color-link constant.number "#f5a97f"
color-link constant.string "#a6da95"

color-link symbol "#f5bde6"
color-link symbol.brackets "#f0c6c6"
color-link symbol.tag "#8aadf4"

color-link type "#8aadf4"
color-link type.keyword "#eed49f"

color-link special "#f5bde6"
color-link statement "#c6a0f6"
color-link preproc "#f5bde6"

color-link underlined "#91d7e3"
color-link error "bold #ed8796"
color-link todo "bold #eed49f"

color-link diff-added "#a6da95"
color-link diff-modified "#eed49f"
color-link diff-deleted "#ed8796"

color-link gutter-error "#ed8796"
color-link gutter-warning "#eed49f"

color-link scrollbar "#939ab7"
color-link statusline "#cad3f5,#1e2030"
color-link tabbar "#cad3f5,#1e2030"
color-link indent-char "#494d64"
color-link line-number "#494d64"
color-link current-line-number "#b7bdf8"

color-link cursor-line "#363a4f,#cad3f5"
color-link color-column "#363a4f"
color-link type.extended "default"
```

</details>

### `home/rizz404/micro/colorschemes/catppuccin-mocha-transparent.micro`

SHA-256: `bf5ac2ae5d77a501956991f1907daa746f2d0d4c978d21fca22791e9e4cd106f`

<details>
<summary>Lihat isi lengkap</summary>

```text
color-link default "#cdd6f4"
color-link comment "#9399b2"
color-link selection "#cdd6f4,#45475a"
color-link hlsearch "#94e2d5"

color-link identifier "#89b4fa"
color-link identifier.class "#89b4fa"
color-link identifier.var "#89b4fa"

color-link constant "#fab387"
color-link constant.number "#fab387"
color-link constant.string "#a6e3a1"

color-link symbol "#f5c2e7"
color-link symbol.brackets "#f2cdcd"
color-link symbol.tag "#89b4fa"

color-link type "#89b4fa"
color-link type.keyword "#f9e2af"

color-link special "#f5c2e7"
color-link statement "#cba6f7"
color-link preproc "#f5c2e7"

color-link underlined "#89dceb"
color-link error "bold #f38ba8"
color-link todo "bold #f9e2af"

color-link diff-added "#a6e3a1"
color-link diff-modified "#f9e2af"
color-link diff-deleted "#f38ba8"

color-link gutter-error "#f38ba8"
color-link gutter-warning "#f9e2af"

color-link scrollbar "#9399b2"
color-link statusline "#cdd6f4,#181825"
color-link tabbar "#cdd6f4,#181825"
color-link indent-char "#45475a"
color-link line-number "#45475a"
color-link current-line-number "#b4befe"

color-link cursor-line "#313244,#cdd6f4"
color-link color-column "#313244"
color-link type.extended "default"
```

</details>

### `home/rizz404/micro/default.nix`

SHA-256: `0c13596a3a9baa73cdf7b399350deb898d602c2892b9d126f64b0d784f242017`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ pkgs, lib, ... }:

let
  fetchPlugin = { owner, repo, rev, hash, subdir ? null }:
    let src = pkgs.fetchFromGitHub {
      inherit owner repo rev hash;
      name = "micro-plugin-${repo}-src";
    };
    in if subdir == null then src else "${src}/${subdir}";

  plugins = {
    bookmark = fetchPlugin {
      owner = "haqk"; repo = "micro-bookmark";
      rev = "64acf8c7dfe67cfc61bf3ae6c5eeae5af5393a86";
      hash = "sha256-i6JkH0J3NsGl8wCoc1zroDsIuyUY4MnRZRGt8vnwX1c=";
    };
    editorconfig = fetchPlugin {
      owner = "10sr"; repo = "editorconfig-micro";
      rev = "892aa42b50e6f57a5065b6f4df8c4e0a3913c9ee";
      hash = "sha256-yZhM+zuyv5PlcD5tya6EzJbSx382HJNb9F5Kaj4tWNY=";
    };
    # NicolaiSoeborg/filemanager-plugin was never ported to micro's v2 Lua API
    # (still uses the old bare MakeCommand/messenger/CurView globals), so it
    # crashes on load with a recent micro. micro-editor/updated-plugins carries
    # a fixed fork that uses the current import("micro/...") API.
    filemanager = fetchPlugin {
      owner = "micro-editor"; repo = "updated-plugins";
      rev = "216ec3adaf3adec78665614402ece56cf60ae713";
      hash = "sha256-bYM+ZOxCbWDuN6/iWzRLxGrQr24Pe+WETRa9cXK076A=";
      subdir = "filemanager-plugin";
    };
    # Same story as filemanager: samdmarshall/micro-fzf-plugin targets the old
    # v1 API and errors on every micro startup ("fzf:27: attempt to call a
    # non-function object"). Use the ported version from the same fork above.
    fzf = fetchPlugin {
      owner = "micro-editor"; repo = "updated-plugins";
      rev = "216ec3adaf3adec78665614402ece56cf60ae713";
      hash = "sha256-bYM+ZOxCbWDuN6/iWzRLxGrQr24Pe+WETRa9cXK076A=";
      subdir = "fzf";
    };
    jump = fetchPlugin {
      owner = "terokarvinen"; repo = "micro-jump";
      rev = "344ca9daab30c2fa8849a0ca41966629147347b1";
      hash = "sha256-7od4rxijA8uOZDP7Go5Qa+88ZvKS6jERH1eYYKnwoac=";
    };
    lsp = fetchPlugin {
      owner = "AndCake"; repo = "micro-plugin-lsp";
      rev = "a3ed3a73b2f7576b1e2dc1ac3c98dfe695e6d05d";
      hash = "sha256-0an688Bc+ZtJ4JHqMfD8UAsCoKgQs6A+DRgfr1QpYG0=";
    };
    manipulator = fetchPlugin {
      owner = "NicolaiSoeborg"; repo = "manipulator-plugin";
      rev = "41ce0bebf29a6f36144dc9ecdd516a27b5b45b64";
      hash = "sha256-ucHOrZhmEVl+4J5q1vqytxrrMw6LXsoV7/nnAgdCQXo=";
    };
    quoter = fetchPlugin {
      owner = "deusnefum"; repo = "micro-quoter";
      rev = "31a8bc6b04755546d47984e6e1ab3dd5e6f0f24c";
      hash = "sha256-BX0Vj1ZVP7FlcG/4D7x1V0MmZ/IYNEmIcpcqubZLabQ=";
    };
    snippets = fetchPlugin {
      owner = "micro-editor"; repo = "updated-plugins";
      rev = "216ec3adaf3adec78665614402ece56cf60ae713";
      hash = "sha256-bYM+ZOxCbWDuN6/iWzRLxGrQr24Pe+WETRa9cXK076A=";
      subdir = "micro-snippets-plugin";
    };
    wc = fetchPlugin {
      owner = "adamnpeace"; repo = "micro-wc-plugin";
      rev = "b2c9957e521770eadc1ecae9d54c0a30f40a0a3d";
      hash = "sha256-Z6MC2cet8+7XHv41G+SlAZViCqlh/9dk0CSt7HklnTg=";
    };
  };

  catppuccinMicro = pkgs.fetchFromGitHub {
    owner = "catppuccin"; repo = "micro";
    rev = "015a2bb208f61a2d5a33121de2644bf4a059436b";
    hash = "sha256-XbhUwRz21/XLkdOb6VOqLwzxWtehf6qRms0YcepNQ0s=";
  };

  colorschemes = pkgs.runCommand "micro-colorschemes" { } ''
    mkdir -p $out
    cp -r ${catppuccinMicro}/themes/. $out/
    chmod -R u+w $out
    cp ${./colorschemes/catppuccin-latte-transparent.micro} $out/catppuccin-latte-transparent.micro
    cp ${./colorschemes/catppuccin-frappe-transparent.micro} $out/catppuccin-frappe-transparent.micro
    cp ${./colorschemes/catppuccin-macchiato-transparent.micro} $out/catppuccin-macchiato-transparent.micro
    cp ${./colorschemes/catppuccin-mocha-transparent.micro} $out/catppuccin-mocha-transparent.micro
  '';
in
{
  programs.micro = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./settings.json);
  };

  xdg.configFile =
    {
      "micro/bindings.json".source = ./bindings.json;
      "micro/colorschemes".source = colorschemes;
    }
    // lib.mapAttrs'
         (name: src: lib.nameValuePair "micro/plug/${name}" { source = src; })
         plugins;
}
```

</details>

### `home/rizz404/micro/settings.json`

SHA-256: `33ee147feeb3c16cd2cbdfdb10c2b7b326ca64ed45cfef293f9881b7a679d435`

<details>
<summary>Lihat isi lengkap</summary>

```json
{
  "autoclose": true,
  "autoindent": true,
  "clipboard": "external",
  "cursorline": true,
  "diffgutter": true,
  "hlsearch": true,
  "keepautoindent": true,
  "mkparents": true,
  "mouse": true,
  "rmtrailingws": true,
  "ruler": true,
  "savecursor": true,
  "saveundo": true,
  "scrollbar": true,
  "softwrap": true,
  "statusline": true,
  "tabmovement": true,
  "tabsize": 4,
  "tabstospaces": true,
  "wordwrap": true
}
```

</details>

### `home/rizz404/mpv/default.nix`

SHA-256: `05f7d4df25128f2956c26504dcc9d89f34dc103b64e1e31f9106b1b481f6efd9`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:
{
  xdg.configFile."mpv/mpv.conf".source = ./mpv.conf;
  xdg.configFile."mpv/input.conf".source = ./input.conf;
  xdg.configFile."mpv/scripts/autoload.lua".source = ./scripts/autoload.lua;
}
```

</details>

### `home/rizz404/mpv/input.conf`

SHA-256: `43e69a2d085b7618acbe7d2d9c844c4516a60b12f4bab39b7c9e25031ac2259e`

<details>
<summary>Lihat isi lengkap</summary>

```ini
ENTER cycle fullscreen
PGDWN playlist-next
PGUP playlist-prev
UP add volume 5
DOWN add volume -5
```

</details>

### `home/rizz404/mpv/mpv.conf`

SHA-256: `a4d7fb821209605589dc24cde5c2bb763f81b410db32dfb5af0eec4db6d8360a`

<details>
<summary>Lihat isi lengkap</summary>

```ini
# Ingat menit/detik terakhir saat aplikasi ditutup
save-position-on-quit=yes

# (Tambahan pintar) Kalau videonya ditutup saat udah bener-bener tamat, 
# memori posisinya nggak akan disimpan, jadi pas dibuka lagi langsung mulai dari awal
[eof-reached]
profile-cond=eof_reached
save-position-on-quit=no
# --- PENGATURAN WARNA & KUALITAS DEWA ---
profile=gpu-hq
video-output-levels=full
hwdec=auto-safe
```

</details>

### `home/rizz404/mpv/scripts/autoload.lua`

SHA-256: `c0ef5ac2c928f6a0d3464c14a403104968d7339cb1ed7cda642945f8420d8744`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-- This script automatically loads playlist entries before and after the
-- currently played file. It does so by scanning the directory a file is
-- located in when starting playback. It sorts the directory entries
-- alphabetically, and adds entries before and after the current file to
-- the internal playlist. (It stops if it would add an already existing
-- playlist entry at the same position - this makes it "stable".)
-- Add at most 5000 * 2 files when starting a file (before + after).

--[[
To configure this script use file autoload.conf in directory script-opts (the "script-opts"
directory must be in the mpv configuration directory, typically ~/.config/mpv/).

Option `ignore_patterns` is a comma-separated list of patterns (see lua.org/pil/20.2.html).
Additionally to the standard lua patterns, you can also escape commas with `%`,
for example, the option `bak%,x%,,another` will be resolved as patterns `bak,x,` and `another`.
But it does not mean you need to escape all lua patterns twice,
so the option `bak%%,%.mp4,` will be resolved as two patterns `bak%%` and `%.mp4`.

Example configuration would be:

disabled=no
images=no
videos=yes
audio=yes
additional_image_exts=list,of,ext
additional_video_exts=list,of,ext
additional_audio_exts=list,of,ext
ignore_hidden=yes
same_type=yes
directory_mode=recursive
ignore_patterns=^~,^bak-,%.bak$

--]]

local MAX_ENTRIES = 5000
local MAX_DIR_STACK = 20

local msg = require 'mp.msg'
local options = require 'mp.options'
local utils = require 'mp.utils'

local o = {
    disabled = false,
    images = true,
    videos = true,
    audio = true,
    additional_image_exts = "",
    additional_video_exts = "",
    additional_audio_exts = "",
    ignore_hidden = true,
    same_type = false,
    directory_mode = "auto",
    ignore_patterns = ""
}

local function Set(t)
    local set = {}
    for _, v in pairs(t) do set[v] = true end
    return set
end

local EXTENSIONS_VIDEO_DEFAULT = Set {
    '3g2', '3gp', 'avi', 'flv', 'm2ts', 'm4v', 'mj2', 'mkv', 'mov',
    'mp4', 'mpeg', 'mpg', 'ogv', 'rmvb', 'webm', 'wmv', 'y4m'
}

local EXTENSIONS_AUDIO_DEFAULT = Set {
    'aiff', 'ape', 'au', 'flac', 'm4a', 'mka', 'mp3', 'oga', 'ogg',
    'ogm', 'opus', 'wav', 'wma'
}

local EXTENSIONS_IMAGES_DEFAULT = Set {
    'avif', 'bmp', 'gif', 'j2k', 'jp2', 'jpeg', 'jpg', 'jxl', 'png',
    'svg', 'tga', 'tif', 'tiff', 'webp'
}

local EXTENSIONS, EXTENSIONS_VIDEO, EXTENSIONS_AUDIO, EXTENSIONS_IMAGES

local function SetUnion(a, b)
    for k in pairs(b) do a[k] = true end
    return a
end

-- Returns first and last positions in string or past-to-end indices
local function FindOrPastTheEnd(string, pattern, start_at)
    local pos1, pos2 = string:find(pattern, start_at)
    return pos1 or #string + 1,
           pos2 or #string + 1
end

local function Split(list)
    local set = {}

    local item_pos = 1
    local item = ""

    while item_pos <= #list do
        local pos1, pos2 = FindOrPastTheEnd(list, "%%*,", item_pos)

        local pattern_length = pos2 - pos1
        local is_comma_escaped = pattern_length % 2

        local pos_before_escape = pos1 - 1
        local item_escape_count = pattern_length - is_comma_escaped

        item = item .. string.sub(list, item_pos, pos_before_escape + item_escape_count)

        if is_comma_escaped == 1 then
            item = item .. ","
        else
            set[item] = true
            item = ""
        end

        item_pos = pos2 + 1
    end

    set[item] = true

    -- exclude empty items
    set[""] = nil

    return set
end

local function split_option_exts(video, audio, image)
    if video then o.additional_video_exts = Split(o.additional_video_exts) end
    if audio then o.additional_audio_exts = Split(o.additional_audio_exts) end
    if image then o.additional_image_exts = Split(o.additional_image_exts) end
end

local function split_patterns()
    o.ignore_patterns = Split(o.ignore_patterns)
end

local function create_extensions()
    EXTENSIONS = {}
    EXTENSIONS_VIDEO = {}
    EXTENSIONS_AUDIO = {}
    EXTENSIONS_IMAGES = {}
    if o.videos then
        SetUnion(SetUnion(EXTENSIONS_VIDEO, EXTENSIONS_VIDEO_DEFAULT), o.additional_video_exts)
        SetUnion(EXTENSIONS, EXTENSIONS_VIDEO)
    end
    if o.audio then
        SetUnion(SetUnion(EXTENSIONS_AUDIO, EXTENSIONS_AUDIO_DEFAULT), o.additional_audio_exts)
        SetUnion(EXTENSIONS, EXTENSIONS_AUDIO)
    end
    if o.images then
        SetUnion(SetUnion(EXTENSIONS_IMAGES, EXTENSIONS_IMAGES_DEFAULT), o.additional_image_exts)
        SetUnion(EXTENSIONS, EXTENSIONS_IMAGES)
    end
end

local function validate_directory_mode()
    if o.directory_mode ~= "recursive" and o.directory_mode ~= "lazy"
       and o.directory_mode ~= "ignore" then
        o.directory_mode = nil
    end
end

options.read_options(o, nil, function(list)
    split_option_exts(list.additional_video_exts, list.additional_audio_exts,
                      list.additional_image_exts)
    if list.videos or list.additional_video_exts or
        list.audio or list.additional_audio_exts or
        list.images or list.additional_image_exts then
        create_extensions()
    end
    if list.directory_mode then
        validate_directory_mode()
    end
    if list.ignore_patterns then
        split_patterns()
    end
end)

split_option_exts(true, true, true)
split_patterns()
create_extensions()
validate_directory_mode()

local function add_files(files)
    local oldcount = mp.get_property_number("playlist-count", 1)
    for i = 1, #files do
        mp.commandv("loadfile", files[i][1], "append")
        mp.commandv("playlist-move", oldcount + i - 1, files[i][2])
    end
end

local function get_extension(path)
    return path:match("%.([^%.]+)$") or "nomatch"
end

local function is_ignored(file)
    for pattern in pairs(o.ignore_patterns) do
        if file:match(pattern) then
            return true
        end
    end
    return false
end

-- alphanum sorting for humans in Lua
-- http://notebook.kulchenko.com/algorithms/alphanumeric-natural-sorting-for-humans-in-lua

local function alphanumsort(filenames)
    local function padnum(n, d)
        return #d > 0 and ("%03d%s%.12f"):format(#n, n, tonumber(d) / (10 ^ #d))
            or ("%03d%s"):format(#n, n)
    end

    local tuples = {}
    for i, f in ipairs(filenames) do
        tuples[i] = {f:lower():gsub("0*(%d+)%.?(%d*)", padnum), f}
    end
    table.sort(tuples, function(a, b)
        return a[1] == b[1] and #b[2] < #a[2] or a[1] < b[1]
    end)
    for i, tuple in ipairs(tuples) do filenames[i] = tuple[2] end
    return filenames
end

local autoloaded
local added_entries = {}
local autoloaded_dir

local function scan_dir(path, current_file, dir_mode, separator, dir_depth, total_files, extensions)
    if dir_depth == MAX_DIR_STACK then
        return
    end
    msg.trace("scanning: " .. path)
    local files = utils.readdir(path, "files") or {}
    local dirs = dir_mode ~= "ignore" and utils.readdir(path, "dirs") or {}
    local prefix = path == "." and "" or path

    local function filter(t, iter)
        for i = #t, 1, -1 do
            if not iter(t[i]) then
                table.remove(t, i)
            end
        end
    end

    filter(files, function(v)
        -- Always accept current file
        local current = prefix .. v == current_file
        if current then
            return true
        end
        if o.ignore_hidden and v:match("^%.") then
            return false
        end
        if is_ignored(v) then
            return false
        end

        local ext = get_extension(v)
        return ext and extensions[ext:lower()]
    end)
    filter(dirs, function(d)
        return not (o.ignore_hidden and d:match("^%."))
    end)
    alphanumsort(files)
    alphanumsort(dirs)

    for i, file in ipairs(files) do
        files[i] = prefix .. file
    end

    local function append(t1, t2)
        local t1_size = #t1
        for i = 1, #t2 do
            t1[t1_size + i] = t2[i]
        end
    end

    append(total_files, files)
    if dir_mode == "recursive" then
        for _, dir in ipairs(dirs) do
            scan_dir(prefix .. dir .. separator, current_file, dir_mode,
                     separator, dir_depth + 1, total_files, extensions)
        end
    else
        for i, dir in ipairs(dirs) do
            dirs[i] = prefix .. dir
        end
        append(total_files, dirs)
    end
end

local function find_and_add_entries()
    local aborted = mp.get_property_native("playback-abort")
    if aborted then
        msg.debug("stopping: playback aborted")
        return
    end

    local path = mp.get_property("path", "")
    local dir, filename = utils.split_path(path)
    msg.trace(("dir: %s, filename: %s"):format(dir, filename))
    if o.disabled then
        msg.debug("stopping: autoload disabled")
        return
    elseif #dir == 0 then
        msg.debug("stopping: not a local path")
        return
    end

    local pl_count = mp.get_property_number("playlist-count", 1)
    local this_ext = get_extension(filename)
    -- check if this is a manually made playlist
    if pl_count > 1 and autoloaded == nil then
        msg.debug("stopping: manually made playlist")
        return
    elseif pl_count == 1 then
        autoloaded = true
        autoloaded_dir = dir
        added_entries = {}
    end

    local extensions
    if o.same_type then
        if EXTENSIONS_VIDEO[this_ext:lower()] then
            extensions = EXTENSIONS_VIDEO
        elseif EXTENSIONS_AUDIO[this_ext:lower()] then
            extensions = EXTENSIONS_AUDIO
        elseif EXTENSIONS_IMAGES[this_ext:lower()] then
            extensions = EXTENSIONS_IMAGES
        end
    else
        extensions = EXTENSIONS
    end
    if not extensions then
        msg.debug("stopping: no matched extensions list")
        return
    end

    local pl = mp.get_property_native("playlist", {})
    local pl_current = mp.get_property_number("playlist-pos-1", 1)
    msg.trace(("playlist-pos-1: %s, playlist: %s"):format(pl_current,
        utils.to_string(pl)))

    local files = {}
    scan_dir(autoloaded_dir, path,
             o.directory_mode or mp.get_property("directory-mode", "lazy"),
             mp.get_property_native("platform") == "windows" and "\\" or "/",
             0, files, extensions)

    if next(files) == nil then
        msg.debug("no other files or directories in directory")
        return
    end

    -- Find the current pl entry (dir+"/"+filename) in the sorted dir list
    local current
    for i = 1, #files do
        if files[i] == path then
            current = i
            break
        end
    end
    if not current then
        msg.debug("current file not found in directory")
        return
    end
    msg.trace("current file position in files: "..current)

    -- treat already existing playlist entries, independent of how they got added
    -- as if they got added by autoload
    for _, entry in ipairs(pl) do
        added_entries[entry.filename] = true
    end

    -- stop initial file from being added twice
    added_entries[path] = true

    local append = {[-1] = {}, [1] = {}}
    for direction = -1, 1, 2 do -- 2 iterations, with direction = -1 and +1
        for i = 1, MAX_ENTRIES do
            local pos = current + i * direction
            local file = files[pos]
            if file == nil or file[1] == "." then
                break
            end

            -- skip files that are/were already in the playlist
            if not added_entries[file] then
                if direction == -1 then
                    msg.verbose("Prepending " .. file)
                    table.insert(append[-1], 1, {file, pl_current + i * direction + 1})
                else
                    msg.verbose("Adding " .. file)
                    if pl_count > 1 then
                        table.insert(append[1], {file, pl_current + i * direction - 1})
                    else
                        mp.commandv("loadfile", file, "append")
                    end
                end
                added_entries[file] = true
            end
        end
        if pl_count == 1 and direction == -1 and #append[-1] > 0 then
            local load = append[-1]
            for i = 1, #load do
                mp.commandv("loadfile", load[i][1], "append")
            end
            mp.commandv("playlist-move", 0, current)
        end
    end

    if pl_count > 1 then
        add_files(append[1])
        add_files(append[-1])
    end
end

mp.register_event("start-file", find_and_add_entries)
```

</details>

### `home/rizz404/noctalia/default.nix`

SHA-256: `b2cdfd885a5598075d9cc860b2839cfacca686c8a2bf99d258689429ffd60178`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ config, ... }:
let
  idlePowerScript = "${config.home.homeDirectory}/.config/noctalia/idle-power.sh";
  onColorsChangedScript = "${config.home.homeDirectory}/.config/noctalia/on-colors-changed.sh";
  stickerRandomScript = "${config.home.homeDirectory}/.config/noctalia/sticker-random.sh";
in
{
  programs.noctalia = {
    enable = true;
    # * Biar gak bentrok sama plasma, jadi kalo bukan hyprland di disable
    systemd.enable = false;

    settings = {
      shell = {
        font_family = "Maple Mono NF";
        # * Default (mru=false) urutin window ikut workspace/posisi, kerasa "acak"
        # * pas alt-tab. mru=true bikin urutannya ikut window yang terakhir
        # * dipakai duluan, kayak behavior Windows/KDE.
        window_switcher = {
          mru = true;
        };
        screenshot = {
          directory = "~/Pictures/Screenshots";
          show_cursor = true;
        };
      };

      theme = {
        mode = "auto";
        shell_mode = "auto";
        source = "wallpaper";
        builtin = "Catppuccin";
        community_palette = "Oxocarbon";
        wallpaper_scheme = "m3-content";
        templates = {
          enable_builtin_templates = true;
          # * hyprland = border window, wezterm = terminal, gtk3/gtk4/qt = app non-KDE,
          # * kcolorscheme = Dolphin & app KDE lain, btop = warna color_theme btop.conf
          # * starship SENGAJA gak dimasukin - starship.toml di-manage home-manager
          # * (symlink read-only ke /nix/store), template Noctalia gak bisa nulis ke situ
          builtin_ids = [ "hyprland" "wezterm" "gtk3" "gtk4" "qt" "kcolorscheme" "btop" ];

          enable_community_templates = true;
          # * vscode sengaja gak dipakai - settings.json-nya di-sync ke perangkat non-Linux juga
          # * micro SENGAJA gak dimasukin - colorschemes/ & settings.json micro juga
          # * symlink read-only ke /nix/store (sama kasusnya kayak starship di atas)
          community_ids = [
            "brave"
            "bat"
            "fastfetch"
            "fzf"
            "lazygit"
            "telegram"
            "zellij"
            "claude-code"
            "steam"
            "prismlauncher"
          ];

          # * Template custom buat theme SDDM noctalia-sync
          user.qylock-colors = {
            input_path = "${config.home.homeDirectory}/.config/noctalia/templates/qylock-colors.json.tmpl";
            output_path = "${config.home.homeDirectory}/.config/qylock/colors.json";
          };
        };
      };

      nightlight = {
        enabled = false;
      };

      # * Lockscreen native Noctalia - wallpaper & warna otomatis ikut wallpaper aktif
      lockscreen = {
        enabled = true;
        blurred_desktop = false;
        blur_intensity = 0.6;
        tint_intensity = 0.35;
      };

      location = {
        auto_locate = true;
      };

      # * Hooks untuk buat samain lockscreen sama sticker ketika wallpaper changed
      hooks = {
        colors_changed = onColorsChangedScript;
        wallpaper_changed = stickerRandomScript;
      };

      wallpaper = {
        directory = "~/Pictures/Wallpapers";
        transition = [ "wipe" ];
        transition_on_startup = true;
        automation = {
          enabled = true;
          interval_seconds = 3600;
        };
      };

      bar.default = {
        position = "top";
        enabled = true;
        thickness = 32;
        radius = 16;
        margin_ends = 0;
        margin_edge = 4;
        # * 0 = gak nambah reserved space ekstra selain gaps_out Hyprland (appearance.lua),
        # *  biar window bisa mepet bar tanpa dead-space dobel
        margin_opposite_edge = 0;
        background_opacity = 0.0;
        capsule = true;
        capsule_opacity = 0.55;

        start = [ "group:nav" ];
        center = [ "clock" ];
        end = [ "group:media" "group:sys" ];

        capsule_group = [
          {
            id = "nav";
            members = [ "launcher" "taskbar" ];
            fill = "surface_variant";
            opacity = 0.55;
          }
          {
            id = "media";
            members = [ "media" "notifications" ];
            fill = "surface_variant";
            opacity = 0.55;
          }
          {
            id = "sys";
            members = [ "network" "bluetooth" "volume" "battery" "tray" "control-center" ];
            fill = "primary";
            foreground = "on_primary";
            # * Dinaikin dari 0.55 - di opacity rendah, teks "on_primary" gampang ilang
            # * kontrasnya kalau primary hasil generate wallpaper kebetulan gelap/terang ekstrem
            opacity = 0.85;
          }
        ];
      };

      widget.clock = {
        format = "{:%H:%M} · {:%a, %d %b}";
        tooltip_format = "{:%A, %d %B %Y}";
      };

      widget.taskbar = {
        # * Fitur inti: kelompokin icon app per-workspace biar keliatan
        # * app apa aja yang jalan di tiap workspace, bukan cuma pill kosong
        group_by_workspace = true;
        workspace_group_content = "icons";
        group_single_icon_per_app = true; # * >1 window Discord di 1 workspace = 1 icon

        # * Tetep kompak - cuma tampilin workspace yang ada isinya. 10 workspace
        # * dari keybindings.lua gak bakal bikin taskbar selebar itu.
        hide_empty_workspaces = true;
        only_active_workspace = false; # * justru mau liat SEMUA workspace terisi

        show_workspace_label = true;
        workspace_label_placement = "corner";
        workspace_group_capsule = true; # * border/bg per-grup biar batas antar-workspace jelas

        show_all_outputs = false;
        focused_output_only = false;

        icon_scale = 0.9; # * dikit lebih kecil biar muat lebih banyak app
        show_active_indicator = true;
        active_indicator_color = "primary";
        active_opacity = 1.0;
        inactive_opacity = 0.75;

        focused_color = "primary";
        occupied_color = "on_surface";
        empty_color = "outline";
        urgent_color = "error";
      };

      # * Widget desktop diatur langsung di ~/.local/state/noctalia/settings.toml
      # * (lewat GUI editor atau edit manual), BUKAN di sini - biar gak perlu
      # * rebuild tiap kali mau ganti/geser widget. Lihat sticker-random.sh buat
      # * hook random gambar sticker-nya.
      desktop_widgets = {
        enabled = true;
      };

      notification = {
        background_opacity = 0.8;
        scale = 0.85;

        # * Notif "Screenshot saved" ilang lebih cepat, gak numpuk lama-lama di layar
        filter.screenshot = {
          enabled = true;
          match_content = "[Ss]creenshot";
          override_duration = 2500;
        };
      };

      osd = {
        background_opacity = 0.8;
        scale = 0.85;
        position = "bottom_center"; # * bar di top, OSD di bottom biar gak numpuk
      };

      idle = {
        pre_action_fade_seconds = 0;
        # * lock & screen-off DIGABUNG jadi satu behavior (bukan screenoff
        # * terpisah 30 detik setelah lock kayak dulu) - workaround bug upstream
        # * Noctalia (github.com/noctalia-dev/noctalia/issues/4190) yang bikin
        # * lockscreen muncul keliru nge-"resume" behavior lain yang udah
        # * kepicu duluan (layar jadi terang lagi alih-alih mati). Detail di
        # * idle-power.sh. Hapus workaround ini kalau upstream udah fix (PR #4002).
        behavior = {
          dim-ac = {
            enabled = true;
            timeout = 300; # 5 menit, saat di-charge
            action = "command";
            command = "${idlePowerScript} ac dim start";
            resume_command = "${idlePowerScript} ac dim resume";
          };
          lock-ac = {
            enabled = true;
            timeout = 870; # 14.5 menit, saat di-charge
            action = "command";
            command = "${idlePowerScript} ac lock start";
            resume_command = "${idlePowerScript} ac lock resume";
          };
          dim-battery = {
            enabled = true;
            timeout = 150; # 2.5 menit, saat pakai baterai
            action = "command";
            command = "${idlePowerScript} battery dim start";
            resume_command = "${idlePowerScript} battery dim resume";
          };
          lock-battery = {
            enabled = true;
            timeout = 570; # 9.5 menit, saat pakai baterai
            action = "command";
            command = "${idlePowerScript} battery lock start";
            resume_command = "${idlePowerScript} battery lock resume";
          };
        };
      };
    };
  };

  wayland.windowManager.hyprland.extraConfig = builtins.readFile ./noctalia.lua;

  xdg.configFile = {
    "hypr/modules/noctalia/autostart.lua".source = ./modules/autostart.lua;
    "hypr/modules/noctalia/keybindings.lua".source = ./modules/keybindings.lua;
    "hypr/modules/noctalia/rules.lua".source = ./modules/rules.lua;
    "hypr/modules/noctalia/theme.lua".source = ./modules/theme.lua;

    "noctalia/idle-power.sh" = {
      source = ./idle-power.sh;
      executable = true;
    };

    "noctalia/on-colors-changed.sh" = {
      source = ./on-colors-changed.sh;
      executable = true;
    };

    "noctalia/sticker-random.sh" = {
      source = ./sticker-random.sh;
      executable = true;
    };

    "noctalia/templates/qylock-colors.json.tmpl".source = ./qylock-colors.json.tmpl;
  };
}
```

</details>

### `home/rizz404/noctalia/idle-power.sh`

SHA-256: `2d054945a49f3fe04084d15188b90c0aa7d8c4053dcf53972fe3c86e38aa1d0b`

<details>
<summary>Lihat isi lengkap</summary>

```bash
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
```

</details>

### `home/rizz404/noctalia/modules/autostart.lua`

SHA-256: `ade87ce4cca36d828e3d71381dd2112851b530af4a68d708a40bff9b8dabeeb0`

<details>
<summary>Lihat isi lengkap</summary>

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
end)
```

</details>

### `home/rizz404/noctalia/modules/keybindings.lua`

SHA-256: `5e7c925e552ad67d003c2cec8c70dffbda0a09427a010044aefbeeb0349a4397`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-- * Keybindings lebih bervariasi jadi gak usah pakai variable
local ipc = "noctalia msg "

hl.bind("ALT + Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind("SUPER + Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind("SUPER + N", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind("SUPER + comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind("SUPER + L", hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))
hl.bind("Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd(ipc .. "screenshot-annotate"))
hl.bind("SUPER + V", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
hl.bind("SUPER + W", hl.dsp.exec_cmd(ipc .. "wallpaper-next"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(ipc .. "wallpaper-previous"))
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd(ipc .. "wallpaper-random"))
hl.bind("SUPER + CTRL + W",
    hl.dsp.exec_cmd([[sh -c 'noctalia msg notification-show "Wallpaper" "$(noctalia msg wallpaper-get)"']]))
```

</details>

### `home/rizz404/noctalia/modules/rules.lua`

SHA-256: `15608ebec0c933016498fa3e4e479e97072fb12043b4826e65184aa6d208e72e`

<details>
<summary>Lihat isi lengkap</summary>

```lua
hl.window_rule({
    match = {
        class = "dev.noctalia.Noctalia"
    },
    float = true,
    size = {1080, 920}
})

hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$"
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true
})
```

</details>

### `home/rizz404/noctalia/modules/theme.lua`

SHA-256: `5226dba36ad101b18b264c34ea952a0381b892a8c99b6e7e07a3e2b59ad4d6de`

<details>
<summary>Lihat isi lengkap</summary>

```lua
require("noctalia").apply_theme()
```

</details>

### `home/rizz404/noctalia/noctalia.lua`

SHA-256: `33b3b4bb35c953079e5c3e6431dc130d774d443e02d654709f6604f6facd6ef5`

<details>
<summary>Lihat isi lengkap</summary>

```lua
-- Entry point config Noctalia (Lua). Tiap section dipecah ke modules/,
-- di-import di sini pakai require(), lihat https://wiki.hypr.land/Configuring/Start/
-- Path modul di-symlink oleh home-manager (lihat default.nix -> xdg.configFile),
-- rooted di ~/.config/hypr, jadi "modules.noctalia.xxx" -> modules/noctalia/xxx.lua
--
-- * general/decoration (gaps, rounding, blur) SENGAJA gak di-set di sini.
--   Itu semua udah dikontrol penuh dari hyprland/modules/appearance.lua biar
--   cuma ada SATU sumber, gak ada dua file yang rebutan nimpa key yang sama.
require("modules.noctalia.autostart")
require("modules.noctalia.keybindings")
require("modules.noctalia.rules")
require("modules.noctalia.theme")
```

</details>

### `home/rizz404/noctalia/on-colors-changed.sh`

SHA-256: `e420e2cf8770c447aa6aadf41f4e149ceeb04e696aa49f35c94d033bdd15954a`

<details>
<summary>Lihat isi lengkap</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

# * Workaround bug casing di template kcolorscheme Noctalia - lihat komentar
#   theme.hooks.colors_changed di default.nix.
plasma-apply-colorscheme noctalia

# * Ekspor path wallpaper aktif ke ~/.config/qylock/wallpaper.txt biar theme
#   login screen (SDDM, lihat ~/qylock/themes/noctalia-sync) bisa nunjukin
#   wallpaper yang sama kayak yang lagi aktif di desktop.
state_file="$HOME/.local/state/noctalia/settings.toml"
out_dir="$HOME/.config/qylock"
mkdir -p "$out_dir"
awk '
  /^\[wallpaper\.last\]/ { in_section = 1; next }
  /^\[/ { in_section = 0 }
  in_section && /^path/ { gsub(/^path *= *"|"$/, ""); print; exit }
' "$state_file" > "$out_dir/wallpaper.txt"
```

</details>

### `home/rizz404/noctalia/qylock-colors.json.tmpl`

SHA-256: `4ef8aadcdc1cc6a15cf04c66b1b04c39c8e49d9fffd00d170a066d96d29d8023`

<details>
<summary>Lihat isi lengkap</summary>

```ini
{
  "primary": "#{{colors.primary.default.hex_stripped}}",
  "on_primary": "#{{colors.on_primary.default.hex_stripped}}",
  "secondary": "#{{colors.secondary.default.hex_stripped}}",
  "on_secondary": "#{{colors.on_secondary.default.hex_stripped}}",
  "surface": "#{{colors.surface.default.hex_stripped}}",
  "on_surface": "#{{colors.on_surface.default.hex_stripped}}",
  "error": "#{{colors.error.default.hex_stripped}}",
  "on_error": "#{{colors.on_error.default.hex_stripped}}"
}
```

</details>

### `home/rizz404/noctalia/sticker-random.sh`

SHA-256: `ebe763f80601708f61a6877f9ef9befef08f1eb8f2b8a7df852ab0c48edf9753`

<details>
<summary>Lihat isi lengkap</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

# * Dipanggil sebagai hooks.wallpaper_changed (lihat default.nix) - jalan tiap
#   wallpaper ganti, baik otomatis (wallpaper.automation) maupun manual lewat
#   keybinding (SUPER+W / SHIFT+W / ALT+W di modules/keybindings.lua).
#
# * Widget desktop diatur manual lewat GUI/settings.toml (bukan Nix), jadi ID
#   sticker-nya di-discover dari settings.toml langsung - bisa berapa aja,
#   nama apa aja, gak perlu tau ID-nya di awal.
#
# * Tiap sticker widget dapet gambar random independen (di-shuffle bareng biar
#   antar-sticker gak kebagian gambar yang sama selama jumlah gambar >= jumlah
#   sticker widget).
state_file="$HOME/.local/state/noctalia/settings.toml"
sticker_dir="$HOME/Pictures/Liked Images Square"

[[ -d "$sticker_dir" && -f "$state_file" ]] || exit 0

mapfile -t sticker_ids < <(awk '
  match($0, /^[ \t]*\[desktop_widgets\.widget\.([A-Za-z0-9_-]+)\]$/, arr) { cur = arr[1]; next }
  /^[ \t]*\[/ { cur = "" }
  cur != "" && $0 ~ /^[ \t]*type[ \t]*=[ \t]*"sticker"$/ { print cur; cur = "" }
' "$state_file" | sort -u)
(( ${#sticker_ids[@]} > 0 )) || exit 0

mapfile -t images < <(find "$sticker_dir" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) | shuf)
(( ${#images[@]} > 0 )) || exit 0

upsert_sticker_image() {
  local id="$1" escaped="$2"
  local header="[desktop_widgets.widget.${id}.settings]"
  local tmp
  tmp="$(mktemp "$(dirname "$state_file")/.sticker-random.XXXXXX")"
  awk -v header="$header" -v newpath="$escaped" '
    BEGIN { in_target = 0; found_header = 0; wrote_path = 0 }
    {
      line = $0
      # Cocokin substring, bukan persis - entry-nya berindentasi (nested under
      # [desktop_widgets.widget.<id>]) sedangkan header di sini flat.
      if (index(line, header) > 0) {
        in_target = 1; found_header = 1
        print line
        next
      }
      if (in_target && line ~ /^[ \t]*\[/) {
        if (!wrote_path) { print "        image_path = \"" newpath "\""; wrote_path = 1 }
        in_target = 0
      }
      if (in_target && line ~ /^[ \t]*image_path[ \t]*=/) {
        sub(/=.*/, "= \"" newpath "\"", line)
        wrote_path = 1
      }
      print line
    }
    END {
      if (in_target && !wrote_path) { print "        image_path = \"" newpath "\"" }
      if (!found_header) {
        print ""
        print header
        print "image_path = \"" newpath "\""
      }
    }
  ' "$state_file" > "$tmp" && mv "$tmp" "$state_file"
}

n=${#images[@]}
i=0
for id in "${sticker_ids[@]}"; do
  picked="${images[i % n]}"
  i=$((i + 1))

  # Escape backslash & double-quote biar valid sebagai TOML basic string
  escaped=${picked//\\/\\\\}
  escaped=${escaped//\"/\\\"}

  upsert_sticker_image "$id" "$escaped"
done
```

</details>

### `home/rizz404/starship/default.nix`

SHA-256: `0c8c0248e13a6d6ac8ab971033e6f897d3bf2e9db2c2dc1503ad230255888c20`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:
{
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };
}
```

</details>

### `home/rizz404/starship/starship.toml`

SHA-256: `f6143639e237c854b201991e6e9071a94de88a5003d2dcfe986e4c31b57f3e9b`

<details>
<summary>Lihat isi lengkap</summary>

```toml
"$schema" = 'https://starship.rs/config-schema.json'

add_newline = true
command_timeout = 5000

# Ini mengatur urutan apa saja yang mau ditampilkan
format = """
[╭─ ](bold blue)$os$directory$git_branch$git_status$all
[╰─](bold blue)$character"""

[character]
success_symbol = "[>](bold green)"
error_symbol = "[x](bold red)"
vimcmd_symbol = "[<](bold yellow)"

[os]
disabled = false

[directory]
style = "bold cyan"
truncation_length = 3
truncation_symbol = ".../"
read_only = " 󰌾"

[git_branch]
style = "bold purple"

[git_status]
style = "bold red"

[aws]
symbol = " "

[buf]
symbol = " "

[bun]
symbol = " "

[c]
symbol = " "

[cpp]
symbol = " "

[cmake]
symbol = " "

[conda]
symbol = " "

[crystal]
symbol = " "

[dart]
symbol = " "

[deno]
symbol = " "

[docker_context]
symbol = " "

[elixir]
symbol = " "

[elm]
symbol = " "

[fennel]
symbol = " "

[fortran]
symbol = " "

[fossil_branch]
symbol = " "

[gcloud]
symbol = " "

[git_commit]
tag_symbol = '  '

[golang]
symbol = " "

[gradle]
symbol = " "

[guix_shell]
symbol = " "

[haskell]
symbol = " "

[haxe]
symbol = " "

[hg_branch]
symbol = " "

[hostname]
ssh_symbol = " "

[java]
symbol = " "

[julia]
symbol = " "

[kotlin]
symbol = " "

[lua]
symbol = " "

[memory_usage]
symbol = "󰍛 "

[meson]
symbol = "󰔷 "

[nim]
symbol = "󰆥 "

[nix_shell]
symbol = " "

[nodejs]
symbol = " "

[ocaml]
symbol = " "

[os.symbols]
Alpaquita = " "
Alpine = " "
AlmaLinux = " "
Amazon = " "
Android = " "
AOSC = " "
Arch = " "
Artix = " "
CachyOS = " "
CentOS = " "
Debian = " "
DragonFly = " "
Elementary = " "
Emscripten = " "
EndeavourOS = " "
Fedora = " "
FreeBSD = " "
Garuda = "󰛓 "
Gentoo = " "
HardenedBSD = "󰞌 "
Illumos = "󰈸 "
Ios = "󰀷 "
Kali = " "
Linux = " "
Mabox = " "
Macos = " "
Manjaro = " "
Mariner = " "
MidnightBSD = " "
Mint = " "
NetBSD = " "
NixOS = " "
Nobara = " "
OpenBSD = "󰈺 "
openSUSE = " "
OracleLinux = "󰌷 "
Pop = " "
Raspbian = " "
Redhat = " "
RedHatEnterprise = " "
RockyLinux = " "
Redox = "󰀘 "
Solus = "󰠳 "
SUSE = " "
Ubuntu = " "
Unknown = " "
Void = " "
Windows = "󰍲 "
Zorin = " "

[package]
symbol = "󰏗 "
format = "is [$symbol$version]($style) "
disabled = true

[perl]
symbol = " "

[php]
symbol = " "

[pijul_channel]
symbol = " "

[pixi]
symbol = "󰏗 "

[python]
symbol = " "

[rlang]
symbol = "󰟔 "

[ruby]
symbol = " "

[rust]
symbol = "󱘗 "

[scala]
symbol = " "

[status]
symbol = " "

[swift]
symbol = " "

[xmake]
symbol = " "

[zig]
symbol = " "
```

</details>

### `home/rizz404/udiskie/default.nix`

SHA-256: `1cb753d4df7b1057f24b13f6f8cf0753cbd047f7f741a6e6b3f2d74dfb9ec30b`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:{
  services.udiskie = {
    enable = true;
    automount = true;  # * auto-mount pas USB dicolok
    notify = true;      # * notifikasi popup pas device masuk/keluar
    tray = "auto";    # * "auto" = ikon cuma nongol kalau ada device, "always" = selalu ada
  };
}
```

</details>

### `home/rizz404/wezterm/default.nix`

SHA-256: `aca7f0fd61f8ebbb9713859a16e1c63523688b932f4d827f36170ef41e5e3eb6`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ ... }:
{
  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
}
```

</details>

### `home/rizz404/wezterm/wezterm.lua`

SHA-256: `b3b7795892bb7b45ee3228a105224fbaa89aa2650b5616b00b6ce2a1c87f26d3`

<details>
<summary>Lihat isi lengkap</summary>

```lua
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- config.color_scheme = 'nord'
-- config.window_background_image = '/home/rizz404/Pictures/Wallpapers/miku-monitoring.png'
-- Memanipulasi HSB untuk meredupkan gambar latar agar teks tetap terbaca
-- config.window_background_image_hsb = {
--   -- Mengurangi kecerahan gambar menjadi 10%
--   brightness = 0.05,
--   
--   -- Mempertahankan rona warna dan saturasi asli
--   hue = 1.0,
--   saturation = 1.0,
-- }

-- Dimensi grid viewport (Akan stabil selama font dirender secara eksplisit)
config.initial_cols = 116
config.initial_rows = 32

-- Konfigurasi tipografi
-- Pastikan paket font (misal: ttf-firacode-nerd) sudah terinstal di CachyOS Anda
config.font = wezterm.font('FiraCode Nerd Font')
config.font_size = 10.0

-- Modifikasi visual kursor
-- Nilai 'BlinkingBar' untuk garis berkedip, gunakan 'SteadyBar' untuk garis statis
config.default_cursor_style = 'BlinkingBar'
config.animation_fps = 1
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- Menyembunyikan tab bar secara dinamis jika tidak ada tab sekunder yang aktif
config.hide_tab_bar_if_only_one_tab = true

-- Transparansi window biar wallpaper keliatan nembus (Hyprland blur udah aktif di
-- decoration.blur, otomatis nge-blur belakang window ini juga)
config.window_background_opacity = 0.85

-- Scrollbar tipis di kanan, aktif kalau ada scrollback
config.enable_scroll_bar = true

-- Menghapus dekorasi jendela bawaan (title bar) namun mempertahankan fungsionalitas resize
-- config.window_decorations = 'RESIZE'

-- * Noctalia nulis skema warna ke ~/.config/wezterm/colors/Noctalia.toml tiap tema berubah
--   (lihat docs/noctalia-ricing-guide.md section 8). wezterm.lua ini symlink read-only ke Nix
--   store jadi auto-insert-nya Noctalia gagal nulis - baris ini ditambahin manual sebagai gantinya.
config.color_scheme = 'Noctalia'

-- Keybindings tambahan (di luar default bawaan WezTerm, lihat
-- https://wezterm.org/config/default-keys.html untuk daftar lengkapnya --
-- copy/paste/tab-switching/dst udah dihandle default, gak perlu di-define ulang)
--
-- * Modifier dipisah per "domain" biar selaras & gak tabrakan sama Hyprland/
--   Noctalia (lihat home/rizz404/hyprland & home/rizz404/noctalia):
--   SUPER      = window manager & shell (Hyprland + Noctalia)
--   CTRL+ALT   = jalanin aplikasi (CTRL+ALT+T buka terminal ini di Hyprland)
--   CTRL+SHIFT = shortcut internal WezTerm (namespace default WezTerm sendiri)
config.keys = {
  -- Select all: WezTerm gak punya action "select all" bawaan, jadi masuk
  -- copy mode, pilih dari baris paling atas scrollback sampai paling bawah,
  -- copy ke clipboard, lalu langsung keluar copy mode lagi
  {
    key = 'A',
    mods = 'CTRL|SHIFT',
    action = act.Multiple {
      act.ActivateCopyMode,
      { CopyMode = 'MoveToScrollbackTop' },
      { CopyMode = { SetSelectionMode = 'Line' } },
      { CopyMode = 'MoveToScrollbackBottom' },
      act.CopyTo 'ClipboardAndPrimarySelection',
      { CopyMode = 'Close' },
    },
  },

  -- Split pane lebih ergonomis dibanding default (CTRL+SHIFT+ALT+" / %) --
  -- "\" kebayang garis vertikal (split ke samping), "-" garis horizontal
  -- (split ke bawah)
  {
    key = '\\',
    mods = 'CTRL|SHIFT',
    action = act.SplitPane { direction = 'Right' },
  },
  {
    key = '-',
    mods = 'CTRL|SHIFT',
    action = act.SplitPane { direction = 'Down' },
  },

  -- Tutup pane aktif aja (bukan seluruh tab) -- konsisten sama konvensi
  -- "Q = close" punya Hyprland (SUPER+Q nutup window)
  {
    key = 'Q',
    mods = 'CTRL|SHIFT',
    action = act.CloseCurrentPane { confirm = true },
  },
}

return config
```

</details>

### `pkgs/ab-download-manager.nix`

SHA-256: `f0d219c1df8c1a236607193c2f710dfb84e8c32f8b8d6758d0fb8965f7f64491`

<details>
<summary>Lihat isi lengkap</summary>

```nix
{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, alsa-lib
, dbus
, fontconfig
, freetype
, libglvnd
, libappindicator-gtk3
, wayland
, libxkbcommon
, libX11
, libXext
, libXi
, libXrender
, libxtst
, zlib
}:

# AB Download Manager gak ada di nixpkgs, jadi di-package manual dari rilis binary
# resminya (jpackage app-image, udah bawa JRE sendiri di lib/runtime).
# Referensi struktur & runtime deps: AUR package "ab-download-manager-bin"
# https://aur.archlinux.org/packages/ab-download-manager-bin
stdenv.mkDerivation (finalAttrs: {
  pname = "ab-download-manager";
  version = "1.10.4";

  src = fetchurl {
    url = "https://github.com/amir1376/ab-download-manager/releases/download/v${finalAttrs.version}/ABDownloadManager_${finalAttrs.version}_linux_x64.tar.gz";
    hash = "sha256-X5O7qI5WuHKvVbuOGWXZAovkqIhhmwxJswQoEysfwWk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    fontconfig
    freetype
    libglvnd
    libappindicator-gtk3
    wayland
    libxkbcommon
    libX11
    libXext
    libXi
    libXrender
    libxtst
    zlib
  ];

  # jangan di-strip, ini app-image hasil jpackage (native launcher + JRE bundel)
  dontStrip = true;

  desktopItems = [
    (makeDesktopItem {
      name = "com.abdownloadmanager.desktop";
      desktopName = "AB Download Manager";
      comment = "Manage and organize your download files better than before";
      genericName = "Download Manager";
      exec = "ABDownloadManager";
      icon = "ABDownloadManager";
      terminal = false;
      categories = [ "Network" "Utility" ];
      startupWMClass = "com-abdownloadmanager-desktop-AppKt";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/ab-download-manager $out/bin $out/share/pixmaps
    cp -r bin lib $out/opt/ab-download-manager/
    install -Dm644 $out/opt/ab-download-manager/lib/ABDownloadManager.png \
      $out/share/pixmaps/ABDownloadManager.png

    # SKIKO_RENDER_API=SOFTWARE = default upstream (AUR) buat hindarin crash/glitch
    # render OpenGL Compose Desktop di banyak setup Linux; masih bisa dioverride
    # user via env var karena pakai --set-default.
    # libfontconfig, libdbus & libappindicator di-dlopen runtime (bukan NEEDED
    # ELF), jadi autoPatchelfHook gak bisa nemuin walau udah di buildInputs ->
    # taro di LD_LIBRARY_PATH manual. Tanpa fontconfig: JVM error "Fontconfig
    # head is null". Tanpa dbus: crash pas load native theme lib nucleus.
    for exe in ABDownloadManager ABDownloadManagerCli ABDownloadManagerNativeMessagingHost; do
      makeWrapper $out/opt/ab-download-manager/bin/$exe $out/bin/$exe \
        --set-default SKIKO_RENDER_API SOFTWARE \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ fontconfig.lib dbus.lib libappindicator-gtk3 ]}"
    done

    runHook postInstall
  '';

  meta = {
    description = "Download manager (HTTP/HTTPS/FTP), multi-connection & resumable, mirip IDM";
    homepage = "https://abdownloadmanager.com/";
    changelog = "https://github.com/amir1376/ab-download-manager/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "ABDownloadManager";
    maintainers = [ ];
  };
})
```

</details>

### `~/qylock/themes/noctalia-sync/Main.qml`

SHA-256: `10e516a277fd3649120d0d49054c73a346f493ac3759f0406f8770b78dce8280`

<details>
<summary>Lihat isi lengkap</summary>

```qml
import QtQuick
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import SddmComponents 2.0

// Login screen custom - niru visual lockscreen native Noctalia (blur+tint di
// atas wallpaper aktif) biar login screen & lockscreen keliatan 1 tema utuh.
// Sumber data: ~/.config/qylock/{colors.json,wallpaper.txt}, di-generate
// Noctalia lewat hook colors_changed (lihat home/rizz404/noctalia/default.nix).
Rectangle {
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.ArrowCursor
        z: -1
    }
    id: root
    width: Screen.width; height: Screen.height
    readonly property real s: height / 768
    color: "#1a1a1a"

    // Palette - default netral, di-override loadNoctaliaColors()
    property color cText:   "#f0f0f0"
    property color cSub:    "#c0c0c0"
    property color cAccent: "#8ab4f8"
    property color cGlass:  "#40000000"
    property color cTint:   "#000000"

    property url bgSource: ""

    property int sessionIndex: (typeof sessionModel !== "undefined" && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0
    property int userIndex: (typeof userModel !== "undefined" && userModel.lastIndex >= 0) ? userModel.lastIndex : 0
    property real ui: 0

    FolderListModel { id: fontFolder; folder: Qt.resolvedUrl("font"); nameFilters: ["*.ttf", "*.otf"] }
    FontLoader { id: mainFont; source: fontFolder.count > 0 ? "font/" + fontFolder.get(0, "fileName") : "" }
    TextConstants { id: textConstants }

    ListView { id: sessionHelper; model: typeof sessionModel !== "undefined" ? sessionModel : null; currentIndex: root.sessionIndex; opacity: 0; width: 1; height: 1; delegate: Item { property string sName: model.name || "" } }
    ListView { id: userHelper; model: typeof userModel !== "undefined" ? userModel : null; currentIndex: root.userIndex; opacity: 0; width: 1; height: 1; delegate: Item { property string uName: model.realName || model.name || ""; property string uLogin: model.name || "" } }

    Timer { interval: 300; running: true; onTriggered: pwd.forceActiveFocus() }
    Component.onCompleted: {
        fadeAnim.start(); keyboard.numLock = true
        loadNoctaliaColors()
        loadCurrentWallpaper()
    }
    NumberAnimation { id: fadeAnim; target: root; property: "ui"; from: 0; to: 1; duration: 1200; easing.type: Easing.OutCubic }

    function loadNoctaliaColors() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file:///home/rizz404/.config/qylock/colors.json")
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status !== 200 && xhr.status !== 0) return
            try {
                var c = JSON.parse(xhr.responseText)
                if (c.on_surface) root.cText = c.on_surface
                if (c.secondary) root.cSub = c.secondary
                if (c.primary) root.cAccent = c.primary
                if (c.surface) {
                    root.cGlass = "#40" + c.surface.replace("#", "")
                    root.cTint = c.surface
                }
            } catch (e) {}
        }
        xhr.send()
    }

    function loadCurrentWallpaper() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file:///home/rizz404/.config/qylock/wallpaper.txt")
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status !== 200 && xhr.status !== 0) return
            var path = xhr.responseText.trim()
            if (path.length > 0) root.bgSource = "file://" + path
        }
        xhr.send()
    }

    // Wallpaper - disembunyiin, cuma dipakai sebagai sumber buat FastBlur di bawah
    Image {
        id: bgImage
        anchors.fill: parent
        source: root.bgSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
    }

    FastBlur {
        anchors.fill: bgImage
        source: bgImage
        radius: 64
        visible: root.bgSource.toString().length > 0
    }

    // Tint - samain intensitasnya sama tint_intensity lockscreen Noctalia (0.35)
    Rectangle {
        anchors.fill: parent
        color: root.cTint
        opacity: 0.35
    }

    // Shadow buat fade-in awal
    Rectangle {
        anchors.fill: parent; visible: root.ui < 1.0; opacity: 1.0 - root.ui; color: "#1a1a1a"; z: 100
    }

    // Clock
    Item {
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 80 * s; height: 120 * s; opacity: root.ui

        Column {
            anchors.horizontalCenter: parent.horizontalCenter; spacing: -6 * s
            Text {
                id: clockText; text: Qt.formatTime(new Date(), "HH:mm")
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.cText; font.family: mainFont.name; font.pixelSize: 88 * s
                Timer { interval: 1000; running: true; repeat: true; onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm") }
            }
            Text {
                text: Qt.formatDate(new Date(), "dddd, d MMMM")
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.cSub; font.family: mainFont.name; font.pixelSize: 18 * s
            }
        }
    }

    // Login
    Item {
        anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 90 * s; width: 320 * s; height: loginCol.height; opacity: root.ui

        Column {
            id: loginCol; width: parent.width; spacing: 16 * s

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: (userHelper.currentItem && userHelper.currentItem.uName) ? userHelper.currentItem.uName : (typeof userModel !== "undefined" ? userModel.lastUser : "user")
                color: root.cText; font.family: mainFont.name; font.pixelSize: 16 * s; font.letterSpacing: 2 * s
                MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { if (typeof userModel !== "undefined") root.userIndex = (root.userIndex + 1) % userModel.rowCount() } }
            }

            Rectangle {
                width: parent.width; height: 44 * s; radius: 22 * s; color: root.cGlass
                border.color: pwd.activeFocus ? root.cAccent : "transparent"; border.width: 1.5 * s
                Behavior on border.color { ColorAnimation { duration: 300 } }

                TextInput {
                    id: pwd; anchors.fill: parent; anchors.leftMargin: 20 * s; anchors.rightMargin: 20 * s
                    horizontalAlignment: TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password; passwordCharacter: "•"; color: root.cText
                    font.family: mainFont.name; font.pixelSize: 18 * s; font.letterSpacing: 6 * s
                    focus: true; clip: true; cursorVisible: false; cursorDelegate: Item { width: 0; height: 0 }
                    onAccepted: doLogin()

                    Text {
                        anchors.centerIn: parent; text: "password"; color: root.cSub; opacity: pwd.text.length === 0 ? 0.6 : 0
                        font.family: mainFont.name; font.pixelSize: 14 * s
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.ArrowCursor; onClicked: pwd.forceActiveFocus() }
            }

            Text {
                id: errorMsg; anchors.horizontalCenter: parent.horizontalCenter
                text: ""; color: "#e57373"; font.family: mainFont.name; font.pixelSize: 12 * s
                visible: text !== ""
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter; spacing: 28 * s
                Repeater {
                    model: [
                        { l: "SESSION", a: 0 },
                        { l: "REBOOT", a: 1 },
                        { l: "POWER", a: 2 }
                    ]
                    delegate: Text {
                        text: (modelData.a === 0 && sessionHelper.currentItem) ? sessionHelper.currentItem.sName.toUpperCase() : modelData.l
                        color: actMa.containsMouse ? root.cAccent : root.cSub; font.family: mainFont.name; font.pixelSize: 11 * s; font.letterSpacing: 2 * s
                        MouseArea {
                            id: actMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.a === 0) { if (typeof sessionModel !== "undefined") root.sessionIndex = (root.sessionIndex + 1) % sessionModel.rowCount() }
                                else if (modelData.a === 1) { if (typeof sddm !== "undefined") sddm.reboot() }
                                else if (modelData.a === 2) { if (typeof sddm !== "undefined") sddm.powerOff() }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: typeof sddm !== "undefined" ? sddm : null
        function onLoginFailed() { errorMsg.text = "access denied"; pwd.text = ""; pwd.focus = true }
    }

    function doLogin() {
        var u = (userHelper.currentItem && userHelper.currentItem.uLogin) ? userHelper.currentItem.uLogin : (typeof userModel !== "undefined" ? userModel.lastUser : "")
        if (typeof sddm !== "undefined") sddm.login(u, pwd.text, root.sessionIndex)
    }
}
```

</details>

### `~/qylock/themes/noctalia-sync/metadata.desktop`

SHA-256: `39e8d032ee25be1d224a3b3e5f97fb1573b5547d55c1048761e766e37bdb68df`

<details>
<summary>Lihat isi lengkap</summary>

```ini
[SddmGreeterTheme]
Name=noctalia-sync
Description=Blur+tint minimal, ikut wallpaper & warna Noctalia aktif
Author=rizz404
Type=sddm-theme
MainScript=Main.qml
ConfigFile=theme.conf
QtVersion=6
```

</details>

### `~/qylock/themes/noctalia-sync/theme.conf`

SHA-256: `ac6af85ac0cd7fa17882c8c0530ec5ae15c4e60007fb807e69127e9c94451c3c`

<details>
<summary>Lihat isi lengkap</summary>

```ini
[General]
font=Itim
themeMode=dark
```

</details>

## 13. Referensi

- [Paket Arch Linux](https://archlinux.org/packages/) dan [database mirror](https://geo.mirror.pkgbuild.com/).
- [Paket CachyOS](https://packages.cachyos.org/) dan [database mirror resmi](https://cdn77.cachyos.org/repo/x86_64/cachyos/).
- [Arch User Repository](https://aur.archlinux.org/) dan [RPC API](https://aur.archlinux.org/rpc).
- [CachyOS — boot manager dan Limine](https://wiki.cachyos.org/configuration/boot_manager_configuration/).
- [Hyprland — konfigurasi Lua](https://wiki.hypr.land/Configuring/Start/).
- [Noctalia — instalasi](https://docs.noctalia.dev/noctalia/getting-started/installation/).
- [Noctalia — konfigurasi dan runtime overrides](https://docs.noctalia.dev/noctalia/configuration/).
- [Noctalia — IPC](https://docs.noctalia.dev/noctalia/ipc/).
- [TLP — service dan instalasi](https://linrunner.de/tlp/faq/installation.html).
- [KDE Wallet — PAM dan startup](https://wiki.archlinux.org/title/KDE_Wallet).
- [Btrfs — swapfile](https://btrfs.readthedocs.io/en/latest/Swapfile.html).
- [PostgreSQL — upgrade](https://www.postgresql.org/docs/current/upgrading.html).
- [MySQL 8.4 — socket authentication](https://dev.mysql.com/doc/refman/8.4/en/socket-pluggable-authentication.html).
- [Maple Mono](https://github.com/subframe7536/maple-font).
- [Catppuccin KDE](https://github.com/catppuccin/kde).
- [Catppuccin Plymouth](https://github.com/catppuccin/plymouth).
- [Moe-Dark](https://gitlab.com/jomada/moe-dark).
- [WhiteSur cursors](https://github.com/vinceliuice/WhiteSur-cursors).
- [itch Linux](https://itch.io/app).

Dokumentasi tambahan yang sudah ada di repo:

- [Shortcut Hyprland × Noctalia](hyprland-noctalia-cheatsheet.md).
- [Appearance Hyprland](hyprland-appearance-variables.md).
- [Panduan ricing Noctalia](noctalia-ricing-guide.md).

