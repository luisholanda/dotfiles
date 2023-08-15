version: let
  rev = "f9ed188b1320f9a4a74a740ed57744f64ca74569";
  cachyosUrl = "https://raw.githubusercontent.com/CachyOS/kernel-patches";
  buildCachyOsPatches = builtins.mapAttrs (name: sha256: {
    inherit sha256;
    url = "${cachyosUrl}/${rev}/${version}/${name}.patch";
  });

  basePatches = {
    "0001-bbr2" = "sha256-6VkPhCE+0xeT0GvbETgNxox/biaW45aCXeRDGG3sxm0=";
    "0002-cachy" = "sha256-sI84iolAFdGwHa+n7SuNgEql4FNh6f7XkLzx5l5qwOI=";
    "0006-sched" = "sha256-m/Dkt3gbgA4tV1yd1MEQo3c3/1zRuVHd8Q2CJQQxMMA=";
    "0007-zstd-1.5.5" = "sha256-V8r3wjGumTVDe6ManBcb8ER5xM34Mlu9eWc36ByXDIo=";
  };

  schedPatches = {
    "sched/0001-EEVDF" = "sha256-kaUzCAP6Yrn+6T1Z3jrkirNDwapQpXIVJRhGkEpO+NI=";
    "sched/0001-bore-eevdf" = "sha256-IFIzs9Vx2L1i18mbsj65q+18kr1c/UsJ8pLGP6IqVVU=";
  };
in
  buildCachyOsPatches (basePatches // schedPatches)
