{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.my) mkEnableOpt isLinux;
in {
  options.modules.programs.kitty = {
    enable = mkEnableOpt "Enable the use of kitty terminal emulator.";
  };

  config = mkIf config.modules.programs.kitty.enable {
    user.terminalCmd = "${lib.makeBinPath [pkgs.kitty]}/kitty";
    user.home.extraConfig.stylix.targets.kitty.variant256Colors = true;
    user.home.programs.kitty = {
      enable = true;

      extraConfig = ''
        modify_font cell_height 1px
      '';

      settings = {
        disable_ligatures = "cursor";
        scroll_back_lines = 3000;
        url_style = "single";
        copy_on_select = true;
        strip_trailing_spaces = "smart";
        focus_follows_mouse = true;
        repaint_delay = 3;
        enable_audio_bell = false;
        hide_window_decorations = isLinux;
        resize_draw_strategy = "scale";
        tab_bar_style = "separator";
        tab_separator = " |";
        tab_title_template = "{index}: {title}";
        update_check_interval = 0;
        macos_show_window_title_in = "menubar";
        kitty_mod = "ctrl+shift";
      };
    };
  };
}
