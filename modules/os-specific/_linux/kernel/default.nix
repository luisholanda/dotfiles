{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.host.hardware) isLaptop;
  inherit (lib) optionals;
  inherit (lib.my) flattenAttrs;
in {
  config = {
    boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;

    boot.kernelParams = let
      defaultParams = [
        # Enable page allocator randomization
        "page_alloc.shuffle=1"
        # Reduce TTY output during boot
        "quiet"
      ];
      desktopParams = [
        # There is no reason to enable mitigations for most desktops.
        "mitigations=off"
      ];
    in
      defaultParams ++ (optionals (!isLaptop) desktopParams);

    boot.kernel.sysctl = flattenAttrs {
      kernel = {
        nmi_watchdog = 0;
        split_lock_mitigate = 0;
      };
      net = {
        core.default_qdisc = "cake";
        ipv4.tcp_congestion_control = "bbr2";
      };
      vm = {
        dirty_background_ratio = 5;
        dirty_ratio = 10;
        ipv4.tcp_fastopen = 3;
        page-cluster = 1;
        swappiness = 30;
        vfs_cache_pressure = 50;
      };
    };
  };
}
