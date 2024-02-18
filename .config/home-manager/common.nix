{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # base system packages + packages what I *need*
    cloud-utils # provides growpart
    parallel
    pinentry # pkg summary: GnuPG’s interface to passphrase input
    pv
    python3Minimal
    rsync
    tree
    vim # it is a necessity

    # shells
    dash

    # download clients
    curl
    wget

    # compression and decompression
    bzip2
    gnutar
    gzip
    unzip
    xz
    zip
    zstd

    # programming tools + compilers + interpreters
    ghc
    rustup # provides rustfmt, cargo-clippy, rustup, cargo, rust-lldb, rust-analyzer, rustc, rust-gdb, cargo-fmt

    # dealing with other distro's packages
    dpkg
    rpm

    # network monitoring
    iperf # this is iperf3
    iperf2 # this is what is usually 'iperf' on other distros
    nload
    trippy

    # other utilities
    android-tools
    asciinema
    #buildah # 1. needs to be built for some reason; 2. git is a build requirement
    fzf
    parted
    picocom
    ubootTools
    ventoy

    # utilities written in Rust
    choose
    du-dust
    dua
    fd
    hyperfine
    procs
    sd
    tre-command

    # tools specific to Nix
    nix-output-monitor
  ];

  programs = {
    aria2.enable = true;
    bat.enable = true;
    bottom.enable = true;
    broot.enable = true;
    btop.enable = true;
    command-not-found.enable = true;
    gpg.enable = true;
    home-manager.enable = true;
    htop.enable = true;
    ripgrep.enable = true;
    tealdeer.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;

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

    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  nix = {
    package = pkgs.nix;
    checkConfig = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false; # no need to re-enable this, '--help' works
  };
  news.display = "silent";
}
