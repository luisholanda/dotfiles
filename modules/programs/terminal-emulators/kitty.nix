{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (lib.my) mkEnableOpt;
  inherit (config.theme) colors fonts;

  defaultMonospace = builtins.head config.fonts.fontconfig.defaultFonts.monospace;

  # Kitty use the same indexing as console for colors.
  colorAttrs = lib.pipe config.console.colors [
    (lib.imap0 (i: c: {
      name = "color${builtins.toString i}";
      value = "#" + c;
    }))
    builtins.listToAttrs
  ];
in {
  options.modules.programs.kitty = {
    enable = mkEnableOpt "Enable the use of kitty terminal emulator.";

    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra configurations to add to kitty terminal emulator.";
    };
  };

  config = mkIf config.modules.programs.kitty.enable {
    user.terminalCmd = "${lib.makeBinPath [pkgs.kitty]}/kitty";
    user.home.programs.kitty = {
      enable = true;

      font.name = defaultMonospace;
      font.size = builtins.floor fonts.size.text;

      settings =
        {
          disable_ligatures = "cursor";
          scroll_back_lines = 3000;
          url_style = "single";
          copy_on_select = true;
          strip_trailing_spaces = "smart";
          focus_follows_mouse = true;
          repaint_delay = 3;
          enable_audio_bell = false;
          window_border_width = 2;
          window_padding_width = 2;
          hide_window_decorations = true;
          resize_draw_strategy = "scale";
          tab_bar_style = "separator";
          tab_separator = " |";
          tab_title_template = "{index}: {title}";
          update_check_interval = 0;
          macos_show_window_title_in = "menubar";
          kitty_mod = "ctrl+shift";

          wayland_titlebar_color = "background";

          foreground = colors.foreground.hex;
          background = colors.background.hex;

          selection_foreground = colors.background.hex;
          selection_background = colors.foreground.hex;
        }
        // config.modules.programs.kitty.extraSettings
        // colorAttrs;
    };
  };
}
