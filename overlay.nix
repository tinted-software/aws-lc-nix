{ aws-lc-src }:
(self: super: {
  linuxKernel.packages.mainline = self.callPackage ./linux { inherit linux-src; };
  llvmPackages = super.llvmPackages_19;
  cmake = self.callPackage ./cmake { isMinimalBuild = true; };
  cmakeMinimal = self.callPackage ./cmake { isMinimalBuild = true; };
  curlMinimal = super.curlMinimal.override {
    opensslSupport = false;
    scpSupport = false;
    gssSupport = false;
    http2Support = false;
  };
  python312 = super.python312.overrideAttrs (old: {
    patches = old.patches ++ [ ./python/aws-lc-3.12.patch ];
  });
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
