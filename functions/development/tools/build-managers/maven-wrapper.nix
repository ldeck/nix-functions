#
# maven-wrapper: automatically add `-s path/to/nearest/.m2/settings.xml`.
#

{
  pkgs ? import <nixpkgs> {},
  jdk ? pkgs.openjdk11_headless,
  maven ? pkgs.maven.overrideAttrs (oldAttrs: rec {
    inherit jdk;
  }),
  baseDir
}:

let

  find-mvn-settings = pkgs.writeShellScriptBin "find-mvn-settings" ''
    path=${baseDir}
    while [[ $path != / ]]; do
      settings="$path/.m2/settings.xml"
      if [[ -f "$settings" ]]; then
        result=$(readlink -f "$settings")
        echo "$result"
        exit 0
      fi
      path="$(readlink -f "$path"/..)"
    done
  '';

  has-settings-arg = pkgs.writeShellScript "has-settings-arg" ''
    find_settings="false"
    for var in "$@"; do
      case "$var" in
        -s*|--settings) find_settings="true"; break;;
        *) continue;;
      esac
    done
    echo "$find_settings"
  '';

  make-mvn-settings-arg = pkgs.writeShellScript "make-mvn-settings-arg" ''
    has_settings=$(${has-settings-arg} "$@")
    if [ "$has_settings" != "true" ]; then
      SETTINGS_PATH=$(${find-mvn-settings}/bin/find-mvn-settings)
      if [[ ! -z "$SETTINGS_PATH" ]]; then
        echo "-s $SETTINGS_PATH"
      fi
    fi
  '';

  mvn-wrapper = pkgs.writeShellScriptBin "mvn" ''
    export JAVA_HOME=''${JAVA_HOME-'${jdk}'}

    function color() {
      echo -n "$(tput setaf $1)$2$(tput sgr0)"
    }

    SETTINGS_ARG=$(${make-mvn-settings-arg} "$@")
    if [ ! -z "$SETTINGS_ARG" ]; then
      color 7 "["
      color 4 "INFO"
      color 7 "] Use settings: "
      color 2 ''${SETTINGS_ARG:2}
      echo ""
    fi

    exec ${maven}/bin/mvn $SETTINGS_ARG "$@"
  '';

  mvnDebug-wrapper = pkgs.writeShellScriptBin "mvnDebug" ''
    export JAVA_HOME=''${JAVA_HOME-'${jdk}'}

    function color() {
      echo -n "$(tput setaf $1)$2$(tput sgr0)"
    }

    SETTINGS_ARG=$(${make-mvn-settings-arg} "$@")
    if [ ! -z "$SETTINGS_ARG" ]; then
      color 7 "["
      color 4 "INFO"
      color 7 "] Use settings: "
      color 2 ''${SETTINGS_ARG:2}
      echo ""
    fi

    exec ${maven}/bin/mvnDebug $SETTINGS_ARG "$@"
  '';

in pkgs.buildEnv {
  name = "ldeck-maven-${maven.version}";
  paths = [
    find-mvn-settings
    mvn-wrapper
    mvnDebug-wrapper
  ];
  passthru = {
    inherit
      jdk
      maven
      mvn-wrapper
      mvnDebug-wrapper;
  };
}
