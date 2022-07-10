{
  config = {
    services.chrony = {
      enable = true;
      enableNTS = true;
    };
    services.localtime.enable = true;
    networking.timeServers = [
      # Start with Brazil-hosted NTP servers
      "a.st1.ntp.br"
      "b.st1.ntp.br"
      "c.st1.ntp.br"
      "d.st1.ntp.br"
      "gps.ntp.br"
      # Use Cloudflare as backup
      "time.cloudflare.com"
    ];
  };
}
