{
  description = "oakes.family";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, ... }:
    let
      domain = "oakes.family";
      pkgsFor = system: nixpkgs.legacyPackages.${system};
      pkgs = pkgsFor "x86_64-linux";
    in {
      nixosConfigurations.pi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [ (import ./pi.nix) ];
      };
      nixopsConfigurations.default = {
        inherit nixpkgs;
        network.description = domain;
        network.nixpkgs = pkgs;
        gitServer = { lib, pkgs, ... }: {
          imports = [
            ./hardware/pi.nix
            ./modules/ddns.nix
            ./modules/git.oakes.family.nix
          ];

          deployment.targetHost = "192.168.0.3";
        };
      };

    } // utils.lib.eachDefaultSystem (system:
      with (pkgsFor system); {
        devShell = mkShell {
          buildInputs = [ nixopsUnstable ];
          # Segfault in nix.
          # ref: https://github.com/NixOS/nix/issues/4178
          GC_DONT_GC = 1;
        };
      });
}
