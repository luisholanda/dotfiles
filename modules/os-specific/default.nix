{lib, ...}: let
  inherit (lib) optionals;
  inherit (lib.my) mapModulesRec' isLinux;
in {
  imports = optionals isLinux (mapModulesRec' ./_linux import);
}
