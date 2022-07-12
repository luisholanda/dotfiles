{
  lib,
  isIntel,
  isAMD,
  isx86,
  isContainer,
  isLaptop,
  mkForce,
  mkIf,
}:
with (lib.kernel); let
  inherit (builtins) foldl' attrValues mapAttrs;

  ifIntel =
    if isIntel
    then yes
    else no;
  ifAMD =
    if isAMD
    then yes
    else no;
  ifx86 =
    if isx86
    then yes
    else no;
  ifLaptop =
    if isLaptop
    then yes
    else no;
  ifDesktop =
    if isLaptop
    then no
    else yes;

  config = {
    cpu = {
      MNATIVE_INTEL = ifIntel;
      MNATIVE_AMD = ifAMD;
      MICROCODE_INTEL = ifIntel;
      MICROCODE_AMD = ifAMD;
      X86_INTEL_TSX_MODE_ON = ifx86;
      X86_AMD_PSTATE = ifAMD;
      X86_AMD_FREQ_SENSITIVITY = ifAMD;
      X86_AMD_PLATFORM_DEVICE = ifAMD;
      CPU_FREQ_DEFAULT_GOV_PERFORMANCE = ifDesktop;
      CPU_FREQ_DEFAULT_GOV_USERSPACE = ifLaptop;
      CPU_IDLE_GOV_TEO = yes;
      NO_HZ_IDLE = yes;
      PREEMPT = yes;
      PREEMPT_DYNAMIC = no;
      PREEMPT_VOLUNTARY = no;
      RCU_EXPERT = yes;
      RCU_BOOST = yes;
    };

    disk = {
      IOSCHED_BFQ = yes;
      MQ_IOSCHED_DEADLINE = no;
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
    };

    networking = {
      TCP_CONG_BBR = yes;
      TCP_CONG_CUBIC = no;
      DEFAULT_BBR = yes;
      INFINIBAND = no;
      NET_SCH_FQ_CODEL = yes;
      NET_SCH_DEFAULT = yes;
      DEFAULT_FQ_CODEL = yes;
    };

    filesystems = {
      F2FS_FS = yes;
      XFS_FS = yes;
      NFS_FS = no;
      EXT2_FS = no;
      EXT3_FS = no;
      "9P_FS" = no;
      MISC_FILESYSTEMS = no;
    };

    thermals = {
      THERMAL_NETLINK = yes;
      INTEL_TCC_COOLING = ifIntel;
    };

    video = {
      DRM_AMDGPU_SI = ifAMD;
      DRM_AMDGPU_CIK = ifAMD;
      DRM_AMD_DC_DCN = ifAMD;
      DRM_AMD_DC_HDCP = ifAMD;
      DRM_AMD_DC_SI = ifAMD;
      DRM_I915_GVT = ifIntel;
      DRM_I915_GVT_KVMGT = ifIntel;
    };

    sound = {
      SND_SOC_SOF_INTEL_TOPLEVEL = ifIntel;
    };

    power = {
      HIBERNATION = yes;
      PM_AUTOSLEEP = yes;
      WQ_POWER_EFFICIENT_DEFAULT = yes;
      ENERGY_MODEL = yes;
    };

    extras = {
      NUMA = no;
      BT_HS = yes;

      KVM = no;
      XEN = no;
      STAGING = no;

      MEDIA_ANALOG_TV_SUPPORT = no;
      MEDIA_RADIO_SUPPORT = no;

      ANDROID = no;
      CHROME_PLATFORMS = no;
    };
  };
in
  mapAttrs (_: v: mkForce v) (foldl' (a: b: a // b) {} (attrValues config))
