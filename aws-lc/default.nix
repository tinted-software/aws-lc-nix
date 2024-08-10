{
  lib,
  stdenv,
  cmake,
  ninja,
  testers,
  aws-lc,
  src,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aws-lc";
  version = "1.33.0";

  src = src;

  vendorHash = "sha256-hHWsEXOOxJttX+k0gy/QXvR+yhQLBjE40QIOpwCNpFU=";

  proxyVendor = true;

  outputs = [
    "out"
    "bin"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  preBuild = ''
    # hack to get both go and cmake configure phase
    # (if we use postConfigure then cmake will loop runHook postConfigure)
    cmakeConfigurePhase
  '';

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.targetPlatform.isStatic))
    "-GNinja"
    "-DDISABLE_GO=ON"
    "-Bbuild"
  ];

  buildPhase = ''
    cmake --build build
  '';

  installPhase = ''
    cmake --install build
  '';

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isGNU [
      # Needed with GCC 12 but breaks on darwin (with clang)
      "-Wno-error=stringop-overflow"
    ]
  );

  postFixup = ''
    for f in $out/lib/crypto/cmake/*/crypto-targets.cmake; do
      substituteInPlace "$f" \
        --replace-fail 'INTERFACE_INCLUDE_DIRECTORIES "''${_IMPORT_PREFIX}/include"' 'INTERFACE_INCLUDE_DIRECTORIES ""'
    done
  '';

  passthru.tests = {
    version = testers.testVersion {
      package = aws-lc;
      command = "bssl version";
    };
    pkg-config = testers.hasPkgConfigModules {
      package = aws-lc;
      moduleNames = [
        "libcrypto"
        "libssl"
        "openssl"
      ];
    };
  };

  meta = {
    description = "General-purpose cryptographic library maintained by the AWS Cryptography team for AWS and their customers";
    homepage = "https://github.com/aws/aws-lc";
    license = [
      lib.licenses.asl20 # or
      lib.licenses.isc
    ];
    maintainers = [ lib.maintainers.theoparis ];
    platforms = lib.platforms.all;
    mainProgram = "bssl";
  };
})
