{config, ...}: {
  config = {
    services.locate.enable = true;
    services.locate.interval = "hourly";
  };
}
