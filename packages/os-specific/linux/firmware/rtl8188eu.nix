{
  bc,
  fetchgit,
  lib,
  linuxPackages_5_10,
  stdenv,
}:
let
  kernel = linuxPackages_5_10.kernel;
  modDestDir =
    "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtl8188eu";
in stdenv.mkDerivation rec {
  name = "rtl8188eu-${kernel.version}-${version}";
  version = "0ff1f31cc50e556626becb0853835a64578e6022";

  src = fetchgit {
    url = meta.homepage;
    rev = version;
    sha256 = "sha256-e2DIV8QKKzdsciM2zJEPSxq8Q0i2WZom573xznahao4=";
    leaveDotGit = true;
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;
  buildInputs = [ bc ];

  makeFlags = [ "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p ${modDestDir}
    find . -name '*.ko' -exec cp --parents {} ${modDestDir} \;
    find ${modDestDir} -name '*.ko' -exec xz -f {} \;
    # mkdir -p $out/lib/firmware/rtlwifi
    # install -D -pm644 rtl8188eufw.bin $out/lib/firmware/rtlwifi/rtl8188eufw.bin
  '';

  meta = with lib; {
    description = "Realtek rtl8188eu driver";
    homepage = "https://github.com/lwfinger/rtl8188eu.git";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
