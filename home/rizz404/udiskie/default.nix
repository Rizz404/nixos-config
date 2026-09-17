{ ... }:{
  services.udiskie = {
    enable = true;
    automount = true;  # * auto-mount pas USB dicolok
    notify = true;      # * notifikasi popup pas device masuk/keluar
    tray = "auto";    # * "auto" = ikon cuma nongol kalau ada device, "always" = selalu ada
  };
}
