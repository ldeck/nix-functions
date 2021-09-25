{ pkgs }:

# About jqo:
# Useful for piping stdout that contains JSON.
# JQO will parse the piped output, and push non-JSON to stdout
# It'll push JSON output through jq to format it nicely.

let
  jq = pkgs.jq;
in
pkgs.writeShellScriptBin "jqo" ''
  ${jq}/bin/jq -R -r 'capture("(?<prefix>[^{]*)(?<json>{.+})?(?<suffix>.*)") |\
  .prefix,(.json|try fromjson catch ""),.suffix | select(length > 0)'
''
