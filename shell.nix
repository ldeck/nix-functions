{
  pkgs ? import <nixpkgs> {},
  nix-functions ? import ./default.nix,
}:

let
  nix-store-path = import nix-functions.scripts.nix-store-path { inherit pkgs; };
  nix-tag = import nix-functions.scripts.nix-tag { inherit pkgs; };

in

pkgs.mkShell {
  name = "nix-functions";
  buildInputs = [
    nix-store-path
    nix-tag
  ];
  shellHook = ''
    echo "Welcome to nix-functions"
  '';
}
