{
  inputs = {
    # a better way of using the latest stable version of nixpkgs
    # without specifying specific release
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        whoAmI = "pratham";
      in
      {
        packages.homeConfigurations = {
          "${whoAmI}" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix
              (if pkgs.stdenv.isLinux then ./linux.nix else ./darwin.nix)
              {
                home = {
                  stateVersion = "23.11";
                  username = "${whoAmI}";
                  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${whoAmI}"
                    else "/home/${whoAmI}";
                };
              }
            ];
          };
        };
      }
    );
}
