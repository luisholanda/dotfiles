{
  config,
  lib,
  ...
}: let
  inherit (lib) optionals;
  inherit (lib.my) mkAttrsOpt mkEnableOpt;

  domainsBlacklist = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/notracking/hosts-blocklists/2183517106ed70cbe50098817ebacd9469221d18/dnscrypt-proxy/dnscrypt-proxy.blacklist.txt";
    sha256 = "09sdyxpr4d0zakfqvsavgbay4l27si6b0bxyyzgimal6spb2byhh";
  };

  cfg = config.modules.services.dnscrypt-proxy2;
in {
  options.modules.services.dnscrypt-proxy2 = {
    enable = mkEnableOpt "Enable dnscrypt-proxy2 configuration.";
    settings = mkAttrsOpt "Settings for dnscrypt-proxy2";
  };

  config = {
    networking.resolvconf.useLocalResolver = cfg.enable;
    networking.nameservers = optionals (!cfg.enable) ["8.8.8.8" "8.8.4.4"];
    services.dnscrypt-proxy2 = {
      inherit (cfg) enable;
      settings =
        cfg.settings
        // {
          server_names = ["cloudflare-security" "cloudflare-security-ipv6"];
          listen_addresses = ["127.0.0.1:53"];
          max_clients = 2048;

          ipv4_servers = true;
          dnscrypt_servers = true;
          doh_servers = true;
          require_dnssec = true;
          require_nolog = true;
          # cloudflare-security filter stuff.
          require_nofilter = false;

          cache = true;
          cache_size = 8196;
          cache_min_ttl = 2400;
          cache_max_ttl = 86400;
          cache_neg_min_ttl = 60;
          cache_neg_max_ttl = 60;

          blacklist.blacklist_file = "${domainsBlacklist}";

          sources.public-resolvers = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
              "https://download.dnscrypt.info/dnscrypt-resolvers/v3/public-resolvers.md"
            ];
            cache_file = "public-resolvers.md";
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
            refresh_delay = 72;
            prefix = "";
          };
        };
    };
  };
}
