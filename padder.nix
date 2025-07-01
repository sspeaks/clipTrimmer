{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "padtimestamps";
  version = "1.0.0";
  src = ./.;

  hsSourceDirs = [ "." ];

  # If your program requires any additional build inputs, list them here.
  buildInputs = [ pkgs.ghc ];

  buildPhase = ''
    ${pkgs.ghc}/bin/ghc ./padtimestamps.hs
    mkdir -p $out/bin
    cp padtimestamps $out/bin/padtimestamps
  '';

}
