{ ... }:
let
  inherit (builtins) substring stringLength;
in {
  mkColor = hex:
  let plain = substring 1 (stringLength hex) hex;
  in {
    inherit hex plain;
    xHex = "0x${plain}";
  };
}
