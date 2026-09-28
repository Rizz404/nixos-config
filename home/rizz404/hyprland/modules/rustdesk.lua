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
