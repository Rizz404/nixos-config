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
