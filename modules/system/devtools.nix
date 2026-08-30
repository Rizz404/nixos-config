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
    tesseract
    xh
    p7zip
    unzip
    zip
    unrar
    rclone
    yt-dlp
    wl-clipboard
    aspell
    aspellDicts.en
    aspellDicts.id
    arch-install-scripts
    podman
    podman-compose
    podman-tui
    iw
    pciutils
    usbutils
    aircrack-ng
    wireshark
    # reaver
    bully
    wpa_supplicant
    wirelesstools

    # database and its tools
    pgcli
    postgresql

	  # programming language
    php
    python3
    jdk25
    nodejs
    go
    golangci-lint
    bun
    maven
    dart
    flutter
  ];
}
