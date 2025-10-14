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
    boot.kernelPackages = pkgs.linuxPackages_latest_xen_dom0;

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
        sched_rt_runtime_us = -1;
      };
      net = {
        core.default_qdisc = "cake";
        ipv4 = {
          tcp_congestion_control = "bbr2";
          tcp_fastopen = 3;
          tcp_ecn = 1;
          tcp_timestamps = 0;
        };
      };
      vm = {
        dirty_background_ratio = 5;
        dirty_ratio = 10;
        page-cluster = 1;
        swappiness = 30;
        vfs_cache_pressure = 50;
      };
    };

    services.scx.enable = true;
    services.scx.package = pkgs.scx_git.full;
    services.scx.scheduler = "scx_lavd";
  };
}
