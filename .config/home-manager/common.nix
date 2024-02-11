{ config, lib, pkgs, ... }:

{
  programs.home-manager.enable = true;

  home = {
    packages = with pkgs; [
      gawk
      gnugrep
      gnused
      parallel
      pv
      python3Minimal
      rsync
      tmux
      tree
      wol

      dash

      aria2
      yt-dlp

      bzip2
      gnutar
      gzip
      unzip
      xz
      zip
      zstd

      b4
      rustup

      btop
      htop
      iperf

      #buildah #1. needs to be built for some reason; 2. git is a build requirement
      fzf
      picocom
      podman

      bat
      broot
      choose
      du-dust
      dua
      fd
      ripgrep
      sd
      skim
      zoxide

      nix-output-monitor
    ];
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

  services = {
    home-manager.autoUpgrade = {
      enable = true;
      frequency = "daily";
    };
  };

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false; # no need to re-enable this, '--help' works
  };
  news.display = "silent";
}
