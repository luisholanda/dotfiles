{ config, lib, pkgs, modulesPath, ... }:
let
  inherit (lib) mkIf mkOptionDefault mkDefault;
  inherit (pkgs.stdenv) isLinux;
in {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  config = mkIf isLinux (mkOptionDefault {
    boot.cleanTmpDir = true;

    # Always use systemd-boot as boot loader.
    boot.loader = {
      # TODO: Why did we need it?
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        consoleMode = "auto";
        editor = false;
        configurationLimit = 5;
        memtest86.enable = true;
      };
    };

    boot.kernelPackages = mkDefault pkgs.linuxPackages_5_14;
    boot.kernelParams = [
      # Slab/slub sanity checks, redzoning, and poisoning
      "slub_debug=FZP"
      # Enable page allocator randomization
      "page_alloc.shuffle=1"
      # Reduce TTY output during boot
      "quiet"
      "vga=current"
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
  });
}
