{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  inherit (pkgs.stdenv) isLinux;

  kernel = let
    inherit (pkgs) linuxPackages_zen;

    baseKernelPackages = linuxPackages_zen;
  in
    baseKernelPackages;
in {
  config = mkIf isLinux {
    boot.kernelPackages = mkDefault kernel;

    boot.kernelParams = [
      # Slab/slub sanity checks, redzoning, and poisoning
      "slub_debug=FZP"
      # Enable page allocator randomization
      "page_alloc.shuffle=1"
      # Reduce TTY output during boot
      "quiet"
    ];
  };
}
