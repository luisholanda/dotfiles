{
  lib,
  system,
  ...
}: let
  inherit (lib) hasSuffix optionals;
  inherit (lib.my) mapModulesRec';

  isLinux = hasSuffix "-linux" system;
in {
  imports = optionals isLinux (mapModulesRec' ./_linux import);
}
