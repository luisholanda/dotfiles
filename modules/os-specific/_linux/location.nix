{lib, ...}: let
  inherit (lib) mkForce;
in {
  config = {
    location.provider = mkForce "geoclue2";

    services.geoclue2.enable = true;
    services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";
  };
}
