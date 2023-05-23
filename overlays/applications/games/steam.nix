(_: prev: {
  # Fix some proton issues in wayland.
  steam = prev.steam.override {
    extraLibraries = pkgs:
      with pkgs; [
        libxcrypt
        libmspack
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        gamemode.lib
        (pkgs.runCommandNoCCLocal "libxcrypt-1" {src = libxcrypt;} ''
          mkdir -p $out/lib
          cp $src/lib/libcrypt.so $out/lib/libcrypt.so.1
        '')
      ];
  };
})
