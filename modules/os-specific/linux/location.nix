{lib, ...}: {
  config.location.provider = lib.mkForce "geoclue2";
}
