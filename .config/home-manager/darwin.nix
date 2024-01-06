{ config, lib, pkgs, ... }:

{
  home.homeDirectory = "/Users/pratham";

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

  services.caffeinate.enable = true;
}
