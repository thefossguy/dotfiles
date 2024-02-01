{ config, lib, pkgs, ... }:

{
  imports = [ ./platform.nix ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home = {
    username = "pratham";
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
      gcc # for neovim [plugins]
      rustup

      clang-tools
      lldb
      ruff
      shellcheck
      tree-sitter

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
      package = pkgs.nix-direnv;
      enableBashIntegration = true;
    };
    neovim.enable = true;
  };

  nix = {
    package = pkgs.nix;
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
