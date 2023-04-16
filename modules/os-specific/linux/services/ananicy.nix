{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux;
in {
  # The default options don't give us enough control over the rules and types.
  config = mkIf isLinux {
    environment.systemPackages = with pkgs; [ananicy-cpp];
    environment.etc."ananicy.d".source = inputs.cachyos-ananicy-rules.outPath;

    systemd = {
      packages = with pkgs; [ananicy-cpp];
      services.ananicy.wantedBy = ["default.target"];
    };
  };
}
