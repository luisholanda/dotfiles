{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  inherit (pkgs.stdenv) isLinux;
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

    boot.kernelPackages = mkDefault pkgs.linuxPackages_5_15_hardened;
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
    boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;

    # don't wait for network during boot.
    systemd.targets.network-online.wantedBy = mkForce [];
    systemd.services.NetworkManager-wait-online.wantedBy = mkForce [];
  };
}
