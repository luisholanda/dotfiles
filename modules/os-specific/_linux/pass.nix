{pkgs, ...}: {
  config.user.home.programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [exts.pass-import]);
  };
}
