{
  lib,
  isIntel,
  isAMD,
  isx86,
  isContainer,
  mkForce,
}:
with (lib.kernel); let
  whenIntel =
    if isIntel
    then yes
    else no;
  whenAMD =
    if isAMD
    then yes
    else no;
  whenx86 =
    if isx86
    then yes
    else no;
in
  builtins.mapAttrs (_: v: mkForce v) {
    MNATIVE_INTEL =
      if isIntel
      then yes
      else no;
    MNATIVE_AMD =
      if isAMD
      then yes
      else no;
    KERNEL_LZ4 = yes;
    KERNEL_ZSTD = mkForce no;
    NO_HZ_IDLE = yes;
    ARCH_NO_PREEMPT = mkForce no;
    PREEMPT = mkForce yes;
    PREEMPT_DYNAMIC = mkForce no;
    PREEMPT_VOLUNTARY = mkForce no;
    RCU_EXPERT = yes;
    RCU_BOOST = yes;
    MICROCODE_INTEL = whenIntel;
    MICROCODE_AMD = whenAMD;
    X86_INTEL_TSX_MODE_ON = whenx86;
    X86_SGX = whenx86;
    PM_AUTOSLEEP = yes;
    WQ_POWER_EFFICIENT_DEFAULT = yes;
    ENERGY_MODEL = yes;
    X86_AMD_PSTATE = whenAMD;
    X86_AMD_FREQ_SENSITIVITY = whenAMD;
    CPU_IDLE_GOV_TEO = yes;
    IOSCHED_BFQ = mkForce yes;
    MQ_IOSCHED_DEADLINE = no;
    MQ_IOSCHED_KYBER = no;
    KSM = yes;
    ZSWAP = yes;
    ZSWAP_COMPRESSOR_DEFAULT_LZ4 = yes;
    ZSWAP_ZPOOL_DEFAULT_Z3FOLD = yes;
    ZSWAP_DEFAULT_ON = yes;
    TCP_CONG_BBR = yes;
    TCP_CONG_CUBIC = no;
    DEFAULT_BBR = yes;
    NET_SCH_FQ_CODEL = yes;
    NET_SCH_DEFAULT = yes;
    DEFAULT_FQ_CODEL = yes;
    BT_HS = yes;
    BLK_DEV_NVME = yes;
    NVME_MULTIPATH = yes;
    INTEL_TCC_COOLING = whenIntel;
    THERMAL_NETLINK = yes;
    XFS_FS = yes;
    MISC_FILESYSTEMS = no;
    # We don't use Xen, so no need to support it.
    XEN = mkForce no;
  }
