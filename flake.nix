{
  description = "A basic flake";

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs/pull/332918/head";
    linux-src = {
      url = "github:torvalds/linux";
      flake = false;
    };
    aws-lc-src = {
      url = "github:aws/aws-lc";
      flake = false;
    };
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      aws-lc-src,
      linux-src,
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    rec {
      packages = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;

            crossSystem = {
              inherit system;
              useLLVM = true;
              linker = "lld";
            };

            overlays = [ (import ./overlay.nix { inherit aws-lc-src linux-src; }) ];
          };
        in
        {
          aws-lc = pkgs.aws-lc;
          linux = pkgs.linuxKernel.packages.mainline;
        }
      );
    };
}
