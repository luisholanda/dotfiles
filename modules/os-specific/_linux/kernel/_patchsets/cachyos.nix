version: let
  rev = "491766fd40bbeb72fea74f74e6dbf02fbb4a07d3";
  cachyosUrl = "https://raw.githubusercontent.com/CachyOS/kernel-patches/";
  buildCachyOsPatches = builtins.mapAttrs (name: sha256: {
    inherit sha256;
    url = "${cachyosUrl}/${rev}/${version}/${name}.patch";
  });

  basePatches = {
    "0001-bbr2" = "sha256-l6yvFPynfnf3/dFbxm+BQJZQKLBSetQmngB+8Ea6RSQ=";
    "0002-bfq" = "sha256-odOFT2VkH2kNWA36L7ySHf7tzHXrBRIxehKrQ1y0uB4=";
    "0003-bitmap" = "sha256-O02koGeJxEi0y+ZVyoe/ubC7AVi8k+Xlkz2NPrajqpA=";
    "0004-cachy" = "sha256-Wge5utsiLXiZKBY/IWTOMUWjTHmWA23meL4Dp1H0Nok=";
    "0005-clr" = "sha256-+BNyMvXsRNGlznMBGHHCUXI+NFmtQcw5i1fIAE9iMMU=";
    "0006-fixes" = "sha256-fGBbvmIIH7fzmOTnFulzHJcrfzItwIulq/veYTSNdiY=";
    "0009-ksm" = "sha256-eDmtDe3ABRrMezP4WI7qz2apEwIVkOoq4uDDy0D+hj4=";
    #"0010-maple-lru" = "sha256-yOvMa/EzLp4OSLyPOW8Hp03CqxxVRMd3I28Xw5jaVWA=";
    "0011-objtool" = "sha256-UUNde1/bgCbWhfCtqNqvpHhylcKDSPBx7tXI178iCd0=";
    "0012-sched" = "sha256-hupdYgbjibj90VghZ2Z8B2KMj4thUrq/IZkmQfqUl7I=";
    "0013-zram" = "sha256-pKLLukvsyGcGKso+6+haXPSJUJdwVJiHXregwdcJoHU=";
    "0014-zstd-import-1.5.5" = "sha256-zpXcqG/L1tiYELSIIIQUdmBTMl6y9A4C3pey0O/txG8=";
    "0015-v4l2-core-add-v4l2loopback" = "sha256-N8Fx11tjiKcqTZvUSNb6rnIVrRpRyc8+m/uEsY+v9NY=";
  };

  schedPatches = {
    "sched/0001-EEVDF" = "sha256-L2HAZtpEXZAKPhU34cA7AauMj5DJO+7qTHYkpuci74Q=";
  };
in
  buildCachyOsPatches (basePatches // schedPatches)
