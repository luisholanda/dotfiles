{
  inputs,
  lib,
  pkgs,
  system,
  ...
}: let
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  modules = import ./modules.nix {
    inherit lib system;
    self.attrs = import ./attrs.nix {
      inherit lib system;
      self = {};
    };
  };

  mylib = makeExtensible (self:
    mapModules ./.
    (file: import file {inherit self lib pkgs inputs system;}));
in
  mylib.extend (_self: super: foldr (a: b: a // b) {} (attrValues super))
