{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
  ];

  programs = {
    home-manager.enable = true;
  };

  # home-manager does not need to overwrite these files in $HOME
  home.file = {
    ".bash_profile".enable = false;
    ".bashrc".enable = false;
    ".profile".enable = false;
  };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
    };
    command-not-found.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    neovim = {
      enable = true;
      extraPackages = with pkgs; [
        clang-tools # provides clangd
        gcc # for nvim-tree's parsers
        lldb # provides lldb-vscode
        lua-language-server
        nil # language server for Nix
        nixpkgs-fmt
        nodePackages.bash-language-server
        ruff
        shellcheck
        tree-sitter # otherwise nvim complains that the binary 'tree-sitter' is not found
      ];
    };
  };

  nix = {
    package = pkgs.nix;
    checkConfig = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false; # no need to re-enable this, '--help' works
  };
  news.display = "silent";
}
