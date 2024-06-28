{pkgs, ...}: {
  config = {
    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    xdg.portal.extraPortals = with pkgs.unstable; [xdg-desktop-portal-gtk];
    environment.systemPackages = [pkgs.xdg-user-dirs];
  };
}
