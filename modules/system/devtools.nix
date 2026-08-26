{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
  	# desktop
    bruno
	  rustdesk-flutter
    vscode

	  # cli tools
    claude-code
    delta
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
    fzf
    aspell
    eza
    arch-install-scripts
    podman
    podman-compose
    podman-tui

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
