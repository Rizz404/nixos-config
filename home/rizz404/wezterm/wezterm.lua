local wezterm = require 'wezterm'
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

return config
