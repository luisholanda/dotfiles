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

    security.protectKernelImage = true;
    security.rtkit.enable = true;
    security.sudo.enable = !config.security.doas.enable;
  };
}
