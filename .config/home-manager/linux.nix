{ config, lib, pkgs, ... }:
let
  me = "pratham";
in

{
  home.username = "${me}";
  home.homeDirectory = "/home/${me}";
  targets.genericLinux.enable = true;
}
