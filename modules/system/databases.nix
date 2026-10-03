{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pgcli
    mycli
  ];

  # Pin versi mayor; patch mengikuti nixpkgs di flake.lock.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    ensureDatabases = [ "rizz404" ];
    ensureUsers = [
      {
        name = "rizz404";
        ensureDBOwnership = true;
      }
    ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mysql84; # MySQL 8.4 LTS
    settings.mysqld.bind-address = "127.0.0.1";
    ensureDatabases = [ "rizz404" ];
    # Login lokal sebagai user sistem rizz404 melalui Unix socket.
    ensureUsers = [
      {
        name = "rizz404";
        ensurePermissions = {
          "rizz404.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
