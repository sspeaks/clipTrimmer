{ pkgs ? import <nixpkgs> { }, compiler ? "default", withHoogle ? true }:

let
  # haskellPackages = pkgs.haskell.packages.ghc921;
  haskellPackages = pkgs.haskellPackages;
  profiledHaskellPackages = haskellPackages.override {
    overrides = self: super: {
      mkDerivation = args:
        super.mkDerivation (args // { enableLibraryProfiling = true; });
    };
  };
  p = profiledHaskellPackages.callPackage ./clipTrimmer.nix { };

  shell = haskellPackages.shellFor {
    packages = ps: [ p ];
    withHoogle = true;
    buildInputs = (with haskellPackages; [
      haskell-language-server
      stylish-haskell
      implicit-hie
      cabal-install
    ]);
  };
in shell
