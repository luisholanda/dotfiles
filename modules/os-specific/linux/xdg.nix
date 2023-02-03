{pkgs, ...}: {
  config = {
    xdg.portal.enable = true;

    xdg.portal.wlr.enable = true;
    xdg.portal.wlr.settings = {
      screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };

    environment.systemPackages = [pkgs.xdg-user-dirs];
  };
}
