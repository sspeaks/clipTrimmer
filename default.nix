{ pkgs ? import <nixpkgs> { } }: {
  clipTrimmer = pkgs.haskellPackages.callPackage ./clipTrimmer.nix { };
}
