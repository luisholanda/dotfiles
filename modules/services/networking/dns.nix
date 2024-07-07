_: let
  cloudflare-sec-stamp = "sdns://AgMAAAAAAAAABzEuMC4wLjIAG3NlY3VyaXR5LmNsb3VkZmxhcmUtZG5zLmNvbQovZG5zLXF1ZXJ5";
in {
  config = {
    networking.resolvconf.useLocalResolver = true;
    services.adguardhome.enable = true;
    services.adguardhome.settings = {
      dns = {
        bind_hosts = ["127.0.0.1" "::1"];
        port = 53;
        ratelimit = 0;
        upstream_dns = ["quic://dns.adguard-dns.com" cloudflare-sec-stamp];
        upstream_mode = "parallel";
        use_http3_upstreams = true;
        bootstrap_dns = ["1.1.1.2" "1.0.0.2"];

        cache_size = 256 * 1024 * 1024;
        cache_optimistic = true;

        enable_dnssec = true;
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        safe_search.enabled = true;
      };
      statistics.enabled = true;
    };

    boot.kernel.sysctl."net.core.rmem_max" = 8 * 1024 * 1024;
    boot.kernel.sysctl."net.core.wmem_max" = 8 * 1024 * 1024;
  };
}
