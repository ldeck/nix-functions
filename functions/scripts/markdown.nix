{ pkgs }:

pkgs.emem.overrideAttrs (oldAttrs: rec {
  installPhase = oldAttrs.installPhase + ''
    ln -fs $out/bin/emem $out/bin/markdown
  '';
})
