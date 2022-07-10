{
  add-zen-interactive-config = {
    url = "https://github.com/zen-kernel/zen-kernel/commit/827501ad72d510cb15ca96495b2233606b739f5e.patch";
    sha256 = "sha256-Ylg9DKgIJszQRRtY9lnlG0LCHS/NGu3BCs/t5xwTxG8=";
  };
  tune-cfs-for-interactivity = {
    url = ./zen/tune-cfs-for-interactivity.patch;
    extraConfig = "CFS_BANDWIDTH=y";
  };
  tune-ondemand-for-interactivity = {
    url = ./zen/tune-ondemand-for-interactivity.patch;
  };
  background-reclaim-hugepages = {
    url = ./zen/background-reclaim-hugepages.patch;
  };
  increase-default-writeback-thresholds = {
    url = ./zen/increase-default-writeback-thresholds.patch;
  };
  use-bfq-elevator = {
    url = ./zen/use-bfq-elevator.patch;
  };
}
