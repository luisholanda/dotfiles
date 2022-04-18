{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.stdenv) isLinux;
in {
  options.modules.services.pipewire.enable = mkEnableOption "pipewire";

  config.services.pipewire = mkIf isLinux {
    inherit (config.modules.services.pipewire) enable;

    config.pipewire = {
      context.modules = [
        {
          name = "libpipewire-module-client-device";
        }
        {
          flags = ["ifexists" "nofail"];
          name = "libpipewire-module-portal";
        }
        {
          args = {};
          name = "libpipewire-module-access";
        }
        {
          name = "libpipewire-module-adapter";
        }
        {
          name = "libpipewire-module-filter-chain";
          args = {
            node.name = "rnnoise_source";
            node.description = "Noise Canceling source";
            media.name = "Noise Canceling sourcel";

            filter.graph.nodes = [
              {
                type = "ladpsa";
                name = "rnnoise";
                plugin = "${pkgs.rnnoise-plugin}/lib/ladpsa/librnnoise_ladpsa";
                control."VAD Threshold (%)" = 50.0;
              }
            ];

            capture.props.node.passivce = true;
            playback.props.media.class = "Audio/Source";
          };
        }
        {
          name = "libpipewire-module-link-factory";
        }
        {
          name = "libpipewire-module-session-manager";
        }
      ];
    };

    pulse.enable = true;
    jack.enable = false;
    alsa.enable = true;
  };
}
