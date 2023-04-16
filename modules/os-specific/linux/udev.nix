{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux;
in {
  config.services.udev.extraRules = mkIf isLinux ''
    # SATA Active Link Power Management
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="max_performance"

    # I/O schedulers
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
}
