{ pkgs, ... }:
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

    # cli tools
    claude-code
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
    xpdf

    # database and its tools
    pgcli
    postgresql
    mycli

    # programming language
    php
    php.packages.composer
    python3
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
