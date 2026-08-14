{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
  	# desktop
    bruno
	rustdesk
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
