{ config, lib, pkgs, ... }:

{
  home.homeDirectory = "/home/pratham";
  targets.genericLinux.enable = true;
}
