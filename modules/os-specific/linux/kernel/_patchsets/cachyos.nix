version: let
  rev = "83a7c85930ac1d1448c3e919137e8f02f5c16b26";
  cachyosUrl = "https://raw.githubusercontent.com/CachyOS/kernel-patches/";
  buildCachyOsPatches = builtins.mapAttrs (name: sha256: {
    inherit sha256;
    url = "${cachyosUrl}/${rev}/${version}/${name}.patch";
  });

  basePatches = {
    "0001-bbr2" = "sha256-l6yvFPynfnf3/dFbxm+BQJZQKLBSetQmngB+8Ea6RSQ=";
    "0002-bfq" = "sha256-odOFT2VkH2kNWA36L7ySHf7tzHXrBRIxehKrQ1y0uB4=";
    "0003-bitmap" = "sha256-O02koGeJxEi0y+ZVyoe/ubC7AVi8k+Xlkz2NPrajqpA=";
    "0004-cachy" = "sha256-XQmSHT0TMLcCERIb6kyNBeClAnuzI5gVmh1ccH6gSf8=";
    # TODO(kernel): It is better to handle ClearLinux patches manually.
    "0005-clr" = "sha256-+BNyMvXsRNGlznMBGHHCUXI+NFmtQcw5i1fIAE9iMMU=";
    "0006-fixes" = "sha256-tP1akjKjbwHfRrs7zN1+w/ahdjanb9uZrXA4JgW9QLE=";
    "0007-fs-patches" = "sha256-DKU4ijoM3DiqeuxKH65b2v9Sl/7S3Uen9WFugBffvHc=";
    "0009-ksm" = "sha256-eDmtDe3ABRrMezP4WI7qz2apEwIVkOoq4uDDy0D+hj4=";
    "0010-maple-lru" = "sha256-yOvMa/EzLp4OSLyPOW8Hp03CqxxVRMd3I28Xw5jaVWA=";
    "0011-objtool" = "sha256-UUNde1/bgCbWhfCtqNqvpHhylcKDSPBx7tXI178iCd0=";
    "0012-sched" = "sha256-7NfPyBgii+Lz9cuJ0+gLWhPdlNYkVc+oKvdGRbZZmBw=";
    "0013-zram" = "sha256-pKLLukvsyGcGKso+6+haXPSJUJdwVJiHXregwdcJoHU=";
    "0014-zstd-import-1.5.5" = "sha256-zpXcqG/L1tiYELSIIIQUdmBTMl6y9A4C3pey0O/txG8=";
    "0015-v4l2-core-add-v4l2loopback" = "sha256-N8Fx11tjiKcqTZvUSNb6rnIVrRpRyc8+m/uEsY+v9NY=";
  };

  schedPatches = {
    "sched/0001-EEVDF" = "sha256-QZ9rg3mPYKhRhhzNyBBsi1JXm/q43QL/29O5NQBD6Ko=";
  };
in
  buildCachyOsPatches (basePatches // schedPatches)
