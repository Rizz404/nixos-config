{ pkgs, lib, ... }:

let
  fetchPlugin = { owner, repo, rev, hash, subdir ? null }:
    let src = pkgs.fetchFromGitHub { inherit owner repo rev hash; };
    in if subdir == null then src else "${src}/${subdir}";

  plugins = {
    bookmark = fetchPlugin {
      owner = "haqk"; repo = "micro-bookmark";
      rev = "64acf8c7dfe67cfc61bf3ae6c5eeae5af5393a86";
      hash = lib.fakeHash;
    };
    editorconfig = fetchPlugin {
      owner = "10sr"; repo = "editorconfig-micro";
      rev = "892aa42b50e6f57a5065b6f4df8c4e0a3913c9ee";
      hash = lib.fakeHash;
    };
    filemanager = fetchPlugin {
      owner = "NicolaiSoeborg"; repo = "filemanager-plugin";
      rev = "76145693baeb4c06cb7728fcf8931ae2980f30ce";
      hash = lib.fakeHash;
    };
    fzf = fetchPlugin {
      owner = "samdmarshall"; repo = "micro-fzf-plugin";
      rev = "ebc6baa05c3532ccaf9139b1d38a8791d6d5ba7d";
      hash = lib.fakeHash;
    };
    jump = fetchPlugin {
      owner = "terokarvinen"; repo = "micro-jump";
      rev = "344ca9daab30c2fa8849a0ca41966629147347b1";
      hash = lib.fakeHash;
    };
    lsp = fetchPlugin {
      owner = "AndCake"; repo = "micro-plugin-lsp";
      rev = "a3ed3a73b2f7576b1e2dc1ac3c98dfe695e6d05d";
      hash = lib.fakeHash;
    };
    manipulator = fetchPlugin {
      owner = "NicolaiSoeborg"; repo = "manipulator-plugin";
      rev = "41ce0bebf29a6f36144dc9ecdd516a27b5b45b64";
      hash = lib.fakeHash;
    };
    quoter = fetchPlugin {
      owner = "deusnefum"; repo = "micro-quoter";
      rev = "31a8bc6b04755546d47984e6e1ab3dd5e6f0f24c";
      hash = lib.fakeHash;
    };
    # bukan repo sendiri — folder di dalam monorepo micro-editor/updated-plugins
    snippets = fetchPlugin {
      owner = "micro-editor"; repo = "updated-plugins";
      rev = "216ec3adaf3adec78665614402ece56cf60ae713";
      hash = lib.fakeHash;
      subdir = "micro-snippets-plugin";
    };
    wc = fetchPlugin {
      owner = "adamnpeace"; repo = "micro-wc-plugin";
      rev = "b2c9957e521770eadc1ecae9d54c0a30f40a0a3d";
      hash = lib.fakeHash;
    };
  };

  catppuccinMicro = pkgs.fetchFromGitHub {
    owner = "catppuccin"; repo = "micro";
    rev = "015a2bb208f61a2d5a33121de2644bf4a059436b";
    hash = lib.fakeHash;
  };

  # Gabung: 4 tema resmi dari upstream + 4 varian -transparent hasil edit sendiri
  colorschemes = pkgs.runCommand "micro-colorschemes" { } ''
    mkdir -p $out
    cp -r ${catppuccinMicro}/themes/. $out/
    cp ${./colorschemes/catppuccin-latte-transparent.micro} $out/catppuccin-latte-transparent.micro
    cp ${./colorschemes/catppuccin-frappe-transparent.micro} $out/catppuccin-frappe-transparent.micro
    cp ${./colorschemes/catppuccin-macchiato-transparent.micro} $out/catppuccin-macchiato-transparent.micro
    cp ${./colorschemes/catppuccin-mocha-transparent.micro} $out/catppuccin-mocha-transparent.micro
  '';
in
{
  programs.micro = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./settings.json);
  };

  xdg.configFile =
    {
      "micro/bindings.json".source = ./bindings.json;
      "micro/colorschemes".source = colorschemes;
    }
    // lib.mapAttrs'
         (name: src: lib.nameValuePair "micro/plug/${name}" { source = src; })
         plugins;
}
