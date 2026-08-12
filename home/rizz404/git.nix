{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Rizqiansyah";
    userEmail = "rizzthenotable@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
