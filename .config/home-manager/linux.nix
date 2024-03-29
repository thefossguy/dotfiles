{ config, lib, pkgs, ... }:

let
  OVMFBinName = if pkgs.stdenv.isAarch64 then "AAVMF"
    else "OVMF";
in

{
  home.packages = with pkgs; [
    # base system packages + packages what I *need*
    smartmontools
    wol

    # other utilities
    parted
    ubootTools
    ventoy

    # virtualisation
    libvirt
    qemu_kvm
    virt-manager
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

  # for raw QEMU VMs
  home.activation = {
    OVMFActivation = lib.hm.dag.entryAfter [ "installPackages" ] (if pkgs.stdenv.isx86_64 then ''
        EDKII_CODE_NIX="${pkgs.OVMF.fd}/FV/${OVMFBinName}_CODE.fd"
        EDKII_VARS_NIX="${pkgs.OVMF.fd}/FV/${OVMFBinName}_VARS.fd"

        EDKII_DIR_HOME="$HOME/.local/share/edk2"
        EDKII_CODE_HOME="$EDKII_DIR_HOME/EDKII_CODE"
        EDKII_VARS_HOME="$EDKII_DIR_HOME/EDKII_VARS"

        if [ -d "$EDKII_DIR_HOME" ]; then
            rm -rf "$EDKII_DIR_HOME"
        fi
        mkdir -p "$EDKII_DIR_HOME"

        cp "$EDKII_CODE_NIX" "$EDKII_CODE_HOME"
        cp "$EDKII_VARS_NIX" "$EDKII_VARS_HOME"

        chown pratham:pratham "$EDKII_CODE_HOME" "$EDKII_VARS_HOME"
        chmod 644 "$EDKII_CODE_HOME" "$EDKII_VARS_HOME"
      '' else "");

    otherPkgMgrActivation = lib.hm.dag.entryAfter [ "installPackages" ] ''
        EXTRA_BIN_PATH="$HOME/.local/$USER/bin"

        if [ -d "$EXTRA_BIN_PATH" ]; then
            rm -rf "$EXTRA_BIN_PATH"
        fi
        mkdir -p "$EXTRA_BIN_PATH"

        pushd "$EXTRA_BIN_PATH"
        for deb_bin in ${pkgs.binutils}/bin/* ${pkgs.rpm}/bin/*; do
            ln -s "$deb_bin" "$(basename "$deb_bin")"
        done
        popd
    '';
  };

  # for libvirt, virt-manager, virsh
  xdg.configFile = {
    "libvirt/qemu.conf" = {
      enable = true;
      text = ''
        nvram = [ "${pkgs.OVMF.fd}/FV/${OVMFBinName}_CODE.fd:${pkgs.OVMF.fd}/FV/${OVMFBinName}_VARS.fd" ]
      '';
    };
  };

  targets.genericLinux.enable = true;
}
