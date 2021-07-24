{ lib, pkgs, ... }:
let
  inherit (builtins) isList isAttrs concatStringsSep;
  inherit (lib) mapAttrsToList;
in {
  cssOptToStr = css: let
    objAsStr = mapAttrsToList
      (class: attrs: let
        attrsStr = mapAttrsToList (a: v: "${a}: ${valToStr v};") attrs;
        valToStr = v: if isList v
        then concatStringsSep "," (map toString v)
        else toString v;
      in ''
        ${class} {
          ${concatStringsSep "\n" (attrsStr)}
        }
        '') css;
  in if isAttrs css then objAsStr else css;
}
