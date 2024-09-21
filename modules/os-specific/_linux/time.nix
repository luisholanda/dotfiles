{
  config = {
    # Workaround for NixOS/nixpkgs#67673 and NixOS/nixpkgs#68489
    time.timeZone = "America/Sao_Paulo";
    services.chrony = {
      enable = true;
      autotrimThreshold = 10;
    };
    services.localtimed.enable = true;
    networking.timeServers = [
      "0.br.pool.ntp.org"
      "1.br.pool.ntp.org"
      "2.br.pool.ntp.org"
      "3.br.pool.ntp.org"
    ];
  };
}
