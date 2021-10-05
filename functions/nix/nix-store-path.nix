{
  pkgs ? import <nixpkgs> {},
}:

pkgs.writeShellScriptBin "nix-store-path" ''
  function usage() {
    echo "Usage: $(basename $0) path"
    echo ""
    echo 'DESCRIPTION'
    echo 'Calculates the store path of the given derivation.'
    echo ""
    echo 'EXAMPLE'
    echo 'nix-store-path hello-docker.nix'
    echo 'result: /nix/store/iai5rbg321mgbwzigr8q757r61fxb2sn-docker-image-hello-docker.tar.gz'
    echo ""
    echo 'This is equivalent to doing the following:'
    echo 'nix-store -q --outputs $(nix-instantiate path --quiet --quiet)'

    exit $1
  }

  if [ $# -ne 1 ] || [ ! -f "$1" ]; then
    usage 1
  fi

  nix-store -q --outputs $(nix-instantiate $1 --quiet --quiet)
''
