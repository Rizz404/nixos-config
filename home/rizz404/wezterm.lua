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

-- Menghapus dekorasi jendela bawaan (title bar) namun mempertahankan fungsionalitas resize
-- config.window_decorations = 'RESIZE'

return config
