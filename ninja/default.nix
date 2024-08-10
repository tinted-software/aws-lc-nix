{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "ninja";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "ninja-build";
    repo = "ninja";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RT5u+TDvWxG5EVQEYj931EZyrHUSAqK73OKDAascAwA=";
  };

  buildPhase = ''
    $CXX \
      -std=c++11 \
      -Os -flto=auto \
      -o ninja \
      src/depfile_parser.cc src/lexer.cc \
      src/build_log.cc \
    	src/build.cc \
    	src/clean.cc \
    	src/clparser.cc \
    	src/dyndep.cc \
    	src/dyndep_parser.cc \
    	src/debug_flags.cc \
    	src/deps_log.cc \
    	src/disk_interface.cc \
    	src/edit_distance.cc \
    	src/eval_env.cc \
    	src/graph.cc \
    	src/graphviz.cc \
    	src/json.cc \
    	src/line_printer.cc \
    	src/manifest_parser.cc \
    	src/metrics.cc \
    	src/missing_deps.cc \
    	src/parser.cc \
    	src/state.cc \
    	src/status.cc \
    	src/string_piece_util.cc \
    	src/util.cc \
    	src/version.cc \
      src/subprocess-posix.cc \
      src/ninja.cc
  '';

  installPhase = ''
    mkdir -p $out/bin/
    mv ninja $out/bin/
  '';
})
