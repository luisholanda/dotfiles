let
  clearLinuxUrl = "https://raw.githubusercontent.com/clearlinux-pkgs/linux/2b27755014265a9019315831d3eb57e20eb661fc";
  buildClearLinuxPatches = builtins.mapAttrs (name: {
    num,
    sha256,
  }: {
    inherit sha256;
    url = "${clearLinuxUrl}/0${builtins.toString num}-${name}.patch";
  });

  numered = buildClearLinuxPatches {
    pci-pme-wakeups = {
      num = 104;
      sha256 = "sha256-iVz+c2a5ygKNRRCQlGCW2iINW3rpnfif7IRt8jhSQQI=";
    };
    ksm-wakeups = {
      num = 105;
      sha256 = "sha256-Aldg6/VU5bur4pa07Rbfxku/GR6qZNitlvHptqmSegY=";
    };
    intel_idle-tweak-cpuidle-cstates = {
      num = 106;
      sha256 = "sha256-hFcnDLBxtA+NiPHjj9akqH4v+zg3pL03fxnbK6IAOMs=";
    };
    smpboot-reuse-timer-calibration = {
      num = 108;
      sha256 = "sha256-813V/iYoivXlgsWOWv6NBktiAU7nivNI1FAiE4VGD1k=";
    };
    ipv4-tcp-allow-the-memory-tuning-for-tcp-to-go-a-lit = {
      num = 111;
      sha256 = "sha256-DeP5Mx7l6sNai+J+cslOQbk7IsWEI2lgmoNjef4nbTY=";
    };
    init-wait-for-partition-and-retry-scan = {
      num = 112;
      sha256 = "sha256-HT27legQLV1yxj5Ah2u7hv1lvEIueEWMGU6sutw6a6I=";
    };
    add-scheduler-turbo3-patch = {
      num = 118;
      sha256 = "sha256-XLanJZBIfAtFvKgV+WeXEI+w7pClL/Zan+lGPci5dsQ=";
    };
    do-accept-in-LIFO-order-for-cache-efficiency = {
      num = 120;
      sha256 = "sha256-lZRGFYyO+7CfBpYD/v8BkshaiIxVusATnfbYIw6BFus=";
    };
    locking-rwsem-spin-faster = {
      num = 121;
      sha256 = "sha256-r91udhKUiK9QjlVTnjG52xro2cW3RN1Oa9NNX3RV3go=";
    };
    itmt_epb-use-epb-to-scale-itmt = {
      num = 128;
      sha256 = "sha256-5wAHh8xYfY/vWJhCFfF1j5Y0pg7rdWXkGWrBm7UcwrU=";
    };
    add-a-per-cpu-minimum-high-watermark-an-tune-batch-s = {
      num = 131;
      sha256 = "sha256-fvroVmlaJPF0OBP+LL8rBUx/rL9bYL9OEMWsluCT6dg=";
    };
  };
in
  numered
  // {
    mm-lru_cache_disable-use-synchronize_rcu_expedited = {
      url = "${clearLinuxUrl}/mm-lru_cache_disable-use-synchronize_rcu_expedited.patch";
      sha256 = "sha256-PtMS0wXIGjIXPYdtwOo4Z4luQYsTsHVPLBv22m6Tya8=";
    };
  }
