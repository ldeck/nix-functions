{ pkgs }:

#
# find-app looks for a macOS application in nix and standard macOS locations:
# ~/.nix-profile/Applications
# ~/.nix-profile/Applications/Utilities
# ~/Applications
# ~/Applications/Utilities
# /Applications
# /Applications/Utilities
# /System/Applications
# /System/Applications/Utilities
#

pkgs.writeShellScriptBin "find-app" ''
  function usage {
    echo "Usage: $(basenaame $0) fuzzyname..."
    exit 1
  }

  LOCATIONS=( "$HOME/.nix-profile/Applications" "$HOME/.nix-profile/Applications/Utilities" "$HOME/Applications" "$HOME/Applications/Utilities" "/Applications" "/Applications/Utilities" "/System/Applications" "/System/Applications/Utilities" )

  #
  # Helper functions
  #
  color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1
  echoerr() { echo "$@" 1>&2; }
  function indented() {
      (set -o pipefail; { "$@" 2>&3 | sed >&2 's/^/   | /'; } 3>&1 1>&2 | perl -pe 's/^(.*)$/\e[31m   | $1\e[0m/')
  }
  function join_by { local d=$1; shift; local f=$1; shift; printf %s "$f" "''${@/#/$d}"; }

  #
  # Begin
  #
  [[ $# -lt 1 ]] && usage

  MATCHER=$(join_by '.*' "$@")
  APP=""

  for l in "''${LOCATIONS[@]}"; do
    if ! [ -d $l ]; then
      continue;
    fi
    NAME=$(ls "$l" | grep -i "$MATCHER")
    COUNT=$(echo "$NAME" | grep -v -e '^$' | wc -l)
    if [[  $COUNT -gt 1 ]]; then
      color echoerr "Matches:"
      indented echoerr "$NAME"
      usage
    fi
    if [[ $COUNT -eq 1 ]]; then
      APP="$l/$NAME"
      break
    fi
  done
  if [ -z "$APP" ]; then
    usage
  else
    echo "$APP"
  fi
''
