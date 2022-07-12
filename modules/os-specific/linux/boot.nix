{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (lib) mapAttrsFlatten optional;
  inherit (pkgs) fetchpatch;
  inherit (pkgs.stdenv) isLinux;
  inherit (config.host.hardware) isIntel isAMD isLaptop;
  inherit (config.boot) isContainer;

  kernel = let
    inherit (pkgs) clang13Stdenv linuxPackages_zen;

    baseKernelPackages = linuxPackages_zen;
    configuratedKernel = baseKernelPackages.kernel.override {
      stdenv = clang13Stdenv;
      structuredExtraConfig = import ./_kernelConfig.nix {
        inherit lib isIntel isAMD isContainer isLaptop mkForce mkIf;
        inherit (pkgs.stdenv.targetPlatform) isx86;
      };
      ignoreConfigErrors = false;

      kernelPatches = clearLinuxPatches;
    };
  in
    pkgs.linuxPackagesFor configuratedKernel;

  buildPatchset = path: let
    patches = import path;
    toPatch = name: {
      url,
      sha256 ? null,
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
  in
    mapAttrsFlatten toPatch patches;

  clearLinuxPatches = buildPatchset ./_kernelPatchsets/clearLinux.nix;

  grayskyMoreUarchesPatch = rec {
    name = "more-uarches-for-kernel-5.17";
    patch = fetchpatch {
      name = name + ".patch";
      url = "https://raw.githubusercontent.com/graysky2/kernel_compiler_patch/bdef5292bba2493d46386840a8b5a824d534debc/more-uarches-for-kernel-5.17%2B.patch";
      sha256 = "sha256-PYrvXEnkC5/KmCVBG+thlOTKD/LxI5cBcn7J4c/mg/0=";
    };
  };
in {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  config = mkIf isLinux {
    boot.cleanTmpDir = mkDefault true;

    boot.loader.grub.enable = false;
    boot.loader.systemd-boot.enable = mkDefault true;

    # TODO: Why did we need it?
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.consoleMode = "auto";
    boot.loader.systemd-boot.editor = false;
    boot.loader.systemd-boot.configurationLimit = 5;

    boot.kernelPackages = mkDefault kernel;
    boot.kernelParams = [
      # Slab/slub sanity checks, redzoning, and poisoning
      "slub_debug=FZP"
      # Enable page allocator randomization
      "page_alloc.shuffle=1"
      # Reduce TTY output during boot
      "quiet"
    ];

    boot.blacklistedKernelModules = [
      # Bad Realtek driver
      "r8188eu"

      # obscure network protocols
      "ax25"
      "netrom"
      "rose"

      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "f2f2"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "ntfs"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"
    ];

    boot.kernel.sysctl."fs.inotify.max_user_watches" = 512 * 1024;

    boot.resumeDevice = let
      inherit (builtins) length head;
      inherit (config) swapDevices;
    in mkIf (length swapDevices > 0) ((head swapDevices).device);

    # don't wait for network during boot.
    systemd.targets.network-online.wantedBy = mkForce [];
    systemd.services.NetworkManager-wait-online.wantedBy = mkForce [];

    hardware.enableRedistributableFirmware = true;

    services.thermald.enable = true;
  };
}
