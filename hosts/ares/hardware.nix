# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  lib,
  modulesPath,
  ...
}: let
  btrfsSubvolOpts = subvol: ["subvol=${subvol}" "compress=zstd" "max_inline=3600" "noatime"];
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/456db9a7-5781-41ef-8d6d-8a8d2e7d189b";
    fsType = "btrfs";
    options = btrfsSubvolOpts "root";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/456db9a7-5781-41ef-8d6d-8a8d2e7d189b";
    fsType = "btrfs";
    options = btrfsSubvolOpts "nix";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/456db9a7-5781-41ef-8d6d-8a8d2e7d189b";
    fsType = "btrfs";
    options = btrfsSubvolOpts "home";
  };

  fileSystems."/media/data" = {
    label = "data";
    fsType = "ext4";
    noCheck = true;
    options = [
      "defaults"
      "noatime"
      "lazytime"
      "data=writeback"
      "journal_async_commit"
      "nombcache"
    ];
  };

  hardware = {
    brillo.enable = true;
    ksm.enable = true;
    graphics.enable = true;
  };
  host.hardware.isIntel = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
