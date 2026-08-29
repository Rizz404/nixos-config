{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Rizqiansyah";
        email = "rizzthenotable@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
