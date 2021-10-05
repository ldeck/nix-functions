# nix-functions

Various useful nix and shell function derivations.

## Quick start ##

    niv add ldeck/nix-functions --name ldeck-functions

## Functions overview ##

All the following examples assume you've imported ldeck/nix-functions as `functions`.

Assuming you're using [niv](https://github.com/nmattia/niv), for example:

    {
      pkgs ? import (import ./nix/sources.nix).nixpkgs {},
      functions ? import (import ./nix/sources.nix).ldeck-functions,
    }:
    ...

### `darwin.installers` ###

#### `darwin.installers.app` ####

Installer function for a macOS app using dmg or zip.

Example usage:

    pkgs.callPackage functions.darwin.installers.app rec {
      name = "Firefox";
      sourceRoot = "Firefox.app";
      version = "92.0";
      src = pkgs.fetchurl {
        url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox+${version}.dmg";
        sha256 = "0kln28330jhmpdvsdsnrqnl0fkpb18i9vi1n98v99aq61ncqr5v8";
        name = "Firefox-${version}.dmg";
      };
      description = "The Firefox web browser";
      homepage = https://www.mozilla.org/en-US/firefox/;
      appcast = https://www.mozilla.org/en-US/firefox/releases/;
    };

#### `darwin.installers.chromium` ####

Builds the macOS Chromium and chromedriver for the given chromeSpec.

Example usage:

    let
      chromeSpec = rec {
        version = "86.0.4240.111";
        x86_64-linux = {
          basePosition = "todo";
          platform = "Linux";
          system = "linux64";
          browserGeneration = "todo";
          browserSha256 = lib.fakeSha256;
          driverGeneration = "todo";
          driverSha256 = lib.fakeSha256;
          version = version;
        };

        x86_64-darwin = {
          basePosition = "800208";
          platform = "Mac";
          system = "mac64";
          browserGeneration = "1597949046060527";
          browserSha256 = "02ssw8gwk38pj5r1yk0zz3rph93k63c20390x4v5g9wpyp8rzx56";
          driverGeneration = "1597949061202635";
          driverSha256 = "13r70wha4pzpk57g25wvxhi794xqydvncjny3vmx1sxx48r33ywr";
          version = version;
        };
      }.${stdenv.hostPlatform.system}
        or (throw "missing chrome platform spec for ${stdenv.hostPlatform.system}");

    chrome = pkgs.callPackage functions.darwin.installers.chromium {
      inherit
        pkgs
        chromeSpec
    };

#### `darwin.installers.eclipseApp` ####

A minor variation on the app function aimed at eclipse based applications.

Example usage:

    pkgs.callPackage functions.darwin.installers.eclipseApp rec {
      name = "MAT";
      sourceRoot = "mat.app";
      mainVersion = with lib.versions; (majorMinor cfg.version) + "." + (patch cfg.version);
      version = cfg.version;
      src = pkgs.fetchurl {
        url = "https://www.eclipse.org/downloads/download.php?r=1&file=/mat/${mainVersion}/rcp/MemoryAnalyzer-${version}-macosx.cocoa.${cfg.arch}.dmg";
        sha256 = cfg.sha256;
      };
      description = "The Eclipse Memory Analyzer is a fast and feature-rich Java heap analyzer that helps you find memory leaks and reduce memory consumption.";
      homepage = "https://www.eclipse.org/mat/";
      appcast = "https://www.eclipse.org/mat/downloads.php";
    };

### `darwin.scripts` ###

#### `darwin.scripts.enable-sudo-touchid` ####

If you have a Macbook Pro with Touch ID capabilities, you can enable the use of Touch ID to authenticate sudo.

Example usage:

    let
      enable-sudo-touchid = builtins.callPackage functions.darwin.scripts.enable-sudo-touchid { inherit pkgs; };
    in pkgs.buildEnv {
      ...
      paths = [ enable-sudo-touchid ];
    }

#### `darwin.scripts.find-app` ####

A script using fuzzy matching to find the path to an app.

Usage: find-app fuzzyname...

It will look in the following locations L for $L/Applications and $L/Applications/Utilities until a match is found or display the script usage.

1. ~/.nix-profile/
1. ~/
1. /
1. /System

To add this to your packages:

    let
      find-app = builtins.callPackage functions.darwin.scripts.find-app { inherit pkgs; };
    in pkgs.buildEnv {
      ...
      paths = [ find-app ];
    }

#### `darwin.scripts.idownload` ####

A script to resolve icloud drive offloaded files.

See my stackexchange answer for a full explanation: https://apple.stackexchange.com/a/387727/231150

**Usage**: `idownload <file|dir>`

Add it to your packages:

    let
      idownload = builtins.callPackage functions.darwin.scripts.idownload { inherit pkgs; };
    in pkgs.buildEnv {
      ...
      paths = [ idownnload ];
    }

#### `darwin.scripts.open-app` ####

macOS has a really useful `open` utility. But apps installed by nix aren't found in spotlight indexed locations.

This script fills that gap by opening any app, whether installed by nix or not, and providing option args.

**Usage:** `open-app fuzzyname [app-args...]`
       `open-app "fuzzy name..." [app-args]`

Add it to your packages:

    let
      open-app = builtins.callPackage functions.darwin.scripts.open-app { inherit pkgs; };
    in pkgs.buildEnv {
      ...
      paths = [ open-app ];
    }

Dependencies:
- functions.darwin.scripts.find-app

## development ##

### tools ###

#### build-managers ####

##### maven-wrapper #####

This maven wrapper provides `mvn` and `mvnDebug` wrappers for the nixpkgs.maven executables that automatically adds a `-s path/to/nearest/.m2/settings.xml` argument to `mvn` and `mvnDebug` if such a settings.xml file exists.

This is useful for being able to independently control the version of maven used for a project whilst sharing a corporate `settings.xml ` from a parent dir.

It does so by searching from the provided `baseDir` upwards until `/` for a relative path `.m2/settings.xml` to exist for a parent dir. If none exists, the end result is exactly the same as calling the underlying `mvn` executable.

NB: you can still specifically pass `-s path/to/another/settings.xml` or the long form equivalent `--settings` to override this as needed.

Add it to your packages:

    let
      maven-wrapper = builtins.callPackage functions.development.tools.build-managers.maven-wrapper {
        inherit pkgs;
      };
    in pkgs.buildEnv {
      ...
      paths = [ maven-wrapper ];
    }

**Module arguments:**
- pkgs (optional)
- jdk (optional)
- maven (optional)
- baseDir (required)


## `scripts` ##

### `scripts.jqo` ###

The [jq](https://stedolan.github.io/jq/) utility is very useful for parsing and formatting JSON.

Piping standard output to `jqo` allows for piping JSON to jq and non-JSON to stdout.

Add it to your packages:

    let
      jqo = builtins.callPackage functions.scripts.jqo { inherit pkgs; };
    in pkgs.buildEnv {
      ...
      paths = [ jqo ];
    }

### `scripts.markdown` ###

This installs the nixpkgs.emem trivial markdown to html converter, providing a 'markdown' alias.

Add it to your packages:

    let
      markdown = builtins.callPackage functions.scripts.markdown { inherit pkgs; };
    in pkgs.buildEnv {
      ...
      paths = [ markdown ];
    }

### `scripts.nix-store-path` ###

Calculates the resulting store path for a given nix file.

    nix-store-path hello-docker.nix
    --> /nix/store/iai5rbg321mgbwzigr8q757r61fxb2sn-docker-image-hello-docker.tar.gz

Add it to your shell:

    let
        nix-store-path = import functions.scripts.nix-store-path { inherit pkgs; };
    in pkgs.mkShell {
      buildInputs = [ nix-store-path ]
    }

### `scripts.nix-system` ###

Raising issues for nix-community repositories often requires running the following:

    nix-shell -p nix-info --run "nix-info -m"

nix-system does this for you.

    let
      nix-system = builtins.callPackage functions.scripts.nix-system { inherit pkgs; };
    in pkgs.buildEnv {
      ...
      paths = [ nix-system ];
    }

### `scripts.nix-tag` ###

Calculates the nix store tag part of a derivation's name.
This equates to the same tag automatically calculated as a docker image built with nix.

    nix-tag hello-docker.nix
    --> iai5rbg321mgbwzigr8q757r61fxb2sn

Add nix-tag to your shell:

    let
        nix-tag = import functions.scripts.nix-tag { inherit pkgs; };
    in pkgs.mkShell {
      buildInputs = [ nix-tag ]
    }
