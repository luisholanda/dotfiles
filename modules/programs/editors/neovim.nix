{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge makeBinPath removePrefix;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.my) mkEnableOpt;

  neovimConfigSource = config.dotfiles.configDir + "/nvim";
  neovimConfigSourceContent = [
    "/init.lua"
    "/ftplugin"
    "/lua"
    "/spell"
  ];

  wrappedNeovim = pkgs.neovim-unwrapped.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ config.modules.editors.extraPackages;
  });

  nvimPath = "${makeBinPath [wrappedNeovim]}/nvim";

  cfg = config.modules.editors.neovim;
in {
  options.modules.editors.neovim = {
    enable = mkEnableOpt "Enable Neovim text editor configuration.";
  };

  config = mkIf cfg.enable {
    user.packages = [ wrappedNeovim ];

    user.shellAliases = {
      vi = nvimPath;
      vim = nvimPath;
      vimdiff = "${nvimPath} -d";
    };

    user.sessionVariables.EDITOR = nvimPath;

    user.xdg.configFile = builtins.listToAttrs
      (builtins.map (p: { name = "nvim" + p; value.source = neovimConfigSource + p; }) neovimConfigSourceContent);

    user.xdg.dataFile."nvim/site/pack/packer/start/packer.nvim".source = pkgs.vimPlugins.packer-nvim;
  };
}
