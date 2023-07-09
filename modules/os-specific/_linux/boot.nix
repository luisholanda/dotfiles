{
  config,
  lib,
  modulesPath,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
in {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  config = {
    boot.tmp.cleanOnBoot = mkDefault true;

    boot.loader.grub.enable = false;
    boot.loader.systemd-boot.enable = mkDefault true;

    # TODO: Why did we need it?
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.consoleMode = "auto";
    boot.loader.systemd-boot.editor = false;
    boot.loader.systemd-boot.configurationLimit = 5;

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
    in
      mkIf (length swapDevices > 0) (head swapDevices).device;

    # don't wait for network during boot.
    systemd.targets.network-online.wantedBy = mkForce [];
    systemd.services.NetworkManager-wait-online.wantedBy = mkForce [];

    hardware.enableRedistributableFirmware = true;

    services.thermald.enable = true;
  };
}
