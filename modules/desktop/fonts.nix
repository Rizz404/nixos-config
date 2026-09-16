{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
    maple-mono.NF
    nerd-fonts.caskaydia-cove
    nerd-fonts.comic-shanns-mono
    corefonts
    open-sans
  ];
}
