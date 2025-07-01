{ pkgs ? import <nixpkgs> { } }: {
  clipTrimmer = pkgs.haskellPackages.callPackage ./clipTrimmer.nix { };
  padtimestamps = pkgs.callPackage ./padder.nix { };
}
