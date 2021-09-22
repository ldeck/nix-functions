# chromeSpec = rec {
#   basePosition = "800208";
#   platform = "Mac";
#   system = "mac64";
#   browserGeneration = "1597949046060527";
#   browserSha256 = "02ssw8gwk38pj5r1yk0zz3rph93k63c20390x4v5g9wpyp8rzx56";
#   driverGeneration = "1597949061202635";
#   driverSha256 = "13r70wha4pzpk57g25wvxhi794xqydvncjny3vmx1sxx48r33ywr";
#   version = version;
# }

{
  pkgs ? import <nixpkgs> {},
  name ? "chromium-with-driver",
  chromeSpec
}:
with pkgs;

# NB: it's painful finding the matching versions
# https://www.chromium.org/getting-involved/download-chromium
# https://chromedriver.chromium.org/getting-started
# https://chromedriver.chromium.org/downloads

let
  mkChromiumUrl =
    { platform, basePosition, archivename, generation, sha256, version, ... }: fetchurl {
      url = "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/${platform}%2F${basePosition}%2F${archivename}.zip?generation=${generation}&alt=media";
      sha256 = sha256;

      # override name because the basename for this image has forbidden characters
      name = "${sha256}-${version}-${archivename}.zip";
    };

  chromedriver = stdenv.mkDerivation rec {
    name = "chromedriver-${chromeSpec.version}";
    version = chromeSpec.version;
    src = mkChromiumUrl {
      platform = chromeSpec.platform;
      basePosition = chromeSpec.basePosition;
      archivename = "chromedriver_${chromeSpec.system}";
      generation = chromeSpec.driverGeneration;
      sha256 = chromeSpec.driverSha256;
      version = chromeSpec.version;
    };
    nativeBuildInputs = [ unzip ];
    buildInputs = [ unzip ];
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p "$out/bin"
      cp -p * "$out/bin/"
    '';
  };

  chrome = if (stdenv.isDarwin)
           then (pkgs.callPackage ./app.nix rec {
             name = "Chromium";
             version = chromeSpec.version;
             sourceRoot = "chrome-mac/${name}.app";
             src = mkChromiumUrl {
               platform = chromeSpec.platform;
               basePosition = chromeSpec.basePosition;
               archivename = "chrome-mac";
               generation = chromeSpec.browserGeneration;
               sha256 = chromeSpec.browserSha256;
               version = chromeSpec.version;
             };
             description = "Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all Internet users to experience the web.";
             homepage = "https://chromium.org/Home";
             appcast = "https://chromiumdash.appspot.com/releases?platform=Mac";
             relpath = "Applications/Chromium.app/Contents/MacOS/Chromium";
           })
           else
             pkgs.chromium.overrideAttrs(oldAttrs: rec {
               relpath = "chrome";
               # TODO
             });

  chrome-wrapper = writeShellScriptBin "chrome-wrapper" ''
    exec "${chrome}/${chrome.relpath}"
  '';

in buildEnv {
  name = name;
  buildInputs = [
    chrome
    chromedriver
    chrome-wrapper
  ];
}
