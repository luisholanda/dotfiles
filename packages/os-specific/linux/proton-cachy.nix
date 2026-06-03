{stdenvNoCC}:
stdenvNoCC.mkDerivation rec {
  pname = "proton-cachyos";
  version = "11.0-20260521";

  src = fetchTarball {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${version}-slr/proton-cachyos-${version}-slr-x86_64_v3.tar.xz";
    sha256 = "sha256:1g4b4z39ld74nh39fhbvqiyd8s7cvsrgp8lmz41zjzjl1yqilbjp";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
    echo "${pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail "${version}" "Proton CatchyOS"
  '';
}
