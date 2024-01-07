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
    ] ++ (with pkgs.fishPlugins; [
      async-prompt
      colored-man-pages
      fzf
      puffer
      sponge
      z
    ]);
  };

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [ "root" "pratham" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  programs.fish.enable = true;
  xdg.configFile."fish/config.fish".enable = false; # no need to overwrite config.fish

  services = {
    home-manager.autoUpgrade = {
      enable = true;
      frequency = "daily";
    };
  };
}
