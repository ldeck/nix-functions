{
  pkgs ? import <nixpkgs> {},
  name ? "chromium-with-driver",
  platform,
  basePosition,
  system,
  browserGeneration,
  browserSha256,
  driverGeneration,
  driverSha256,
  version,
}:
with pkgs;

let
  mkChromiumUrl =
    { platform, basePosition, archivename, generation, sha256, version, ... }: fetchurl {
      url = "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/${platform}%2F${basePosition}%2F${archivename}.zip?generation=${generation}&alt=media";
      sha256 = sha256;

      # override name because the basename for this image has forbidden characters
      name = "${sha256}-${version}-${archivename}.zip";
    };

  chromedriver = stdenv.mkDerivation rec {
    name = "chromedriver-${version}";
    version = version;
    src = mkChromiumUrl {
      platform = platform;
      basePosition = basePosition;
      archivename = "chromedriver_${system}";
      generation = driverGeneration;
      sha256 = driverSha256;
      version = version;
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
           then (installCustomApplication rec {
             name = "Chromium";
             version = version;
             sourceRoot = "chrome-mac/${name}.app";
             src = mkChromiumUrl {
               platform = platform;
               basePosition = basePosition;
               archivename = "chrome-mac";
               generation = browserGeneration;
               sha256 = browserSha256;
               version = version;
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
