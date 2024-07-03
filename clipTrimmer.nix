{ mkDerivation, base, directory, lib, parsec, process }:
mkDerivation {
  pname = "clipTrimmer";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base directory parsec process ];
  license = "unknown";
  hydraPlatforms = lib.platforms.none;
}
