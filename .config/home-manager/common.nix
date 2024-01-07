{ config, lib, pkgs, ... }:

{
  imports = [ ./platform.nix ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home = {
    username = "pratham";
    packages = with pkgs; [
      neovim
      direnv
    ];
  };

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [ "root" "pratham" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  services = {
    home-manager.autoUpgrade = {
      enable = true;
      frequency = "daily";
    };
  };
}
