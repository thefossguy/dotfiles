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
      in
      {
        packages.homeConfigurations = {
          "pratham" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix
              (if pkgs.stdenv.isLinux then ./linux.nix else ./darwin.nix)
              {
                home.stateVersion = "23.11";
              }
            ];
          };
        };
      }
    );
}
