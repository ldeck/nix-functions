{ pkgs }:

let
  perl = pkgs.perl;

in

pkgs.writeShellScriptBin "idownload" ''
  if [ "$#" -ne 1 ] || ! [ -e $1 ]; then
    echo "Usage: idownload <file|dir>";
    return 1;
  fi
  find . -name '.*icloud' |\
  ${perl}/bin/perl -pe 's|(.*)/.(.*).icloud|$1/$2|s' |\
  while read file; do brctl download "$file"; done
''
