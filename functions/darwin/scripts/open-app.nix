{ pkgs }:

let
  find-app = builtins.callPackage ./find-app.nix { inherit pkgs; };

in

pkgs.writeShellScriptBin "open-app" ''
  function usage {
    echo "Usage: $(basename $0) fuzzyappname [args...]"
    echo         $(basename $0) "fuzzy app name" [args...]"
    exit 1
  }
  [[ $# -lt 1 ]] && usage

  IFS=', ' read -r -a APPFUZZIES <<< "$1"
  shift

  APP=$(${find-app}/bin/find-app "''${APPFUZZIES[@]}")

  if [ -z "$APP" ]; then
    usage
  else
    open -a "$APP" "$@"
  fi
''
