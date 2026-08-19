{ pkgs, ... }:

let
  # Helper function untuk mempermudah fetch plugin dari GitHub
  fetchPlugin = { owner, repo, rev, hash }: pkgs.fetchFromGitHub {
    inherit owner repo rev hash;
  };
in
{
  programs.micro = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./settings.json);
    keybindings = builtins.fromJSON (builtins.readFile ./bindings.json);
  };

  # Deklarasi Plugin & Tema ke ~/.config/micro/plug/
  xdg.configFile = {
    # --- 1. Navigasi & File Explorer ---
    "micro/plug/filemanager".source = fetchPlugin {
      owner = "micro-editor";
      repo = "updated-plugins";
      rev = "v1.0.0";
      hash = "sha256-5c5k11Yn05U4dM67gLq1Qx97/y9G6/y7H9FkL7tVw5g=";
    };
    "micro/plug/fzf".source = fetchPlugin {
      owner = "micro-editor";
      repo = "micro-fzf-plugin";
      rev = "master";
      hash = "sha256-5B1a4f0kQ9n7q6u7o8p0kQ9n7q6u7o8p0kQ9n7q6u7o=";
    };
    "micro/plug/jump".source = fetchPlugin {
      owner = "micro-editor";
      repo = "micro-jump";
      rev = "master";
      hash = "sha256-1111111111111111111111111111111111111111111=";
    };
    "micro/plug/bookmark".source = fetchPlugin {
      owner = "micro-editor";
      repo = "micro-bookmark";
      rev = "master";
      hash = "sha256-1111111111111111111111111111111111111111111=";
    };

    # --- 2. Produktivitas Koding & Formatting ---
    "micro/plug/lsp".source = fetchPlugin {
      owner = "Andriamanitra";
      repo = "micro-lsp";
      rev = "v0.6.2";
      hash = "sha256-wK9h7aHkX9hFvK3m8E2G8D0M2L1P4A6Z8X2C4V6B8N0=";
    };
    "micro/plug/snippets".source = fetchPlugin {
      owner = "micro-editor";
      repo = "micro-snippets-plugin";
      rev = "master";
      hash = "sha256-1111111111111111111111111111111111111111111=";
    };
    "micro/plug/quoter".source = fetchPlugin {
      owner = "micro-editor";
      repo = "micro-quoter";
      rev = "master";
      hash = "sha256-1111111111111111111111111111111111111111111=";
    };
    "micro/plug/manipulator".source = fetchPlugin {
      owner = "micro-editor";
      repo = "micro-manipulator";
      rev = "master";
      hash = "sha256-1111111111111111111111111111111111111111111=";
    };
    "micro/plug/editorconfig".source = fetchPlugin {
      owner = "micro-editor";
      repo = "micro-editorconfig";
      rev = "master";
      hash = "sha256-1111111111111111111111111111111111111111111=";
    };

    # --- 3. Eksekusi & Utilitas ---
    "micro/plug/runit".source = fetchPlugin {
      owner = "micro-editor";
      repo = "micro-runit";
      rev = "master";
      hash = "sha256-1111111111111111111111111111111111111111111=";
    };
    "micro/plug/wc".source = fetchPlugin {
      owner = "micro-editor";
      repo = "micro-wc";
      rev = "master";
      hash = "sha256-1111111111111111111111111111111111111111111=";
    };
    "micro/plug/cheat".source = fetchPlugin {
      owner = "micro-editor";
      repo = "micro-cheat";
      rev = "master";
      hash = "sha256-1111111111111111111111111111111111111111111=";
    };

    # --- 4. Tema: Catppuccin ---
    "micro/plug/catppuccin".source = fetchPlugin {
      owner = "catppuccin";
      repo = "micro";
      rev = "main";
      hash = "sha256-3M1g7W32H+XqQzX3k9h4k1/1w6vQ8Y7k0X2a3B4C5D6=";
    };
  };
}