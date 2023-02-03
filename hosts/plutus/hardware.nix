# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{modulesPath, ...}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  #boot.kernelModules = ["kvm-intel" "8188eu"];

  fileSystems = {
    "/" = {
      label = "nixos";
      fsType = "xfs";
      options = ["defaults" "noatime" "lazytime"];
    };
    "/boot" = {
      label = "boot";
      fsType = "vfat";
    };
    "/media/data" = {
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
  };

  swapDevices = [
    {
      label = "swap";
      priority = 1;
    }
  ];
}
