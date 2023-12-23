{
  config,
  lib,
  ...
}: let
  inherit (lib.my) mkEnableOpt;
in {
  options.modules.programs.gpg.enable = mkEnableOpt "Enable GnuPG configuration.";

  config = {
    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.pinentryFlavor = "qt";
    user.home.programs.gpg = {
      inherit (config.modules.programs.gpg) enable;

      settings = let
        cert-digest-algo = "SHA512";
        list-options = "show-uid-validity";
      in {
        inherit cert-digest-algo list-options;
        default-key = "6209F03056D0A60684B83B6B552912613CB92BF6";
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        s2k-digest-algo = cert-digest-algo;
        s2k-cipher-algo = "AES256";
        fixed-list-mode = true;
        no-comments = true;
        no-emit-version = true;
        keyid-format = "0xlong";
        verify-options = list-options;
        with-fingerprint = true;
        require-cross-certification = true;
        no-symkey-cache = true;
        throw-keyids = true;
        use-agent = true;
        auto-key-retrieve = true;
      };
    };
  };
}
