{ pkgs ? import <nixpkgs> { } }: {
  bbshop-trimmer = pkgs.haskellPackages.callPackage ./clipTrimmer.nix { };
}
