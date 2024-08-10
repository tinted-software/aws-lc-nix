{
  description = "A basic flake";

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs/master";
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

            overlays = [ (import ./overlay.nix { inherit aws-lc-src; }) ];
          };
        in
        {
          aws-lc = pkgs.aws-lc;
        }
      );
    };
}
