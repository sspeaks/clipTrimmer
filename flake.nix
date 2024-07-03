{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages =
        (import ./default.nix) { pkgs = nixpkgs.legacyPackages.${system}; };
      defaultPackage = self.packages.${system}.clipTrimmer;
      devShell =
        (import ./shell.nix) { pkgs = nixpkgs.legacyPackages.${system}; };
    });
}
