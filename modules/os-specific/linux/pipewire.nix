{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.stdenv) isLinux;

  json = pkgs.formats.json {};

  quantum = 64;
  rate = 96000;
in {
  options.modules.services.pipewire.enable = mkEnableOption "pipewire";

  config = mkIf isLinux {
    services.pipewire = {
      inherit (config.modules.services.pipewire) enable;

      pulse.enable = true;
      jack.enable = false;
      alsa.enable = true;
    };

    user.home.services.easyeffects.enable = true;

    environment.etc = {
      "pipewire/pipewire.d/99-lowlatency.conf".source = json.generate "99-lowlatency.conf" {
        context.properties.default.clock.min-quantum = quantum;
      };
      "pipewire/pipewire-pulse.d/99-lowlatency.conf".source = let
        qr = "${toString quantum}/${toString rate}";
      in
        json.generate "99-lowlatency.conf" {
          context.modules = [
            {
              name = "libpipewire-module-rtkit";
              args = {
                nice.level = -15;
                rt.prio = 88;
                rt.time.soft = 200000;
                rt.time.hard = 200000;
              };
              flags = ["ifexists" "nofail"];
            }
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                pulse.min.req = qr;
                pulse.min.quantum = qr;
                pulse.min.frag = qr;
                server.address = ["unix:native"];
              };
            }
          ];

          stream.properties = {
            node.lowlatency = qr;
            resample.quanlity = 1;
          };
        };

      "wireplumber/main.lua.d/99-alsa-lowlatency.lua".text = ''
        alsa_monitor.rules = {
          {
            matches = {{{ "node.name", "matches", "alsa_output.*" }}};
            apply_properties = {
              ["audio.format"] = "S32LE",
              ["audio.rate"] = ${toString (rate * 2)},
              ["api.alsa.period-size"] = 2,
            },
          },
        }
      '';
    };
  };
}
