{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # base system packages + packages what I *need*
    coreutils-prefixed
    gawk
    gnugrep
    gnused

    # for media consumption, manipulation and metadata info
    ffmpeg
    imagemagick
    mediainfo

    # GUI apps
    meld
    utm

    # fonts
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "Overpass"
        "SourceCodePro"
      ];
    })
  ];

  programs = {
    mpv.enable = true;
    alacritty.enable = true;
    tmux.enable = true;
    bash = {
      enable = true;
      enableCompletion = true;
    };
  };

  # home-manager does not need to overwrite these files in $HOME
  xdg.configFile = {
  };
  home.file = {
    ".bash_profile".enable = false;
    ".bashrc".enable = false;
    ".profile".enable = false;
  };

  targets.darwin = {
    currentHostDefaults = {
      "com.apple.controlcenter".BatteryShowPercentage = true;
    };
    defaults = {
      NSGlobalDomain = {
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      "com.apple.Safari" = {
        AutoFillCreditCardData = false;
        AutoFillPasswords = false;
        AutoOpenSafeDownloads = false;
        IncludeDevelopMenu = true;
        ShowOverlayStatusBar = true;
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.dock" = {
        expose-group-apps = false;
        size-immutable = false;
        tilesize = 32;
      };
    };
    # https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/TextDefaultsBindings/TextDefaultsBindings.html
    keybindings = {
      "^\Uf702" = "moveWordLeft:"; # Ctrl-<Left>
      "^\Uf703" = "moveWordRight:"; # Ctrl-<Right>
    };
  };
}
