{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.host.hardware) isIntel isAMD isLaptop;
  inherit (lib) mkIf mkDefault mkForce;
  inherit (lib) mapAttrsFlatten;
  inherit (pkgs) fetchpatch;
  inherit (pkgs.stdenv) isLinux;

  kernel = let
    inherit (pkgs) clang13Stdenv;

    baseKernelPackages = pkgs.linuxPackages_6_0;
    configuratedKernel = baseKernelPackages.kernel.override {
      stdenv = clang13Stdenv;
      structuredExtraConfig = import ./_config.nix {
        inherit lib isIntel isAMD isLaptop mkForce;
        inherit (pkgs.stdenv.targetPlatform) isx86;
      };
      ignoreConfigErrors = true;

      kernelPatches = clearLinuxPatches;
    };
  in
    pkgs.linuxPackagesFor configuratedKernel;

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

  clearLinuxPatches = buildPatchset ./_patchsets/clearLinux.nix {};
in {
  config = mkIf isLinux {
    boot.kernelPackages = mkDefault kernel;

    boot.kernelParams = [
      # Enable page allocator randomization
      "page_alloc.shuffle=1"
      # Reduce TTY output during boot
      "quiet"
    ];
  };
}
