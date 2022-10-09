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

      kernelPatches = clearLinuxPatches ++ mglruPatches ++ miscPatches;
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

  # Won't be needed for 6.1
  mglruPatches = [
    (buildPatch "multi-gen-lru" {
      url = "https://raw.githubusercontent.com/Frogging-Family/linux-tkg/master/linux-tkg-patches/6.0/0010-lru_6.0.patch";
      sha256 = "sha256-Tt+1b0W9ERRJi9aFekmb1dJuNTcxT9doVmP2Rn6lENA=";
    })
  ];

  miscPatches = [
    (buildPatch "optimize-harder-03" {
      url = "https://raw.githubusercontent.com/Frogging-Family/linux-tkg/master/linux-tkg-patches/6.0/0013-optimize_harder_O3.patch";
      sha256 = "sha256-Qa4/3Yk8KrfW42s7Itjce1J2floRcdnQ99BdIK1BT9E=";
    })
  ];
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
