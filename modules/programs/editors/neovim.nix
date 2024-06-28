{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf makeBinPath;
  inherit (lib.my) mkEnableOpt wrapProgram;

  neovimConfigSource = config.dotfiles.configDir + "/neovim";

  extraPackages =
    config.modules.editors.extraPackages
    ++ (with pkgs; [zig nodejs_20 unstable.codeium]);

  wrappedNeovim = wrapProgram pkgs.neovim-unwrapped {
    suffix.PATH = makeBinPath extraPackages;
  };

  nvimPath = "${makeBinPath [wrappedNeovim]}/nvim";

  cfg = config.modules.editors.neovim;
in {
  options.modules.editors.neovim = {
    enable = mkEnableOpt "Enable Neovim text editor configuration.";
  };

  config = mkIf cfg.enable {
    user.packages = [wrappedNeovim];

    user.shellAliases.vimdiff = "${nvimPath} -d";
    user.shellAliases.vi = nvimPath;
    user.shellAliases.vim = nvimPath;

    user.sessionVariables.EDITOR = "nvim";

    user.xdg.configFile.nvim.source = neovimConfigSource;
    user.xdg.configFile.nvim.recursive = true;
  };
}
