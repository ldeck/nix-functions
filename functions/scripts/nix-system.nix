{ pkgs }:

# Helps with nix issues to print the required info about your nix installation

let
  command = ''nix-shell -p nix-info --run "nix-info -m"'';

in

pkgs.writeShellScriptBin "nix-system" ''
  echo '${command}'
  ${command}
''
