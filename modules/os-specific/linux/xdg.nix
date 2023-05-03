{pkgs, ...}: {
  config = {
    xdg.portal.enable = true;

    environment.systemPackages = [pkgs.xdg-user-dirs];
  };
}
