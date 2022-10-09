{lib, ...}: let
  inherit (builtins) substring stringLength hasAttr;
  inherit (lib) toUpper toInt;

  # Yes, I know, this is a shitty way of doing hex -> dec
  # conversion. I don't care.
  intFromHex = hex: let
    h = toUpper (substring 0 1 hex);
    hMap = {
      "A" = 10;
      "B" = 11;
      "C" = 12;
      "D" = 13;
      "E" = 14;
      "F" = 15;
    };

    hVal =
      if hasAttr h hMap
      then hMap.${h}
      else toInt h;

    rest = intFromHex (substring 1 (stringLength hex - 1) hex);
  in
    if hex == ""
    then 0
    else if stringLength hex > 1
    then 16 * hVal + rest
    else hVal;
in {
  mkColor = hex: let
    plain = substring 1 (stringLength hex) hex;
    r = intFromHex (substring 0 2 plain);
    g = intFromHex (substring 2 2 plain);
    b = intFromHex (substring 4 2 plain);
  in {
    inherit hex plain;
    xHex = "0x${plain}";
    rgb = builtins.concatStringsSep "," (map toString [r g b]);
  };
}
