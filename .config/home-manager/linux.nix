{ config, lib, pkgs, ... }:

{
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    virt-manager
    libvirt
  ];

  systemd.user = {
    timers = {
      "update-flake-inputs" = {
        Unit = {
          Description = "Flake input update timer";
        };
        Timer = {
          OnCalendar = "*** 23:30:00";
          Persistent = "true";
          Unit = "update-flake-inputs.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
    services = {
      "update-flake-inputs" = {
        Unit = {
          Description = "Update flake inputs for Home Manager";
          Before = [ "home-manager-auto-upgrade.service" ];
        };
        Service = {
          ExecStart = toString
            (pkgs.writeShellScript "" ''
              echo 'Running `nix flake update` for the Home Manager flake'
              pushd $HOME/.config/home-manager
              ${pkgs.nix}/bin/nix flake update
              popd
            '');
        };
        Install = {
          RequiredBy = [ "home-manager-auto-upgrade.service" ];
        };
      };
    };
  };

  services = {
    home-manager.autoUpgrade = {
      enable = true;
      frequency = "daily";
    };
  };
}
