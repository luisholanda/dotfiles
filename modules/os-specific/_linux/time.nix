{
  config = {
    # Workaround for NixOS/nixpkgs#67673 and NixOS/nixpkgs#68489
    time.timeZone = "America/Sao_Paulo";
    services.chrony = {
      enable = true;
      enableNTS = true;
    };
    services.localtimed.enable = true;
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
