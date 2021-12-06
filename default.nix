{
  darwin = {
    installers = {
      app = ./functions/darwin/installers/app.nix;
      chromium = ./functions/darwin/installers/chromium.nix;
      eclipseApp = ./functions/darwin/installers/eclipseApp.nix;
      firefox = ./functions/darwin/installers/firefox.nix;
    };
    scripts = {
      enable-sudo-touchid = ./functions/darwin/scripts/enable-sudo-touchid.nix;
      find-app = ./functions/darwin/scripts/find-app.nix;
      idownload = ./functions/darwin/scripts/idownload.nix;
      open-app = ./functions/darwin/scripts/open-app.nix;
    };
  };
  development = {
    tools = {
      build-managers = {
        maven-wrapper = ./functions/development/tools/build-managers/maven-wrapper.nix;
      };
    };
  };
  scripts = {
    jqo = ./functions/utils/jqo.nix;
    markdown = ./functions/utils/markdown.nix;
    nix-store-path = ./functions/nix/nix-store-path.nix;
    nix-tag = ./functions/nix/nix-tag.nix;
    nix-system = ./functions/nix/nix-system.nix;
  };
}
