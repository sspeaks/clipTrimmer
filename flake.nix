{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = (import ./default.nix) { inherit pkgs; };
        defaultPackage = self.packages.${system}.clipTrimmer;
        devShell =
          (import ./shell.nix) { inherit pkgs; };
        formatter = pkgs.nixpkgs-fmt;
      });
}
