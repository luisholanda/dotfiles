{
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.lib) mkEnableOption mkIf;
  inherit (pkgs.stdenv) isDarwin;
  inherit (config.modules.services.audio) spotify;

  spotifyd = pkgs.spotifyd.override {withMpris = true;};

  configFile = (pkgs.formats.toml {}).generate "spotifyd.conf" {
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

  mkIfEnabled = mkIf spotify.enable;
in {
  options.modules.services.audio.spotify.enable = mkEnableOption "spotifyd";

  config = {
    user.home.extraConfig.systemd.user.services.spotifyd = mkIfEnabled {
      Unit = {
        Description = "spotify daemon";
        Documentation = "https://github.com/Spotifyd/spotifyd";
      };

      Install.WantedBy = ["default.target"];

      Service = {
        ExecStart = "${spotifyd}/bin/spotifyd --no-daemon --config-path ${configFile}";
        Restart = "always";
        RestartSec = 12;
      };
    };

    user.home.services.playerctld.enable = spotify.enable;

    user.packages = mkIfEnabled [pkgs.spotify-tui];
  };
}
