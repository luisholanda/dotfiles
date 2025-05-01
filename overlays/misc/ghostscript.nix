final: prev: let
  inherit (final.lib) optionalString removeSuffix;
  inherit (final.stdenv.hostPlatform) isDarwin;
in {
  ghostscript = prev.ghostscript.overrideAttrs (o: {
    installCheckPhase = let
      base = removeSuffix "runHook preInstallCheck\n" o.installCheckPhase;
    in
      ''
        runHook preInstallCheck
      ''
      + optionalString isDarwin ''
        DYLD_LIBRARY_PATH=$out/lib
        export DYLD_LIBRARY_PATH
      ''
      + base;
  });
}
