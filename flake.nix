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

            overlays = [
              (self: super: {
                llvmPackages = super.llvmPackages_19;
                cmake = self.callPackage ./cmake { isMinimalBuild = true; };
                cmakeMinimal = self.callPackage ./cmake { isMinimalBuild = true; };
                curlMinimal = super.curlMinimal.override {
                  opensslSupport = false;
                  scpSupport = false;
                  gssSupport = false;
                  http2Support = false;
                };
                curl = super.curl.override { pslSupport = false; };
                ninja = super.callPackage ./ninja { };
                pkg-config-unwrapped = super.pkg-config-unwrapped.overrideAttrs (old: rec {
                  src = builtins.fetchTarball {
                    url = "https://pkg-config.freedesktop.org/releases/${old.pname}-${old.version}.tar.gz";
                    sha256 = "0lhhkix4pxnbxbialg7ma3pj892r8b5vp16iavccfxzzmwn4mbyk";
                  };
                });
                aws-lc = super.callPackage ./aws-lc { src = aws-lc-src; };
                openssl = self.aws-lc;
              })
            ];
          };
        in
        {
          aws-lc = pkgs.aws-lc;
        }
      );
    };
}
