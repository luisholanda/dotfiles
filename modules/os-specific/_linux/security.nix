{config, ...}: {
  config = {
    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [config.user.name];
          persist = true;
          # This is not thats secure, but don't having this is a PITA.
          keepEnv = true;
        }
      ];
    };

    security.protectKernelImage = !config.host.hardware.isLaptop;
    security.rtkit.enable = true;
    security.sudo.enable = !config.security.doas.enable;

    security.allowUserNamespaces = true;

    boot.kernel.sysctl."kernel.yama.ptrace_scope" = 1;
  };
}
