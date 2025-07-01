{ pkgs, mkDerivation, base, directory, lib, parsec, process}:
mkDerivation {
  pname = "clipTrimmer";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base directory parsec process ];
  executableSystemDepends = [ pkgs.ffmpeg-full pkgs.makeWrapper ];
  postFixup = ''
    wrapProgram $out/bin/clipTrimmer \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ffmpeg-full ]}
  '';
  license = "unknown";
  hydraPlatforms = lib.platforms.none;
}
