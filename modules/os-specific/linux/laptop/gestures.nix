{ config, lib, pkgs, ... }: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  inherit (lib.my) mkStrOpt;
  inherit (config.host.hardware) isLaptop;
  inherit (config.host.laptop) gestures;

  configFile = with gestures; pkgs.writeText "libinput-gestures.conf" ''
    gesture swipe left  3 ${goBack}
    gesture swipe right 3 ${goForward}

    gesture swipe left  4 ${prevWorkspace}
    gesture swipe right 4 ${nextWorkspace}
  '';
in {
  options.host.laptop.gestures = {
    nextWorkspace = mkStrOpt "Command that goes to the next workspace";
    prevWorkspace = mkStrOpt "Command that goes to the prev workspace";
    goBack = mkStrOpt "Command that goes back";
    goForward = mkStrOpt "Command that goes forward";
  };

  config = mkIf isLaptop {
    systemd.user.services.libinput-gestures = {
      description = "Action gestures on your touchpad using libinput";
      path = with pkgs; [ libinput-gestures ];
      script = "libinput-gestures --conffile=${configFile}";
      wantedBy = [ "graphical-session.target" ];
    };

    systemd.services.ydotoold = {
      path = with pkgs; [ ydotool ];
      script = "ydotoold --socket-perm 0622";
      wantedBy = [ "graphical-session.target" ];
    };
  };
}
