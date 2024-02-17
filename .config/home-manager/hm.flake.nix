{
  inputs = {
    # a better way of using the latest stable version of nixpkgs
    # without specifying specific release
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        OVMFPkg = (pkgs.OVMF.override{
          secureBoot = true;
          tpmSupport = true;
          }).fd;
        OVMFBinName = if pkgs.stdenv.isAarch64 then "AAVMF"
          else (
            if pkgs.stdenv.isx86_64 then "OVMF"
            else ""
          );
        whoAmI = "pratham";
      in
      {
        packages.homeConfigurations = {
          "${whoAmI}" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix OVMFPkg OVMFBinName
              (if pkgs.stdenv.isLinux then ./linux.nix whoAmI else ./darwin.nix whoAmI)
              {
                home.stateVersion = "23.11";
              }
            ];
          };
        };
      }
    );
}
