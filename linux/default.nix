{ buildLinux, linux-src, ... }@args:
buildLinux (
  args
  // rec {
    version = "6.11";

    src = linux-src;
    kernelPatches = [
      ({
        name = "AWS-LC Support";
        patch = ./aws-lc.patch;
      })
      ({
        name = "Rust Support";
        patch = null;
        features = {
          rust = true;
        };
      })
    ];

    extraConfig = ''
      CONFIG_BCACHEFS_FS y
    '';

    extraMeta.branch = "";
  }
  // (args.argsOverride or { })
)
