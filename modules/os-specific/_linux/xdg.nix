{pkgs, ...}: {
  config = {
    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    environment.systemPackages = [pkgs.xdg-user-dirs];
  };
}
