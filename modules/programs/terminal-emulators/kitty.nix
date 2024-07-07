{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.my) mkEnableOpt;
in {
  options.modules.programs.kitty = {
    enable = mkEnableOpt "Enable the use of kitty terminal emulator.";
  };

  config = mkIf config.modules.programs.kitty.enable {
    user.terminalCmd = "${lib.makeBinPath [pkgs.kitty]}/kitty";
    user.home.extraConfig.stylix.targets.kitty.enable = true;
    user.home.extraConfig.stylix.targets.kitty.variant256Colors = true;
    user.home.programs.kitty = {
      enable = true;

      extraConfig = let
        font_features = let
          sss =
            builtins.concatStringsSep " "
            (map (i: "+ss0${toString i}") (lib.range 1 9));
          styles = [
            "Bold"
            "BoldItalic"
            "ExtraBold"
            "ExtraBoldItalic"
            "ExtraLightItalic"
            "Italic"
            "Light"
            "LightItalic"
            "Medium"
            "MediumItalic"
            "SemiBold"
            "SemiBoldItalic"
            "SemiWideBold"
            "SemiWideBoldItalic"
            "SemiWideExtraBold"
            "SemiWideExtraBoldItalic"
            "SemiWideExtraLight"
            "SemiWideExtraLightItalic"
            "SemiWideItalic"
            "SemiWideLight"
            "SemiWideLightItalic"
            "SemiWideMedium"
            "SemiWideMediumItalic"
            "SemiWideRegular"
            "SemiWideSemiBold"
            "SemiWideSemiBoldItalic"
            "Regular"
            "WideBold"
            "WideBoldItalic"
            "WideExtraBold"
            "WideExtraBoldItalic"
            "WideExtraLight"
            "WideExtraLightItalic"
            "WideItalic"
            "WideLight"
            "WideLightItalic"
            "WideMedium"
            "WideMediumItalic"
            "WideRegular"
            "WideSemiBold"
            "WideSemiBoldItalic"
          ];
          font-name = builtins.replaceStrings [" "] [""] config.stylix.fonts.monospace.name;
        in
          builtins.concatStringsSep "\n" (builtins.map (s: "font_features ${font-name}-${s} +calt +liga ${sss}") styles);
      in ''
        modify_font cell_height 1px
        ${font_features}
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
        hide_window_decorations = true;
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
