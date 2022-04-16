{pkgs, ...}: {
  config = {
    xdg.portal.enable = true;
    xdg.portal.gtkUsePortal = true;

    environment.systemPackages = [pkgs.xdg-user-dirs];
  };
}
