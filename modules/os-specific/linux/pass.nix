{pkgs, ...}: let
  inherit (pkgs.lib) mkIf;
  inherit (pkgs.stdenv) isLinux;
in {
  config.user.home.programs.password-store = mkIf isLinux {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [exts.pass-import]);
  };
}
