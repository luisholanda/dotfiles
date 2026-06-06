{pkgs, ...}: {
  config.user.home.programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [exts.pass-import]);
    settings.PASSWORD_STORE_DIR = "$XDG_DATA_HOME/password-store";
  };
}
