{
  pkgs ? import <nixpkgs> {},
}:

let
  nix-store-path = import ./nix-store-path.nix { inherit pkgs; };

in

pkgs.writeShellScriptBin "nix-tag" ''
  function usage() {
    echo 'Usage: $(basename $0) path'
    echo ""
    echo 'DESCRIPTION'
    echo 'Calculates the tag of a given derivation.'
    echo ""
    echo 'EXAMPLE'
    echo 'nix-tag hello-docker.nix'
    echo 'result: iai5rbg321mgbwzigr8q757r61fxb2sn'
    echo ""
    echo 'This is equivalent to doing the following:'
    echo "nix-store-path path | awk -F'[/-]' '{print \$4}'"

    exit $1
  }

  if [ $# -ne 1 ] || [ ! -f "$1" ]; then
    usage 1
  fi

  ${nix-store-path}/bin/nix-store-path $1 | awk -F'[/-]' '{print $4}'
''
