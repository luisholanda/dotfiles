{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.host.hardware) isLaptop;
  inherit (lib) mkDefault optionals;
  inherit (lib) mapAttrsFlatten;
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

  defaultKernel = pkgs.linuxPackages_6_3.kernel;
  kernelPackages = pkgs.linuxPackagesFor (defaultKernel.override {
    stdenv = pkgs.clang13Stdenv;
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
    boot.kernelPackages = mkDefault kernelPackages;

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

    boot.kernel.sysctl = {
      "vm.swappiness" = 30;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_ratio" = 10;
      "vm.page-cluster" = 1;
      "vm.dirty_background_ratio" = 5;
      "kernel.nmi_watchdog" = 0;
      "vm.ipv4.tcp_fastopen" = 3;
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_congestion_control" = "bbr2";
      "kernel.split_lock_mitigate" = 0;
    };
  };
}
