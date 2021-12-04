{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types optionalString;
  inherit (lib.my) mkEnableOpt;
  inherit (pkgs.stdenv) isDarwin;

  functionModule = types.submodule {
    options = {
      body = mkOption {
        type = types.lines;
        description = ''
          The function body.
        '';
      };

      argumentNames = mkOption {
        type = with types; nullOr (either str (listOf str));
        default = null;
        description = ''
          Assigns the value of successive command line arguments to the names
          given.
        '';
      };

      description = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          A description of what the function does, suitable as a completion
          description.
        '';
      };

      wraps = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          Causes the function to inherit completions from the given wrapped
          command.
        '';
      };

      onEvent = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          Tells fish to run this function when the specified named event is
          emitted. Fish internally generates named events e.g. when showing the
          prompt.
        '';
      };

      onVariable = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          Tells fish to run this function when the specified variable changes
          value.
        '';
      };

      onJobExit = mkOption {
        type = with types; nullOr (either str int);
        default = null;
        description = ''
          Tells fish to run this function when the job with the specified group
          ID exits. Instead of a PID, the stringer <literal>caller</literal> can
          be specified. This is only legal when in a command substitution, and
          will result in the handler being triggered by the exit of the job
          which created this command substitution.
        '';
      };

      onProcessExit = mkOption {
        type = with types; nullOr (either str int);
        default = null;
        example = "$fish_pid";
        description = ''
          Tells fish to run this function when the fish child process with the
          specified process ID exits. Instead of a PID, for backwards
          compatibility, <literal>%self</literal> can be specified as an alias
          for <literal>$fish_pid</literal>, and the function will be run when
          the current fish instance exits.
        '';
      };

      onSignal = mkOption {
        type = with types; nullOr (either str int);
        default = null;
        example = [ "SIGHUP" "HUP" 1 ];
        description = ''
          Tells fish to run this function when the specified signal is
          delievered. The signal can be a signal number or signal name.
        '';
      };

      noScopeShadowing = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Allows the function to access the variables of calling functions.
        '';
      };

      inheritVariable = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          Snapshots the value of the specified variable and defines a local
          variable with that same name and value when the function is defined.
        '';
      };
    };
  };

  cfg = config.modules.programs.fish;
  user = config.user;
in {
  options.modules.programs.fish = {
    enable = mkEnableOpt "Enable Fish shell configuration.";

    aliases = mkOption {
      type = with types; attrsOf str;
      default = {};
      description = "Shell specific aliases.";
    };

    functions = mkOption {
      type = types.attrsOf functionModule;
      default = {};
      description = "Custom fish functions.";
    };
  };

  config.user.shell = pkgs.fish;
  config.user.home.programs.fish = {
    enable = cfg.enable;
    interactiveShellInit = ''
      set -g fish_key_bindings __fish_user_key_bindings
      set -g fish_cursor_default block;
      set -g fish_cursor_insert line;
      set -g fish_cursor_replace_one underscore
      _pure_set_default pure_show_prefix_root_prompt true
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
    shellAliases = user.shellAliases // cfg.aliases;
    functions = {
      __fish_user_key_bindings = ''
        fish_default_key_bindings -M insert
        fish_vi_key_bindings default

        set pisces_pairs '(,)' '[,]' '{,}' '","' "','"

        for pair in $pisces_pairs
          _pisces_bind_pair insert (string split -- ',' $pair)
        end

        # normal backspace, also known as \010 or ^H:
        bind -M insert \b _pisces_backspace;

        # Terminal.app sends DEL code on ?:
        ${optionalString isDarwin "bind -M insert \\177 _pisces_backspace"}

        # overrides TAB to provide completion of vars before a closeing '"'
        bind -M insert \t _pisces_complete
      '';
      workon = {
        argumentNames = "project";
        description = "Go to the given project";
        body = ''
          set --local prev_dir (dir)
          set --local projects_dirs ${builtins.concatStringsSep " " user.home.projectDirs}

          for proj_dir in $proejcts_dirs
            set --local project_dir $proj_dir/$project
            if test -d $project_dir
              pushd $project_dir

              if test -f $project_dir/shell.nix
                nix-shell
              end

              function __on_exit --on-event fish_exit
                popd
              end

              return 0
            end
          end

          echo "Project $project not found"
          return 1
        '';
      };
    } // cfg.functions;

    plugins = [
      rec {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "rafaelrinaldi";
          repo = name;
          rev = "69e9a074125ad853aae244ce2aabc33811b99970";
          sha256 = "1x1h65l8582p7h7w5986sc9vfd7b88a7hsi68dbikm090gz8nlxx";
        };
      }
      rec {
        name = "pisces";
        src = pkgs.fetchFromGitHub {
          owner = "laughedelic";
          repo = name;
          rev = "34971b9671e217cfba0c71964f5028d44b58be8c";
          sha256 = "05wjq7v0v5hciqa27wx2xypyywa4291pxmmvfv5yvwmxm1pc02hm";
        };
      }
    ];
  };
}
