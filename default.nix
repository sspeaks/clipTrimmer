{ pkgs ? import <nixpkgs> { } }: {
  bbshop-trimmer = pkgs.haskellPackages.callPackage ./bbshop-trimmer.nix { };
}
