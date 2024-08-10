{ buildLinux, linux-src, ... }@args:
buildLinux (
  args
  // rec {
    version = "6.11";

    src = linux-src;
    kernelPatches = [ ./aws-lc.patch ];

    extraConfig = ''
      CONFIG_BCACHEFS_FS y
    '';

    extraMeta.branch = "";
  }
  // (args.argsOverride or { })
)
