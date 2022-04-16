{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.my) mkEnableOpt mkBoolOpt;

  cfg = config.modules.programs.ssh;
in {
  options.modules.programs.ssh = {
    enable = mkEnableOpt "Enable SSH client configuration.";
    agent.enable = mkBoolOpt true "Enable ssh-agent configuration.";
  };

  config = {
    user.home.programs.ssh = {
      inherit (cfg) enable;

      forwardAgent = true;
      compression = true;
      serverAliveInterval = 30;
      serverAliveCountMax = 5;
      hashKnownHosts = true;
      controlMaster = "auto";
    };

    programs.ssh.startAgent = cfg.agent.enable;

    user.sessionVariables.SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent";
  };
}
