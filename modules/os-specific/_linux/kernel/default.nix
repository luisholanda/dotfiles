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
  imports = [
    # renamed stuff on unstable.
    (lib.mkAliasOptionModule ["hardware" "graphics" "enable"] ["hardware" "opengl" "enable"])
    (lib.mkAliasOptionModule ["hardware" "graphics" "enable32Bit"] ["hardware" "opengl" "driSupport32Bit"])
    (lib.mkAliasOptionModule ["hardware" "graphics" "package"] ["hardware" "opengl" "package"])
    (lib.mkAliasOptionModule ["hardware" "graphics" "package32"] ["hardware" "opengl" "package32"])
    (lib.mkAliasOptionModule ["hardware" "graphics" "extraPackages"] ["hardware" "opengl" "extraPackages"])
    (lib.mkAliasOptionModule ["hardware" "graphics" "extraPackages32"] ["hardware" "opengl" "extraPackages32"])
  ];
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

    chaotic.scx.enable = true;
    chaotic.scx.package = pkgs.scx_git.bpfland;
    chaotic.scx.scheduler = "scx_bpfland";
  };
}
