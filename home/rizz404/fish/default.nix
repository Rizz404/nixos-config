{ ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
      end
    '';
  };
}
