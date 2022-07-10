{lib, ...}: let
  inherit (lib.my) mkBoolOpt;
in {
  options.host.hardware.isLaptop = mkBoolOpt false "Is this host a laptop?";
}
