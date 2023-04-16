{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf makeBinPath;
  inherit (lib.my) mkEnableOpt wrapProgram;

  neovimConfigSource = config.dotfiles.configDir + "/neovim";

  extraPackages = config.modules.editors.extraPackages ++ [pkgs.zig];

  wrappedNeovim = wrapProgram pkgs.neovim-unwrapped {
    prefix.PATH = makeBinPath extraPackages;
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

    user.sessionVariables.EDITOR = nvimPath;

    user.xdg.configFile.nvim = {
      recursive = true;
      source = inputs.nvchad;
    };
    user.xdg.configFile."nvim/lua/custom".source = neovimConfigSource;
  };
}
