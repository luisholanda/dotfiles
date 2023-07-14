{lib, ...}: let
  inherit (lib) mkOption types hasSuffix;
in rec {
  mkAttrsOpt = description:
    mkOption {
      inherit description;
      default = {};
      type = types.attrs;
    };
  mkBoolOpt = default: description:
    mkOption {
      inherit description default;
      type = types.bool;
    };
  mkColorValueOpt = prefix: description:
    mkOption {
      inherit description;
      example = "${prefix}424242";
      type = types.strMatching "${prefix}[0-9A-F]{6}";
    };
  mkColorHexValueOpt = mkColorHexValueOpt "#";
  mkColorOpt = {
    description,
    default ? null,
  }:
    mkOption {
      inherit description default;
      type = types.submodule {
        options = {
          hex = mkColorValueOpt "#" "#-started hexadecimal value of this color.";
          plain = mkColorValueOpt "" "plain hexadecimal value of this color.";
          xHex = mkColorValueOpt "0x" "0x-started hexadecimal value of this color.";
          rgb = mkOption {
            description = "RGB components of the color.";
            example = "42,42,42";
          };
        };
      };
    };
  mkCssOpt = with types; let
    cssAttrValue = oneOf [int str (listOf str)];
  in
    {
      description,
      default ? "",
    }:
      mkOption {
        inherit description default;
        type = either str (attrsOf (attrsOf cssAttrValue));
      };
  mkCssFileOpt = mkPathWithExtOpt ".css";
  mkCssFilesOpt = mkPathsWithExtOpt ".css";
  mkEnableOpt = mkBoolOpt false;
  mkPathOpt = description:
    mkOption {
      inherit description;
      type = with types; either str path;
    };
  mkPathWithDefaultOpt = default: description:
    mkOption {
      inherit description default;
      type = with types; either str path;
    };
  mkPathWithExtOpt = ext: description:
    with types;
      mkOption {
        inherit description;
        type = addCheck path (hasSuffix ext);
      };
  mkPathsOpt = description:
    mkOption {
      inherit description;
      type = types.listOf types.path;
    };
  mkPathsWithExtOpt = ext: description:
    with types;
      mkOption {
        inherit description;
        type = addCheck (listOf path) (builtins.all (hasSuffix ext));
      };
  mkPkgOpt = default: name:
    mkOption {
      inherit default;
      type =
        if default == null
        then types.nullOr types.package
        else types.package;
      description = "Package to use for ${name}.";
    };
  mkPkgsOpt = name:
    mkOption {
      default = [];
      type = types.listOf types.package;
      description = "Packages to use for ${name}.";
    };
  mkStrOpt = description:
    mkOption {
      inherit description;
      default = "";
      type = types.str;
    };
}
