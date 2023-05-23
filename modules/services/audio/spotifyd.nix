{
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.lib) mkEnableOption mkIf;
  inherit (pkgs.stdenv) isDarwin;
  inherit (config.modules.services.audio) spotify;
in {
  options.modules.services.audio.spotify.enable = mkEnableOption "spotifyd";

  config = {
    user.home.services.spotifyd.enable = spotify.enable;
    user.home.services.spotifyd.package = pkgs.spotifyd.override {withMpris = true;};
    user.home.services.spotifyd.settings = {
      global = {
        username = "luiscmholanda";
        password_cmd = "PASSWORD_STORE_DIR=~/.local/share/password-store ${pkgs.pass-wayland}/bin/pass spotify";
        use_mpris = true;
        dbus_type = "session";
        backend =
          if isDarwin
          then "portaudio"
          else "alsa";
        device = "default";
        volume_controller =
          if isDarwin
          then "softvol"
          else "alsa";
        device_name = "Spotifyd";
        bitrate = 320;
        cache_path = "${config.user.home.dir}/.cache/spotifyd";
        initial_volume = "50";
        volume_normalisation = true;
        autoplay = true;
        device_type = "computer";
      };
    };
    user.home.services.playerctld.enable = spotify.enable;

    user.packages = mkIf spotify.enable [pkgs.spotify-tui];
  };
}
