# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel" "8188eu"];

  fileSystems = {
    "/" = {
      label = "nixos";
      fsType = "xfs";
    };
    "/boot" = {
      label = "boot";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      label = "swap";
      priority = 1;
    }
  ];

  hardware = {
    brillo.enable = true;
    ksm.enable = true;
    opengl.enable = true;
    video.hidpi.enable = true;
  };
  host.hardware.isIntel = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
