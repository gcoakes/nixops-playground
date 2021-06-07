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
      nixopsConfigurations.default = {
        inherit nixpkgs;
        network.description = domain;
        network.nixpkgs = pkgs;
        webserver = { ... }: {
          deployment.targetEnv = "libvirtd";
          services.lighttpd = {
            enable = true;
            cgit.enable = true;
          };
          networking.firewall.allowedTCPPorts = [ 80 443 ];
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
