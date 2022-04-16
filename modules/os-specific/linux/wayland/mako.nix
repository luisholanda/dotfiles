{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.my) mkEnableOpt;
  inherit (config.theme) colors;

  uiFont = builtins.head config.fonts.fontconfig.defaultFonts.sansSerif;
  uiSize = config.theme.fonts.size.ui;
in {
  options.modules.services.mako = {
    enable = mkEnableOpt "Enable mako notification daemon.";
  };

  config = mkIf config.modules.services.mako.enable {
    user.home.programs.mako = {
      enable = true;
      maxVisible = 3;
      layer = "overlay";
      font = "${uiFont} ${builtins.toString uiSize}";
      backgroundColor = colors.background.hex;
      textColor = colors.foreground.hex;
      # TODO: These should be moved to a theme config.
      borderSize = 0;
      progressColor = "over ${colors.normal.blue.hex}";
      defaultTimeout = 1500;
      width = 420;
    };

    user.home.extraConfig.wayland.windowManager.sway.config.startup = [{command = "exec mako";}];
  };
}
