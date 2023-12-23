{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.host.hardware) isLaptop;
  inherit (lib) mkDefault optionals mapAttrsFlatten;
  inherit (lib.my) flattenAttrs;
  inherit (pkgs) fetchpatch;

  buildPatch = name: {
    url,
    sha256,
  }: {
    inherit name;
    patch =
      if builtins.isPath url
      then url
      else
        fetchpatch {
          inherit url sha256;
          name = name + ".patch";
        };
  };
  buildPatchset = path: args: let
    patches = let
      mod = import path;
    in
      if builtins.isFunction mod
      then mod args
      else mod;
  in
    mapAttrsFlatten buildPatch patches;

  cachyOsPatches = buildPatchset ./_patchsets/cachyos.nix;

  defaultKernel = pkgs.linuxPackages_6_6.kernel;
  kernelPackages = pkgs.linuxPackagesFor (defaultKernel.override {
    structuredExtraConfig = import ./_config.nix {
      inherit lib isLaptop;
      inherit (config.host.hardware) isIntel isAMD gpu;
      inherit (pkgs.stdenv.targetPlatform) isx86;
    };
    ignoreConfigErrors = true;
    kernelPatches = cachyOsPatches (lib.versions.majorMinor defaultKernel.version);
  });
in {
  config = {
    boot.kernelPackages = pkgs.linuxPackages_6_6;

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
