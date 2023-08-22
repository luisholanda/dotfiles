version: let
  rev = "f9ed188b1320f9a4a74a740ed57744f64ca74569";
  cachyosUrl = "https://raw.githubusercontent.com/CachyOS/kernel-patches";
  buildCachyOsPatches = builtins.mapAttrs (name: sha256: {
    inherit sha256;
    url = "${cachyosUrl}/${rev}/${version}/${name}.patch";
  });

  basePatches = {
    "0001-bbr2" = "sha256-KNNPcB+Yo9nxuJHbiHh0ayr6Wn9K34a+QFboAWyIMTQ=";
    "0002-cachy" = "sha256-KqsgTfBlJv8AY0NBobfM6VcvzqU57LQ8q3Vtx5gtq/E=";
    "0006-sched" = "sha256-1gJnGQ4qxLP+x2H/HQYl0bmEPAvZ1ytdQf9/El5gI5Y=";
    "0007-zstd-1.5.5" = "sha256-V8r3wjGumTVDe6ManBcb8ER5xM34Mlu9eWc36ByXDIo=";
  };

  schedPatches = {};
in
  buildCachyOsPatches (basePatches // schedPatches)
