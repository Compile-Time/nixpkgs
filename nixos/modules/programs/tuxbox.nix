{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.tuxbox;
in {
  options.programs.tuxbox = {
    enable = lib.mkEnableOption "TuxBox";
    package = lib.mkPackageOption pkgs "tuxbox" {};
    users = lib.mkOption {
      description = "User to add to the input and dialout group for the driver. If no user is assigned, the program will not work.";
      default = [];
      type = lib.types.listOf lib.types.str;
      example = ''
        programs.tuxbox = {
          enable = true;
          # The user name can be retrieved with `whoami` or `id -un`.
          user = [ "john" ];
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.length cfg.users == 0;
        message = "Users need to be set for the TuxBox driver to work!";
      }
      {
        assertion = lib.lists.all (user: lib.hasAttr user config.users.users) cfg.users;
        message = "Some or all users do not exist on the system! The TuxBox driver will not work for all users!";
      }
    ];

    environment.systemPackages = [cfg.package];

    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    '';

    users.users."${cfg.user}".extraGroups = [
      "input"
      "dialout"
    ];

    systemd.services."tuxbox" = {
      enable = true;
      name = "tuxbox.service";
      wantedBy = ["default.target"];
      after = ["graphical-session.target"];
      path = [
        pkgs.glib
        pkgs.hyprland
        pkgs.kdotool
        pkgs.niri
        pkgs.sway
        pkgs.xdotool
      ];
      unitConfig = {
        Description = "TuxBox Driver";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = cfg.tuxbox-installation;
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      CompileTime
    ];
    doc = ./tuxbox.md;
  };
}
