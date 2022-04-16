{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) hasPrefix isString mkOption splitString types;

  gpgModule = types.submodule {
    options = {
      key = mkOption {
        type = types.str;
        description = ''
          The key to use as listed in <command>gpg --list-keys</command>.
        '';
      };

      signByDefault = mkOption {
        type = types.bool;
        default = false;
        description = "Sign messages by default.";
      };

      encryptByDefault = mkOption {
        type = types.bool;
        default = false;
        description = "Encrypt outgoing messages by default.";
      };
    };
  };

  signatureModule = types.submodule {
    options = {
      text = mkOption {
        type = types.str;
        default = "";
        example = ''
          --
          Luke Skywalker
          May the force be with you.
        '';
        description = ''
          Signature content.
        '';
      };

      showSignature = mkOption {
        type = types.enum ["append" "attach" "none"];
        default = "none";
        description = "Method to communicate the signature.";
      };
    };
  };

  mailAccountOpts = {
    name,
    config,
    ...
  }: {
    options = {
      name = mkOption {
        type = types.str;
        readOnly = true;
        description = ''
          Unique identifier of the account. This is set to the
          attribute name of the account configuration.
        '';
      };

      primary = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether this is the primary account. Only one account may be
          set as primary.
        '';
      };

      flavor = mkOption {
        type = types.enum ["plain" "gmail.com" "runbox.com"];
        default = "plain";
        description = ''
          Some email providers have peculiar behavior that require
          special treatment. This option is therefore intended to
          indicate the nature of the provider.
          </para><para>
          When this indicates a specific provider then, for example,
          the IMAP and SMTP server configuration may be set
          automatically.
        '';
      };

      address = mkOption {
        type = types.strMatching ".*@.*";
        example = "jane.doe@example.org";
        description = "The email address of this account.";
      };

      aliases = mkOption {
        type = types.listOf (types.strMatching ".*@.*");
        default = [];
        example = ["webmaster@example.org" "admin@example.org"];
        description = "Alternative email addresses of this account.";
      };

      realName = mkOption {
        type = types.str;
        example = "Jane Doe";
        default = config.user.name;
        description = "Name displayed when sending mails.";
      };

      userName = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The server username of this account. This will be used as
          the SMTP and IMAP user name.
        '';
      };

      passwordCommand = mkOption {
        type = types.nullOr (types.either types.str (types.listOf types.str));
        default = null;
        apply = p:
          if isString p
          then splitString " " p
          else p;
        example = "secret-tool lookup email me@example.org";
        description = ''
          A command, which when run writes the account password on
          standard output.
        '';
      };

      folders = mkOption {
        type = types.submodule {
          options = {
            inbox = mkOption {
              type = types.str;
              default = "Inbox";
              description = ''
                Relative path of the inbox mail.
              '';
            };

            sent = mkOption {
              type = types.nullOr types.str;
              default = "Sent";
              description = ''
                Relative path of the sent mail folder.
              '';
            };

            drafts = mkOption {
              type = types.str;
              default = "Drafts";
              description = ''
                Relative path of the drafts mail folder.
              '';
            };

            trash = mkOption {
              type = types.str;
              default = "Trash";
              description = ''
                Relative path of the deleted mail folder.
              '';
            };
          };
        };
        default = {};
        description = ''
          Standard email folders.
        '';
      };

      signature = mkOption {
        type = signatureModule;
        default = {};
        description = ''
          Signature configuration.
        '';
      };

      gpg = mkOption {
        type = types.nullOr gpgModule;
        default = null;
        description = ''
          GPG configuration.
        '';
      };
    };

    config = {inherit name;};
  };

  cfg = config.user;
in {
  options.user.accounts.email = {
    maildirBasePath = mkOption {
      type = types.str;
      default = "${config.user.home.dir}/Maildir";
      defaultText = "$HOME/Maildir";
      apply = p:
        if hasPrefix "/" p
        then p
        else "${config.home.homeDirectory}/${p}";
      description = ''
        The base directory for account maildir directories. May be a
        relative path, in which case it is relative the home
        directory.
      '';
    };

    accounts = mkOption {
      type = with types; attrsOf (submodule mailAccountOpts);
      default = {};
      description = "List of email accounts.";
    };
  };

  config = {
    #home-manager.user.${cfg.name}.accounts = cfg.accounts;
  };
}
