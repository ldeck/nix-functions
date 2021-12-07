{
  pkgs ? import <nixpkgs> {},
  version,
  sha256,
  stdenv,
  fetchurl,
  undmg,
}:

with pkgs;

let
  browserVersion = version;
  browserSha256 = sha256;

in

stdenv.mkDerivation rec {
  pname = "Firefox";
  version = browserVersion;

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
      mkdir -p "$out/Applications"
      cp -r Firefox.app "$out/Applications/Firefox.app"
    '';

  src = fetchurl {
    name = "Firefox-${version}.dmg";
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-GB/Firefox%20${version}.dmg";
    sha256 = browserSha256;
  };

  meta = with lib; {
    description = "The Firefox web browser";
    homepage = "https://www.mozilla.org/en-GB/firefox";
    maintainers = [ "ldeck" ];
    platforms = platforms.darwin;
  };
}
