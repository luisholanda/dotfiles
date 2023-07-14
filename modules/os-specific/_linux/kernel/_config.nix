{
  lib,
  isIntel,
  isAMD,
  isx86,
  isLaptop,
  gpu,
}:
with lib.kernel; let
  inherit (lib) mkForce;
  inherit (builtins) foldl' attrValues mapAttrs;

  enableIf = b:
    if b
    then yes
    else no;

  ifIntel = enableIf isIntel;
  ifAMD = enableIf isAMD;
  ifx86 = enableIf isx86;
  ifLaptop = enableIf isLaptop;
  ifDesktop = enableIf (!isLaptop);
  ifAMDGpu = enableIf (!gpu.isNVIDIA && isAMD);
  ifIntelGpu = enableIf (!gpu.isNVIDIA && isIntel);
  ifNouveauGpu = enableIf gpu.isNVIDIA;

  config = {
    cpu = {
      MNATIVE_INTEL = ifIntel;
      MNATIVE_AMD = ifAMD;

      MICROCODE_INTEL = ifIntel;
      MICROCODE_AMD = ifAMD;

      X86_INTEL_TSX_MODE_ON = ifx86;
      X86_IOSF_MBI = ifx86;

      X86_INTEL_LPSS = ifIntel;

      X86_AMD_PSTATE = ifAMD;
      X86_AMD_PLATFORM_DEVICE = ifAMD;

      x86_KERNEL_IBT = yes;

      CPU_FREQ_DEFAULT_GOV_PERFORMANCE = ifDesktop;
      CPU_FREQ_DEFAULT_GOV_USERSPACE = ifLaptop;
      CPU_IDLE_GOV_TEO = yes;

      NO_HZ_IDLE = yes;

      PERF_EVENTS_INTEL_UNCORE = ifIntel;
      PERF_EVENTS_INTEL_RAPL = ifIntel;
      PERF_EVENTS_INTEL_CSTATE = ifIntel;
      PERF_EVENTS_AMD_POWER = ifAMD;
      PERF_EVENTS_AMD_UNCORE = ifAMD;
      PERF_EVENTS_AMD_CSTATE = ifAMD;
      PERF_EVENTS_AMD_BRS = ifAMD;

      PREEMPT = yes;
      PREEMPT_DYNAMIC = yes;

      RCU_EXPERT = yes;
      RCU_FANOUT = freeform "64";
      RCU_FANOUT_LEAF = freeform "16";
      RCU_BOOST = yes;
      RCU_BOOST_DELAY = freeform "500";
      RCU_NOCB_CPU = yes;
      RCU_NOCB_CPU_DEFAULT_ALL = yes;
      RCU_LAZY = yes;
      RCU_STALL_COMMON = yes;
      RCU_NEED_SEGCBLIST = yes;
    };

    disk = {
      IOSCHED_BFQ = yes;
      MQ_IOSCHED_DEADLINE = yes;
      MQ_IOSCHED_KYBER = no;
      NVME_MULTIPATH = yes;
      BLK_DEV_NVME = yes;
    };

    ram = {
      ZSWAP = yes;
      ZBUD = no;
      ZSWAP_COMPRESSOR_DEFAULT_LZ4 = yes;
      ZSWAP_ZPOOL_DEFAULT_Z3FOLD = yes;
      ZSWAP_DEFAULT_ON = yes;
      LRU_GEN = yes;
    };

    networking = {
      TCP_CONG_BIC = no;
      TCP_CONG_BBR = yes;
      TCP_CONG_CDG = no;
      TCP_CONG_CUBIC = no;
      TCP_CONG_DCTCP = no;
      TCP_CONG_HTCP = no;
      TCP_CONG_HSTCP = no;
      TCP_CONG_HYBLA = no;
      TCP_CONG_ILLINOIS = no;
      TCP_CONG_LP = no;
      TCP_CONG_NV = no;
      TCP_CONG_SCALABLE = no;
      TCP_CONG_VEGAS = no;
      TCP_CONG_YEAH = no;
      TCP_CONG_WESTWOOD = no;
      DEFAULT_BBR = yes;
      INFINIBAND = no;
      NET_SCH_FQ_CODEL = yes;
      NET_SCH_DEFAULT = yes;
      DEFAULT_FQ_CODEL = yes;

      # For docker.
      BRIDGE = yes;

      ARCNET = no;
      CAN_DEV = no;
      "6LOWPAN" = no;
      NET_9P = no;
      ATM = no;
      CAIF = no;
      CAN = no;
      CEPH = no;
      NET_DSA = no;
    };

    filesystems = {
      AFS_FS = no;
      CEPH_FS = no;
      CIFS_FS = no;
      F2FS_FS = yes;
      GFS2_FS = no;
      ISO9660_FS = no;
      JBD2_FS = no;
      JFS_FS = no;
      OCFS2_FS = no;
      NFTS3_FS = no;
      XFS_FS = yes;
      NILFS2_FS = no;
      NLS_FS = no;
      NFSD_FS = no;
      EXT2_FS = no;
      EXT3_FS = no;
      "9P_FS" = no;
      REISERFS_FS = no;
      MISC_FILESYSTEMS = no;
    };

    thermals = {
      THERMAL_NETLINK = yes;
      INTEL_TCC_COOLING = ifIntel;
    };

    video = {
      DRM_ACCEL = yes;
      DRM_RADEON = no;
      DRM_AMD_DC_DCN = ifAMDGpu;
      DRM_AMD_DC_HDCP = ifAMDGpu;
      DRM_AMD_DC_SI = ifAMDGpu;
      DRM_I915 = ifIntelGpu;
      DRM_I915_GVT = yes;
      DRM_I915_GVT_KVMGT = ifIntelGpu;
      DRM_NOVEAU = ifNouveauGpu;
      DRM_GMA500 = no;

      DRM_SSD130X = no;

      RC_CORE = no;
      FB_GRVGA = no;
      FB_CIRRUS = no;
      FB_PM2 = no;
      FB_ARMCLCD = no;
      FB_ACORN = no;
      FB_CLPS711X = no;
      FB_SA110 = no;
      FB_IMX = no;
      FB_CYBER2000 = no;
      FB_ARC = no;
      FB_MATROX = no;
      FB_ATY = no;
      FB_STI = no;
      FB_TGA = no;
      FB_HGA = no;
      FB_SAVAGE = no;

      LCP_CLASS_DEVICE = ifLaptop;
    };

    sound = {
      SND_SOC_SOF_TOPLEVEL = no;
      SND_SOC_INTEL_SST_TOPLEVEL = ifIntel;
    };

    power = {
      HIBERNATION = yes;
      PM_AUTOSLEEP = yes;
      WQ_POWER_EFFICIENT_DEFAULT = yes;
      ENERGY_MODEL = yes;
    };

    media = {
      MEDIA_ANALOG_TV_SUPPORT = no;
      MEDIA_DIGITAL_TV_SUPPORT = no;
      MEDIA_RADIO_SUPPORT = no;
      MEDIA_SDR_SUPPORT = no;
      MEDIA_TEST_SUPPORT = no;
    };

    extras = {
      NUMA = no;
      BT_HS = yes;

      KVM = no;
      XEN = no;
      STAGING = no;

      ANDROID = no;
      CHROME_PLATFORMS = no;

      CC_OPTIMIZE_FOR_PERFORMANCE = yes;

      IIO = no;
      COMEDI = no;

      MEDIA_TUNER = no;
      REGULATOR = no;

      KERNEL_ZSD = yes;
      ZSTD_COMPRESSION_LEVEL = freeform "2";
    };
  };
in
  mapAttrs (_: mkForce) (foldl' (a: b: a // b) {} (attrValues config))
