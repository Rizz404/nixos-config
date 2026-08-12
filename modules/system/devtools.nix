{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bruno
    claude-code
    delta
    gh
    lazygit
    micro
    pgcli
    php
    postgresql
    python3
	rustdesk    
    vscode

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
  ];
}
