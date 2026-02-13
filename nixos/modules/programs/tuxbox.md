# TuxBox {#module-programs-tuxbox}

[TuxBox](https://github.com/AndyCappDev/tuxbox) is a Linux driver for TourBox devices.

## Input and dialout group {#module-programs-tuxbox-groups}

For the driver to work your user needs to be in the `input` and `dialout` group. This module does
that setup for you, but you need to specify the user for which the setup should be done.

```
programs.tuxbox = {
  enable = true;
  user = "john";
};
```

## Profile switching {#module-programs-tuxbox-profile-switching}

Profile switching requires the Systemd service to have its path amended with the applications used
to verify the running compositor. The checks can be found [here in the source
code](https://github.com/AndyCappDev/tuxbox/blob/2827c69fa293fec6d6c00303707dd173c484d291/tuxbox/window_monitor.py#L72).

Otherwise, profile switching will be disabled by the application.

The module handles this for you.

## GUI driver restart {#module-programs-tuxbox-driver-restart}

The GUI will restart the `tuxbox` driver when saving changes to profiles. However, before the
`tuxbox` Systemd service is restarted or the user supplied restart command is run, the application
checks with `pgrep` if there is a running driver process. This fails for the built package under
NixOS since the process is named `tuxbox-wrapped` but `python.*-m.*tuxbox` is used for the search.

Therefore, the package patches the source code to use a `pgrep` search string that works for NixOS.

The logic for the check is [here in the source
code](https://github.com/AndyCappDev/tuxbox/blob/2827c69fa293fec6d6c00303707dd173c484d291/tuxbox/gui/driver_manager.py#L95).
