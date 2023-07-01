version: let
  rev = "e41280bb5b6bd752cc8f3f1331dcf4027c7add08";
  cachyosUrl = "https://raw.githubusercontent.com/CachyOS/kernel-patches/";
  buildCachyOsPatches = builtins.mapAttrs (name: sha256: {
    inherit sha256;
    url = "${cachyosUrl}/${rev}/${version}/${name}.patch";
  });

  basePatches = {
    "0001-bbr2" = "sha256-9r8phyrCYxjSdDMyToTVK2DkQnzNYTg40go2LkA6bP0=";
    "0003-cachy" = "sha256-LbHPRtRo/RJkA4vMnADZ3nAut08Sfp0UgivFpbhv5oY=";
    "0007-ksm" = "sha256-QgGr1dCpbGZ6S8a8Q0scB8SQ8Bd4KVEhV1piZNre7Ow=";
    "0009-Per-VMA-locks" = "sha256-WMFnTgCjCFZ1RieJBboZq3b+KhBkeZNzwpvq4B56dmo=";
    "0010-sched" = "sha256-H3tsCrHL7Q7Y4Lv8S2F1JfbgMISnZpCDaGAZkJNBxTA=";
    "0012-zstd-import-1.5.5" = "sha256-V8r3wjGumTVDe6ManBcb8ER5xM34Mlu9eWc36ByXDIo=";
  };

  schedPatches = {
    "sched/0001-EEVDF" = "sha256-kaUzCAP6Yrn+6T1Z3jrkirNDwapQpXIVJRhGkEpO+NI=";
    "sched/0001-bore-eevdf" = "sha256-IFIzs9Vx2L1i18mbsj65q+18kr1c/UsJ8pLGP6IqVVU=";
  };
in
  buildCachyOsPatches (basePatches // schedPatches)
