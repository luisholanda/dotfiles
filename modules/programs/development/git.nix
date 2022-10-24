{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
  inherit (lib) mkIf mkMerge mkOption types;
  inherit (lib.my) mkBoolOpt mkEnableOpt mkPkgOpt;

  cfg = config.modules.programs.git;
  account = config.user.accounts.email.accounts."${cfg.emailAccount}";
in {
  options.modules.programs.git = {
    enable = mkEnableOpt "Enable the Git version control system.";
    package = mkPkgOpt pkgs.git "Git";

    emailAccount = mkOption {
      description = ''
        Email account to use for git.

        This should be the name of an account in
        <literal>user.accounts.email.accounts</literal>.
      '';
      type = types.str;
    };

    ssh = {
      always = mkBoolOpt true "Always use ssh for Git connections.";
      keys = mkOption {
        type = with types; attrsOf (either str path);
        description = "SSH key to use for SSH Git connections.";
        default = {
          "github.com" = "~/.ssh/github";
          "gitlab.com" = "~/.ssh/gitlab";
          "git.sr.ht" = "~/.ssh/sourcehut";
        };
      };
    };

    addons = {
      delta = {
        enable = mkEnableOpt "Enable the delta syntax highlighter.";
        options = mkOption {
          description = "Delta configuration options.";
          default = {};
          type = with types; let
            value = either str (either bool int);
          in
            attrsOf (either value (attrsOf value));
        };
      };
      stgit.enable = mkEnableOpt "Enable the stacked-git wrapper.";
      stack.enable = mkEnableOpt "Enable git-stack support.";
    };
  };

  config = mkMerge [
    {
      user.home.programs.git = {
        inherit (cfg) enable package;

        userName = account.realName;
        userEmail = account.address;

        signing.key = account.gpg.key;
        signing.signByDefault = account.gpg.signByDefault;

        delta = {
          inherit (cfg.addons.delta) enable;
          options =
            {
              line-numbers = true;
              syntax-theme = "OneHalfDark";
            }
            // cfg.addons.delta.options;
        };

        extraConfig = {
          branch.autosetuprebase = "always";
          core.commentChar = "@";
          color.ui = true;
          credential.helper = "store";
          diff.algorithm = "histogram";
          pull.rebase = true;
          rebase = {
            autoSquash = true;
            autoStash = true;
            abbreviateCommands = true;
          };
          sendemail = {
            smtpserver = "smtp.googlemail.com";
            smtpencryption = "tls";
            smtpserverport = 587;
            smtpuser = account.address;
          };
          github.user = "luisholanda";
        };
      };

      user.sessionVariables = mkIf cfg.enable {
        GIT_SEQUENCE_EDITOR = config.user.sessionVariables.EDITOR or "";
      };

      user.home.programs.ssh.matchBlocks =
        builtins.mapAttrs (hostname: identityFile: {
          inherit hostname identityFile;
          user = "git";
          identitiesOnly = true;
          extraOptions = {
            PreferredAuthentications = "publickey";
            AddKeysToAgent = "yes";
          };
        })
        cfg.ssh.keys;
    }

    # Use GitHub cli to authenticate in case we don't want to use SSH.
    (mkIf (!cfg.ssh.always) {
      user.home.programs.git.extraConfig = {
        credential."https://github.com".helper = "!${pkgs.gitAndTools.gh}/bin/gh auth git-credential";
      };
    })

    # SSH-specific configurations.
    (mkIf cfg.ssh.always {
      user.home.programs.git.extraConfig = {
        url."git@github.com:".insteadOf = "https://github.com/";
      };
    })
    # Stacked-git addon.
    (mkIf cfg.addons.stgit.enable {
      user.packages = [pkgs.stgit];
      user.home.programs.git.extraConfig.stgit = {
        keepoptimized = "yes";
        diff-opts = "-M -w -W";

        alias = {
          submit = "git stg-submit";
        };
      };

      user.home.programs.git.aliases.stg-submit = "!f() { local patch=$\{1:?Must pass patch name}; shift; git push origin $@ $(stg id $patch):refs/heads/$(echo $patch | sed 's/\\(\\w\\)-/\\1\\//'); }; f";
    })
    (mkIf cfg.addons.stack.enable {
      user.packages = [pkgs.gitAndTools.git-stack];

      user.home.programs.git.extraConfig.stack = {
        show-stacked = "yes";
        auto-fixup = "squash";
        auto-repair = "yes";
      };
    })
    # MacOS-specific configurations.
    (mkIf isDarwin {
      user.home.programs.git = {
        extraConfig.credentials.helper = "oskeychain";
        ignores = [
          # General
          ".DS_Store"
          ".AppleDouble"
          ".LSOverride"
          "Icon"
          # Files that might appear in the root of a volume
          ".DocumentRevisions-V100"
          ".fseventsd"
          ".Spotlight-V100"
          ".TemporaryItems"
          ".Trashes"
          ".VolumeIcon.icns"
          ".com.apple.timemachine.donotpresent"
          # Directories potentially created on remote AFP share
          ".AppleDB"
          ".AppleDesktop"
          "Network Trash Folder"
          "Temporary Items"
          ".apdisk"
        ];
      };
    })
    # Aliases
    {
      user.home.programs.git.aliases = {
        # list all aliases
        aliases = "!git config --get-regexp '^alias\\.' | cut -c 7- | sed 's/ / = /'";

        # list all tags
        tags = "tag -n1 --list";
        # list all stashes
        stashes = "stash list";
        # fix dumb mistakes
        fuck = "!git add :/*; git cane; git sync -f";
        # status with short format instead of full details
        ss = "status --short";
        # status with short format and showing branch and tracking info.
        ssb = "status --short --branch";
        # list all branches, remotes included.
        branches = "branch -a";
        # create a new branch.
        nb = "checkout -b";
        # checkout to a branch.
        ch = "checkout";
        # current branch
        current-branch = "rev-parse --abbrev-ref HEAD";
        unstage = "restore --staged";

        # sync to remove
        sync = ''!git push origin "$(git current-branch)"'';
        # update branch with base branch.
        upwb = ''
          !git pull origin develop --rebase && git push origin "$(git current-branch)" --force'';

        # cherry-pick
        cp = "cherry-pick";
        cpc = "cp --continue";
        cpa = "cp --abort";

        # commit
        co = "commit";
        # commit with inline message
        cm = "co --message";
        # commit - amend the tip of the current branch rather than creating
        # a new commit
        ca = "co --amend";
        # commit - amend the tip of the current branch with inline message
        cam = "ca --message";
        # commit - amend the tip of the current branch, and do not edit the message
        cane = "ca --no-edit";
        # commit interactive
        ci = "co --interactive";
        # create a fixup commit using a fzf commit list selector
        fixup = ''
          !git l --no-decorate "$(git merge-base $(git current-branch) origin/develop)".. | fzf | cut -c -7 | xargs -o git commit --fixup'';

        df = "diff";
        # diff - show changes not yet staged
        dc = "df --cached";
        # diff - show changes about to be commited
        ds = "df --staged";
        dh = "df HEAD";
        # diff - show changes by word, not line
        dw = "!git diff --word-diff";
        # diff deep
        dd = "diff --check --dirstat --find-copies --find-renames --histogram --color";

        fe = "fetch --prune";
        feo = "fe origin";

        # log with a text-based graphical representation of the commit history.
        lg = "log --graph";
        # log with patch generation.
        lp = "log --patch";
        # log with one line per item.
        l = "log --oneline --no-merges";
        ll = "log --graph --topo-order --date=short --abbrev-commit --decorate --all --boundary --pretty=format:'%Cgreen%ad %Cred%h%Creset -%C(yellow)%d%Creset %s %Cblue[%cn]%Creset %Cblue%G?%Creset'";
        lll = "log --graph --topo-order --date=iso8601-strict --no-abbrev-commit --abbrev=40 --decorate --all --boundary --pretty=format:'%Cgreen%ad %Cred%h%Creset -%C(yellow)%d%Creset %s %Cblue[%cn <%ce>]%Creset %Cblue%G?%Creset'";

        # rebase - forward-port local commits to the updated upstream head.
        rb = "rebase";
        # iterative rebases using the provided number of commits.
        rbi = "rb --interactive";
        # rebase abort - cancel the rebasing process.
        rba = "rb --abort";
        # rebase - continue the rebasing process after resolving a conflict
        # manually and updating the index with the resolution.,
        rbc = "rb --continue";
        # rebase - restart the rebasing process by skipping the current patch.
        rbs = "rb --skip";
        rbt = ''
          !git l --no-decorate "$(git merge-base $(git current-branch) origin/develop)".. | fzf | cut -c -7 | xargs -o git rbi'';

        save = "stash push -u";
        pop = "stash pop";
        snapshot = "!git save \"snapshot: $(date)\" && git stash apply 'stash@{0}'";

        # pruner: prune everything that is unreachable now.
        #
        # This command taskes a long time to run, perhaps even overnight.
        # This is useful for removing unreachable objects from all places,
        # reducing the total repository size.
        #
        #By [CodeGnome](http://www.codegnome.com/)
        pruner = "!git prune --expire=now && git reflog expire --expire-unreachable=now --rewrite --all && git fetch --prune";

        # repacker: repack a repo the way Linus recommends.
        #
        # This command takes a long time to run, perhaps even overnight.
        #
        # It does the equivalent of "git gc --aggressive" but done *properly*,
        # which is to do something like:
        #
        #     git repack -a -d --depth=250 --window=250
        #
        # The depth setting is about how deep the delta chains can be; make
        # them longer for old history - it's worth the space overhead.
        #
        # The window setting is about how big an object window we want each
        # delta candidate to scan.
        #
        # And here, you might well want to add the "-f" flag (which is the
        # "drop all old deltas"), since you now are actually trying to make
        # sure that this one actually finds good candidates.
        #
        # And then it's going to tkae forever and a day (i.e. a "do it overnight"
        # thing), but the end result is that everybody downstream from that
        # repository will get much better packs, without having to spend any
        # effort on it themselves.
        #
        # http://metalinguist.wordpress.com/2007/12/06/the-woes-of-git-gc-aggressive-and-how-git-deltas-work/
        #
        # We also add the --window-memory limit of 1G, which helps protect
        # us from a window that has very large objects such as binary blobs.
        repacker = "repack -a -d -f --depth=300 --window=300 --window-memory=1g";

        optimize = "!git pruner && git repacker";

        # create a new pull request for this branch on GitHub.
        prc = "!gh pr create -w";
      };
    }
  ];
}
