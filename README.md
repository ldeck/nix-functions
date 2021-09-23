# nix-functions

Various useful nix function derivations

## Overview ##

### macOS ###

#### app ####

Installer function for a macOS app using dmg or zip.

Example usage:

    pkgs.callPackage functions.macOS.app rec {
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

#### eclipseApp ####

A minor variation on the app function aimed at eclipse based applications.

Example usage:

    pkgs.callPackage functions.macOS.eclipseApp rec {
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

#### chromium ####

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

    chrome = pkgs.callPackage functions.macOS.chromium {
      inherit
        pkgs
        chromeSpec
    };
