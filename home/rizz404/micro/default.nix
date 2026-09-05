{ pkgs, lib, ... }:

let
  fetchPlugin = { owner, repo, rev, hash, subdir ? null }:
    let src = pkgs.fetchFromGitHub {
      inherit owner repo rev hash;
      name = "micro-plugin-${repo}-src";
    };
    in if subdir == null then src else "${src}/${subdir}";

  plugins = {
    bookmark = fetchPlugin {
      owner = "haqk"; repo = "micro-bookmark";
      rev = "64acf8c7dfe67cfc61bf3ae6c5eeae5af5393a86";
      hash = "sha256-i6JkH0J3NsGl8wCoc1zroDsIuyUY4MnRZRGt8vnwX1c=";
    };
    editorconfig = fetchPlugin {
      owner = "10sr"; repo = "editorconfig-micro";
      rev = "892aa42b50e6f57a5065b6f4df8c4e0a3913c9ee";
      hash = "sha256-yZhM+zuyv5PlcD5tya6EzJbSx382HJNb9F5Kaj4tWNY=";
    };
    filemanager = fetchPlugin {
      owner = "NicolaiSoeborg"; repo = "filemanager-plugin";
      rev = "76145693baeb4c06cb7728fcf8931ae2980f30ce";
      hash = "sha256-R4uSZOf8H9tu+v31fFQ+CcUEGxhVAmE9c/1vK8pxM+o=";
    };
    fzf = fetchPlugin {
      owner = "samdmarshall"; repo = "micro-fzf-plugin";
      rev = "ebc6baa05c3532ccaf9139b1d38a8791d6d5ba7d";
      hash = "sha256-tmQBBiRc/hR09KUkNUT/nwD/AfC8k1eIopJPKb8+3qo=";
    };
    jump = fetchPlugin {
      owner = "terokarvinen"; repo = "micro-jump";
      rev = "344ca9daab30c2fa8849a0ca41966629147347b1";
      hash = "sha256-7od4rxijA8uOZDP7Go5Qa+88ZvKS6jERH1eYYKnwoac=";
    };
    lsp = fetchPlugin {
      owner = "AndCake"; repo = "micro-plugin-lsp";
      rev = "a3ed3a73b2f7576b1e2dc1ac3c98dfe695e6d05d";
      hash = "sha256-0an688Bc+ZtJ4JHqMfD8UAsCoKgQs6A+DRgfr1QpYG0=";
    };
    manipulator = fetchPlugin {
      owner = "NicolaiSoeborg"; repo = "manipulator-plugin";
      rev = "41ce0bebf29a6f36144dc9ecdd516a27b5b45b64";
      hash = "sha256-ucHOrZhmEVl+4J5q1vqytxrrMw6LXsoV7/nnAgdCQXo=";
    };
    quoter = fetchPlugin {
      owner = "deusnefum"; repo = "micro-quoter";
      rev = "31a8bc6b04755546d47984e6e1ab3dd5e6f0f24c";
      hash = "sha256-BX0Vj1ZVP7FlcG/4D7x1V0MmZ/IYNEmIcpcqubZLabQ=";
    };
    snippets = fetchPlugin {
      owner = "micro-editor"; repo = "updated-plugins";
      rev = "216ec3adaf3adec78665614402ece56cf60ae713";
      hash = "sha256-bYM+ZOxCbWDuN6/iWzRLxGrQr24Pe+WETRa9cXK076A=";
      subdir = "micro-snippets-plugin";
    };
    wc = fetchPlugin {
      owner = "adamnpeace"; repo = "micro-wc-plugin";
      rev = "b2c9957e521770eadc1ecae9d54c0a30f40a0a3d";
      hash = "sha256-Z6MC2cet8+7XHv41G+SlAZViCqlh/9dk0CSt7HklnTg=";
    };
  };

  catppuccinMicro = pkgs.fetchFromGitHub {
    owner = "catppuccin"; repo = "micro";
    rev = "015a2bb208f61a2d5a33121de2644bf4a059436b";
    hash = "sha256-XbhUwRz21/XLkdOb6VOqLwzxWtehf6qRms0YcepNQ0s=";
  };

  colorschemes = pkgs.runCommand "micro-colorschemes" { } ''
    mkdir -p $out
    cp -r ${catppuccinMicro}/themes/. $out/
    chmod -R u+w $out
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
