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
    user = lib.mkOption {
      description = "User to add to the input and dialout group for the driver. If no user is assigned, the program will not work.";
      default = "";
      type = lib.types.str;
      example = ''
        programs.tuxbox = {
          enable = true;
          # The user name can be retrieved with `whoami` or `id -un`.
          user = "john";
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasAttr cfg.user config.users.users;
        message = "User for TuxBox driver is not set!";
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
      environment = {
        XDG_CURRENT_DESKTOP = "${cfg.xdgCurrentDesktop}";
        XDG_SESSION_TYPE = "${cfg.xdgSessionType}";
        WAYLAND_DISPLAY = "${cfg.waylandDisplay}";
      };
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
